extends Control

@onready var code_edit := $"%CodeEdit" as CodeEdit
@onready var output_label := $"%OutputLabel" as RichTextLabel

var repl_env := {
	"+": StLambda.new(func(addends: Array) -> StType:
		return StInt.new(
			addends.reduce(func(sum, x): return sum + x)
		)),
	"-": StLambda.new(func(subtrahends: Array) -> StType:
		return StInt.new(
			subtrahends[0] - subtrahends.slice(1).reduce(func(diff, x): return diff + x)
		)),
	"*": StLambda.new(func(factors: Array) -> StType:
		return StInt.new(
			factors.reduce(func(product, x): return product * x)
		)),
	"/": StLambda.new(func(divs: Array) -> StType:
		return StInt.new(
			divs[0] / divs.slice(1).reduce(func(product, x): return product * x)
		)),
}


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("codespace_eval_sexpr"):
		get_viewport().set_input_as_handled()
		if not code_edit.text.is_empty():
			rep(code_edit.text)


func eval_ast(ast: StType) -> StType:
	if ast is StSymbol:
		if ast.value in repl_env:
			return repl_env[ast.value]
		else:
			return StErr.new("Tried to evaluate undefined symbol `" + ast.value + "`")
	elif ast is StList:
		var evaluated: StList
		if ast is StVector:
			evaluated = StVector.new()
		else:
			evaluated = StList.new()

		for element in ast.elements:
			var element_evaluated = eval(element)
			if element_evaluated is StErr:
				return element_evaluated
			else:
				evaluated.push_back(element_evaluated)

		return evaluated
	elif ast is StHashmap:
		var evaluated := StHashmap.new()

		for key in ast.elements:
			evaluated.elements[key] = eval(ast.elements[key])
			if evaluated.elements[key] is StErr:
				return evaluated.elements[key]

		return evaluated
	else:
		return ast


func read(input: String) -> StType:
	return Reader.new().read_str(input)


func eval(ast: StType) -> StType:
	if ast is StList and not ast is StVector:
		if ast.elements.is_empty():
			return ast
		else:
			var evaluated = eval_ast(ast)
			if evaluated is StErr:
				return evaluated
			return evaluated.elements[0].value.call(
				evaluated.elements.slice(1).map(func(e: StType): return e.value))
	else:
		return eval_ast(ast)


func put(input: StType) -> String:
	# catch-all check for having nothing to do
	if input == null:
		return ""

	return StType.pr_str(input, true)


func rep(input: String) -> void:
	var result := put(eval(read(input)))
	if not result.is_empty():
		output_label.append_text(result + "\n")
