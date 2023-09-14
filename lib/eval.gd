class_name Eval

class StFnFunction extends StType:
	var ast: StType
	var params: StList
	var env: Env
	var fn: StFunction


	func pr_to_string(print_readably := false) -> String:
		return "#<function>"


static func _eval_ast(ast: StType, env: Env) -> StType:
	if ast is StSymbol:
		return env.eget(ast)

	elif ast is StList:
		var evaluated: StList
		if ast is StVector:
			evaluated = StVector.new()
		else:
			evaluated = StList.new()

		for element in ast.elements:
			var element_evaluated := eval(element, env)
			if element_evaluated is StErr:
				return element_evaluated
			else:
				evaluated.push_back(element_evaluated)

		return evaluated

	elif ast is StHashmap:
		var evaluated := StHashmap.new()

		for key in ast.elements:
			evaluated.elements[key] = eval(ast.elements[key], env)
			if evaluated.elements[key] is StErr:
				return evaluated.elements[key]

		return evaluated

	else:
		return ast


static func eval(ast: StType, env: Env) -> StType:
	while true:
		if (not ast is StList) or (ast is StVector):
			return _eval_ast(ast, env)

		if ast.elements.is_empty():
			return ast

		# special forms
		if ast.elements[0] is StSymbol:
			match ast.elements[0].value:
				"def!":
					if ast.elements.size() != 3:
						return StErr.new("def! expected 2 arguments, got " + str(ast.elements.size()-1))
					if not ast.elements[1] is StSymbol:
						return StErr.new("def! argument 1 must be symbol")

					var value_evaluated := eval(ast.elements[2], env)
					if value_evaluated is StErr:
						return value_evaluated
					env.eset(ast.elements[1], value_evaluated) 
					return value_evaluated

				"let*":
					if ast.elements.size() != 3:
						return StErr.new("let* expected 2 arguments, got " + str(ast.elements.size()-1))
					if not ast.elements[1] is StList:
						return StErr.new("let* argument 1 must be list")

					var let_env := Env.new(env)
					for i in range(0, ast.elements[1].elements.size(), 2):
						var key: StType = ast.elements[1].elements[i]
						if not key is StSymbol:
							return StErr.new("let* binding list key " + str(i+1) + " is not a symbol")

						var value: StType = ast.elements[1].elements[i+1]
						var value_evaluated := eval(value, let_env)
						if value_evaluated is StErr:
							return value_evaluated
						let_env.eset(key, value_evaluated)
					env = let_env
					ast = ast.elements[2]
					continue

				"do":
					var evaluated: StType
					for element in ast.elements.slice(1, -1):
						evaluated = _eval_ast(element, env)
						if evaluated is StErr:
							return evaluated
					ast = ast.back()
					continue

				"if":
					if ast.elements.size() < 3:
						return StErr.new("if expected 2 arguments, got " + str(ast.elements.size()-1))

					var condition := eval(ast.elements[1], env)
					if condition is StErr:
						return condition

					# condition is not nil or false
					if ((not condition is StNil) and
						(not (condition is StBool and condition.value == false))):
						ast = ast.elements[2]
						continue

					# condition is nil or false, but there is no "else" parameter
					if ast.elements.size() < 4:
						return StNil.new()

					# condition is nil or false
					ast = ast.elements[3]
					continue

				"fn*":
					if ast.elements.size() == 1:
						return StErr.new("fn* expected at least 1 argument, got 0")

					var fn_data := StFnFunction.new()
					fn_data.ast = ast.elements[2]
					fn_data.params = ast.elements[1]
					fn_data.env = env
					fn_data.fn = StFunction.new(
						func(args: Array) -> StType:
							if ast.elements.size() == 2:
								return StNil.new()

							var new_env := Env.new(env, ast.elements[1], args)
							return eval(ast.elements[2], new_env))
					return fn_data


		var evaluated := _eval_ast(ast, env)
		if evaluated is StErr:
			return evaluated

		var fn = evaluated.elements[0]
		var fn_args: Array = evaluated.elements.slice(1)

		if fn is StFnFunction:
			ast = fn.ast
			env = Env.new(fn.env, fn.params, fn_args)
			continue
		elif fn is StFunction:
			return fn.value.call(fn_args)
		else:
			return StErr.new("First element of evaluated list must be a function")

	return null
