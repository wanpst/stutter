class_name Reader
extends RefCounted

static var token_regex := RegEx.create_from_string(
	'[\\s ,]*(~@|[\\[\\]{}()\'`~@]|"(?:[\\\\].|[^\\\\"])*"?|;.*|[^\\s \\[\\]{}()\'"`~@,;]*)'
)
static var string_regex := RegEx.create_from_string('^"((?:[\\\\].|[^\\\\"])*)"$')
var tokens: Array[String]
var current_token: int = 0


func next() -> String:
	current_token += 1
	return tokens[current_token - 1]


func peek() -> String:
	if current_token < tokens.size():
		return tokens[current_token]
	else:
		return ""


func read_str(input: String) -> StType:
	tokens.assign(_tokenize(input))
	if tokens.is_empty():
		return null
	else:
		return _read_form()


# FIXME: the return type for this function should really be Array[String],
# but Godot has forced my hand; see godotengine/godot issue #72566
func _tokenize(input: String) -> Array:
	var matches: Array[RegExMatch] = token_regex.search_all(input)

	# callables to keep only the useful substrings in the regex matches
	var ignore_func := func(m: RegExMatch) -> bool:
		var substring := m.get_string(1)
		return not substring.begins_with(";") and not substring.is_empty()
	var substring_func := func(m: RegExMatch) -> String:
		return m.get_string(1)

	return matches.filter(ignore_func).map(substring_func)


func _token_to_symbol_list(symbol: String) -> StType:
	next()
	if peek().is_empty():
		return StErr.new("Unexpected EOF")

	var rest := _read_form()
	if rest is StErr:
		return rest

	var result := StList.new()
	result.push_back(StSymbol.new(symbol))
	result.push_back(rest)
	return result


func _read_form() -> StType:
	match peek()[0]:
		# macros
		"'":
			return _token_to_symbol_list("quote")
		"`":
			return _token_to_symbol_list("quasiquote")
		"~":
			if peek() == "~@":
				return _token_to_symbol_list("splice-unquote")
			return _token_to_symbol_list("unquote")
		"@":
			return _token_to_symbol_list("deref")
		"^":
			next()
			if peek().is_empty():
				return StErr.new("Unexpected EOF")
			var meta := _read_form()
			if meta is StErr:
				return meta

			var result := _token_to_symbol_list("with-meta")
			if not result is StErr:
				result.push_back(meta)
			return result
		# errors
		")":
			return StErr.new("Unexpected `)`")
		"]":
			return StErr.new("Unexpected `]`")
		"}":
			return StErr.new("Unexpected `}`")
		# readable
		"(":
			return _read_list(StList.new(), "(", ")")
		"[":
			return _read_list(StVector.new(), "[", "]")
		"{":
			var contents := _read_list(StList.new(), "{", "}")
			if contents is StErr:
				return contents
			return StHashmap.from_seq(contents)
		_:
			return _read_atom()


func _read_list(seq: StList, start: String, end: String) -> StType:
	assert(peek() == start, "Tried to read missing `" + start + "`")
	
	next()
	while peek() != end:
		if peek().is_empty():
			return StErr.new("Unclosed `" + start + "`")

		var value := _read_form()

		if value is StErr:
			return value

		seq.push_back(value)
		next()

	return seq


func _read_atom() -> StType:
	var token := peek()
	var string_match := string_regex.search(token)

	if token.is_valid_int():
		return StInt.new(token.to_int())
	elif token.is_valid_float():
		return StFloat.new(token.to_float())
	elif token == "inf":
		return StFloat.new(INF)
	elif token == "-inf":
		return StFloat.new(-INF)
	elif token == "nan":
		return StFloat.new(NAN)
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
