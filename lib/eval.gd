class_name Eval


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
	if not ast is StList or ast is StVector:
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
				return eval(ast.elements[2], let_env)
	
	# just a function call
	var evaluated := _eval_ast(ast, env)
	if evaluated is StErr:
		return evaluated
		
	return evaluated.elements[0].value.call(
		evaluated.elements.slice(1).map(func(e: StType): return e.value))
