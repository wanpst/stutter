extends Control

@onready var code_edit := $"%CodeEdit" as CodeEdit
@onready var output_label := $"%OutputLabel" as RichTextLabel

var repl_env := Env.new()


func _ready() -> void:
	repl_env.eset(StSymbol.new("+"), StFunction.new(Library.add))
	repl_env.eset(StSymbol.new("-"), StFunction.new(Library.sub))
	repl_env.eset(StSymbol.new("*"), StFunction.new(Library.mul))
	repl_env.eset(StSymbol.new("/"), StFunction.new(Library.div))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("codespace_eval_sexpr"):
		get_viewport().set_input_as_handled()
		if not code_edit.text.is_empty():
			rep(code_edit.text)


func read(input: String) -> StType:
	return Reader.new().read_str(input)


func put(input: StType) -> String:
	# catch-all check for having nothing to do
	if input == null:
		return ""

	return StType.pr_str(input, true)


func rep(input: String) -> void:
	var result := put(Eval.eval(read(input), repl_env))
	if not result.is_empty():
		output_label.append_text(result + "\n")
