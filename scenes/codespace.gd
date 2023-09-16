class_name Codespace
extends Control

@onready var code_edit := $"%CodeEdit" as CodeEdit
static var output: RichTextLabel

var repl_env := Env.new()


func _ready() -> void:
	output = $"%OutputLabel"

	for symbol in Core.ns_gd:
		repl_env.eset(StSymbol.new(symbol), StFunction.new(Core.ns_gd[symbol]))
	repl_env.eset(StSymbol.new("eval"), StFunction.new(
		func seval(args: Array) -> StType:
			if args.size() != 1:
				return StErr.new("eval expected 1 argument, got " + str(args.size()))
			return Eval.eval(args[0], repl_env)))

	for function in Core.ns:
		Eval.eval(read(function), repl_env)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("codespace_eval_sexpr"):
		get_viewport().set_input_as_handled()
		if not code_edit.text.is_empty():
			rep(code_edit.text)


static func print_to_output(input: String) -> void:
	if not input.is_empty():
		output.append_text(input + "\n")


func read(input: String) -> StType:
	return Reader.new().read_str(input)


func put(input: StType) -> String:
	# catch-all check for having nothing to do
	if input == null:
		return ""

	return StType.pr_str(input, true)


func rep(input: String) -> void:
	var result := put(Eval.eval(read(input), repl_env))
	Codespace.print_to_output(result)
