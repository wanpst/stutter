extends Control

@onready var code_edit := $"%CodeEdit" as CodeEdit
@onready var output_label := $"%OutputLabel" as RichTextLabel

var repl_env := Env.new()


func _ready() -> void:
	repl_env.eset(StSymbol.new("+"), StLambda.new(_add))
	repl_env.eset(StSymbol.new("-"), StLambda.new(_sub))
	repl_env.eset(StSymbol.new("*"), StLambda.new(_mul))
	repl_env.eset(StSymbol.new("/"), StLambda.new(_div))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("codespace_eval_sexpr"):
		get_viewport().set_input_as_handled()
		if not code_edit.text.is_empty():
			rep(code_edit.text)


## Returns the sum of the contents of [param addends].
##
## Returns 0 if called with no arguments.
func _add(addends: Array) -> StType:
	if addends.is_empty():
		return StInt.new(0)
	
	for i in addends.size():
		if (not addends[i] is int) and (not addends[i] is float):
			return StErr.new("+ argument " + str(i+1) + " is not int or float")

	var result = addends.reduce(func(sum, x): return sum + x)

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


## Returns the difference between the first element of
## [param subtrahends] and the sum of the rest.
##
## In other words, it subtracts each element
## from the first one, in order.[br]
## Returns 0 if called with no arguments.
func _sub(subtrahends: Array) -> StType:
	if subtrahends.is_empty():
		return StInt.new(0)

	for i in subtrahends.size():
		if (not subtrahends[i] is int) and (not subtrahends[i] is float):
			return StErr.new("- argument " + str(i+1) + " is not int or float")
	
	if subtrahends.size() == 1:
		return StInt.new(-subtrahends[0])
	
	var first = subtrahends[0]
	var sum_of_rest = subtrahends.slice(1).reduce(func(sum, x): return sum + x)
	var result = first - sum_of_rest

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


## Returns the product of the elements in [param factors].
##
## Returns 1 if called with no arguments.
func _mul(factors: Array) -> StType:
	if factors.is_empty():
		return StInt.new(1)

	for i in factors.size():
		if (not factors[i] is int) and (not factors[i] is float):
			return StErr.new("* argument " + str(i+1) + " is not int or float")

	var result = factors.reduce(func(sum, x): return sum * x)

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


## Returns the quotient of dividing the first element in [param divs]
## by the product of the rest.
##
## In other words, it divides the first element by each following one,
## in order.[br]
## Returns the multiplicative inverse of the first element if called with
## only one argument. This will be [StInt] if the element is an int, and
## [StFloat] if the element is a float.
func _div(divs: Array) -> StType:
	if divs.is_empty():
		return StErr.new("/ expected at least 1 argument, got 0")

	for i in divs.size():
		if (not divs[i] is int) and (not divs[i] is float):
			return StErr.new("/ argument " + str(i+1) + " is not int or float")

	var result

	if divs.size() == 1:
		result = 1 / divs[0]
	else:
		var first = divs[0]
		var product_of_rest = divs.slice(1).reduce(func(sum, x): return sum * x)
		result = first / product_of_rest
	
	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


func eval_ast(ast: StType, env: Env) -> StType:
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


func read(input: String) -> StType:
	return Reader.new().read_str(input)


func eval(ast: StType, env: Env) -> StType:
	if not ast is StList or ast is StVector:
		return eval_ast(ast, env)

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
	var evaluated := eval_ast(ast, env)
	if evaluated is StErr:
		return evaluated
		
	return evaluated.elements[0].value.call(
		evaluated.elements.slice(1).map(func(e: StType): return e.value))
	

func put(input: StType) -> String:
	# catch-all check for having nothing to do
	if input == null:
		return ""

	return StType.pr_str(input, true)


func rep(input: String) -> void:
	var result := put(eval(read(input), repl_env))
	if not result.is_empty():
		output_label.append_text(result + "\n")
