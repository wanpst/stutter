extends Control

@onready var code_edit := $CodeEdit as CodeEdit
var token_regex: RegEx = RegEx.new()


class Reader:
	var tokens: Array[String]
	var current_token: int = 0

	func _init(p_tokens: Array = []) -> void:
		tokens.assign(p_tokens)

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

# FIXME: the return type for this function should really be Array[String],
# but Godot has forced my hand; see godotengine/godot issue #72566 
func _tokenize(input: String) -> Array:
	var matches: Array[RegExMatch] = token_regex.search_all(input)

	# extract the substrings out of the regex matches
	const CAPTURING_GROUP = 1
	return matches.map(func (m): return m.get_string(CAPTURING_GROUP))

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

func _read_list(reader: Reader) -> StType:
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

		list.push_back(value)
		reader.next()

	return list

func _read_atom(reader: Reader) -> StType:
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


func read(input: String) -> StType:
	return _read_str(input)

func eval(input: StType) -> StType:
	return input

func put(input: StType) -> String:
	# normally, this means we found nothing but a comment
	if input == null:
		return ""

	return StType.pr_str(input)

func rep(input: String) -> void:
	print(put(eval(read(input))))
