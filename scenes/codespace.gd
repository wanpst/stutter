extends Control

@onready var code_edit := $"%CodeEdit" as CodeEdit
@onready var output_label := $"%OutputLabel" as RichTextLabel
var token_regex: RegEx = RegEx.new()
var string_regex: RegEx = RegEx.new()


class Reader:
	var tokens: Array[String]
	var current_token: int = 0

	func _init(p_tokens: Array = []) -> void:
		tokens.assign(p_tokens)

	func next() -> String:
		current_token += 1
		return tokens[current_token - 1]

	func peek() -> String:
		if current_token < tokens.size():
			return tokens[current_token]
		else:
			return ""


func _ready() -> void:
	token_regex.compile(
		'[\\s ,]*(~@|[\\[\\]{}()\'`~@]|"(?:[\\\\].|[^\\\\"])*"?|;.*|[^\\s \\[\\]{}()\'"`~@,;]*)'
	)
	string_regex.compile('^"((?:[\\\\].|[^\\\\"])*)"$')


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("codespace_eval_sexpr"):
		get_viewport().set_input_as_handled()
		if not code_edit.text.is_empty():
			rep(code_edit.text)


func _read_str(input: String) -> StType:
	var reader = Reader.new(_tokenize(input))
	if reader.tokens.is_empty():
		return null
	else:
		return _read_form(reader)


# FIXME: the return type for this function should really be Array[String],
# but Godot has forced my hand; see godotengine/godot issue #72566
func _tokenize(input: String) -> Array:
	var matches: Array[RegExMatch] = token_regex.search_all(input)

	# callables to keep only the useful substrings in the regex matches
	var ignore_func = func(m):
		var substring: String = m.get_string(1)
		return not substring.begins_with(";") and not substring.is_empty()
	var substring_func = func(m):
		return m.get_string(1)

	return matches.filter(ignore_func).map(substring_func)


func _read_form(reader: Reader) -> StType:
	match reader.peek()[0]:
		# errors
		")":
			return StErr.new("Unexpected `)`")
		"]":
			return StErr.new("Unexpected `]`")
		"}":
			return StErr.new("Unexpected `}`")
		# readable
		"(":
			return _read_list(reader, StList.new(), "(", ")")
		"[":
			return _read_list(reader, StVector.new(), "[", "]")
		"{":
			return StHashmap.from_seq(_read_list(reader, StList.new(), "{", "}"))
		_:
			return _read_atom(reader)


func _read_list(reader: Reader, seq: StList, start: String, end: String) -> StType:
	assert(reader.peek() == start, "Tried to read missing `" + start + "`")
	
	reader.next()
	while reader.peek() != end:
		if reader.peek().is_empty():
			return StErr.new("Unclosed `" + start + "`")

		var value = _read_form(reader)

		if value is StErr:
			return value

		seq.push_back(value)
		reader.next()

	return seq


func _read_atom(reader: Reader) -> StType:
	var token = reader.peek()
	var string_match := string_regex.search(token)

	if token.is_valid_int():
		return StInt.new(token.to_int())
	elif token.is_valid_float():
		return StFloat.new(token.to_float())
	elif token == "true":
		return StBool.new(true)
	elif token == "false":
		return StBool.new(false)
	elif token == "nil":
		return StNil.new()
	elif string_match:
		return StString.new(string_match.get_string(1).c_unescape())
	elif token[0] == '"':
		return StErr.new("Unclosed string")
	elif token[0] == ":":
		return StString.new("\u029e" + token.substr(1))
	else:
		return StSymbol.new(token)


func read(input: String) -> StType:
	return _read_str(input)


func eval(input: StType) -> StType:
	return input


func put(input: StType) -> String:
	# normally, this means we found nothing but a comment
	if input == null:
		return ""

	return StType.pr_str(input, true)


func rep(input: String) -> void:
	var result := put(eval(read(input)))
	if not result.is_empty():
		output_label.append_text(result + "\n")
