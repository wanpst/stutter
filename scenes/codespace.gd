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

	repl_env.eset(StSymbol.new("swap!"), StFunction.new(
		func swap(args: Array) -> StType:
			if args.size() < 2:
				return StErr.new("swap! expected at least 2 arguments, got " + str(args.size()))
			if (not args[0] is StAtom):
				return StErr.new("def! argument 1 is not atom")
			if (not args[1] is StFunction):
				return StErr.new("def! argument 2 is not function")

			var apply_args := StList.new()
			apply_args.push_back(args[1])
			apply_args.push_back(args[0].value)
			apply_args.elements += args.slice(2)
			args[0].value = Eval.eval(apply_args, repl_env)
			return args[0].value))

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
