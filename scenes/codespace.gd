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


func _add(addends: Array) -> StType:
	var result = addends.reduce(func(sum, x): return sum + x)

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


func _sub(subtrahends: Array) -> StType:
	var first = subtrahends[0]
	var sum_of_rest = subtrahends.slice(1).reduce(func(sum, x): return sum + x)
	var result = first - sum_of_rest

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


func _mul(factors: Array) -> StType:
	var result = factors.reduce(func(sum, x): return sum * x)

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


func _div(divs: Array) -> StType:
	var first = divs[0]
	var product_of_rest = divs.slice(1).reduce(func(sum, x): return sum * x)
	var result = first / product_of_rest
	
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
				var value_evaluated := eval(ast.elements[2], env)
				if value_evaluated is StErr:
					return value_evaluated
				env.eset(ast.elements[1], value_evaluated) 
				return value_evaluated
			"let*":
				var let_env := Env.new(env)
				for i in range(0, ast.elements[1].elements.size(), 2):
					var key: StType = ast.elements[1].elements[i]
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
