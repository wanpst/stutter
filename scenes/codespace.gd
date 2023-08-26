extends Control

@onready var code_edit := $CodeEdit as CodeEdit
var token_regex: RegEx = RegEx.new()


class Reader extends RefCounted:
	var tokens: Array[String]
	var current_token: int = 0

	func _init(p_tokens: Array[String] = []) -> void:
		tokens = p_tokens

	func next() -> String:
		current_token += 1
		return tokens[current_token-1]
	
	func peek() -> String:
		if tokens.size() >= current_token + 1:
			return tokens[current_token]
		else:
			return ""


func _ready() -> void:
	# Pilfered directly from https://github.com/kanaka/mal. I had to
	#
	# - [\s,]*: Matches any number of whitespaces or commas. This is not captured
	#   so it will be ignored and not tokenized.
	#
	# - ~@: Captures the special two-characters ~@ (tokenized).
	#
	# - [\[\]{}()'`~^@]: Captures any special single character, one of
	#   []{}()'`~^@ (tokenized).
	#
	# - "(?:\\.|[^\\"])*"?: Starts capturing at a double-quote and stops at the
	#   next double-quote unless it was preceded by a backslash in which case it
	#   includes it until the next double-quote (tokenized). It will also
	#   match unbalanced strings (no ending double-quote) which should be
	#   reported as an error.
	#
	# - ;.*: Captures any sequence of characters starting with ; (tokenized).
	#
	# - [^\s\[\]{}('"`,;)]*: Captures a sequence of zero or more non special
	#   characters (e.g. symbols, numbers, "true", "false", and "nil") and is sort
	#   of the inverse of the one above that captures special characters (tokenized).
	token_regex.compile("[\\s ,]*(~@|[\\[\\]{}()'`~@]|\"(?:[\\\\].|[^\\\\\"])*\"?|;.*|[^\\s \\[\\]{}()'\"`~@,;]*)")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("codespace_eval_sexpr"):
		get_viewport().set_input_as_handled()
		if not code_edit.text.is_empty():
			rep(code_edit.text)


func _read_str(input: String) -> StType:
	var reader = Reader.new(_tokenize(input))
	return _read_form(reader)

func _tokenize(input: String) -> Array[String]:
	var matches: Array[RegExMatch] = token_regex.search_all(input)

	# Array[RegExMatch] to Array[String]
	var string_tokens: Array[String] = []
	for regex_match in matches:
		const CAPTURING_GROUP = 1
		string_tokens.push_back(regex_match.get_string(CAPTURING_GROUP))

	return string_tokens

func _read_form(reader: Reader) -> StType:
	match reader.peek()[0]:
		# comment
		';':
			return null
		')':
			return StErr.new("Unexpected `)`")
		'(':
			return _read_list(reader)
		_:
			return _read_atom(reader)

func _read_list(reader) -> StType:
	var list := StList.new()

	reader.next()
	while reader.peek() != ')':
		if reader.peek().is_empty():
			return StErr.new("Unclosed list")
		
		var value = _read_form(reader)

		if value is StErr:
			return value
		if value == null:
			continue

		list.value.push_back(value)
		reader.next()

	return list

func _read_atom(reader) -> StType:
	var token = reader.peek()

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
	else:
		return StSymbol.new(token)

func _pr_str(input: StType) -> String:
	if input is StErr:
		return "ERROR: " + input.what
	elif input is StInt:
		return str(input.value)
	elif input is StFloat:
		return str(input.value).pad_decimals(1)
	elif input is StBool:
		return str(input.value)
	elif input is StNil:
		return "nil"
	elif input is StSymbol:
		return input.value
	elif input is StList:
		return "(" + " ".join(input.value.map(_pr_str)) + ")"
	else:
		push_error("Unhandled type")
		return ""


func read(input: String) -> StType:
	return _read_str(input)

func eval(input: StType) -> StType:
	return input

func put(input: StType) -> String:
	# normally, this means we found nothing but a comment
	if input == null:
		return ""

	return _pr_str(input)

func rep(input: String) -> void:
	print(put(eval(read(input))))
