class_name StString
extends StType

var value: String


func _init(p_value: String = "") -> void:
	value = p_value


func pretty_to_string(print_readably := false, skip_quotes := false) -> String:
	if value.begins_with("\u029e"):
		return ":" + value.substr(1)

	if print_readably:
		# NOTE: c_escape() will escape single quotes; this is close enough!
		if skip_quotes:
			return value.json_escape()
		else:
			return '\"' + value.json_escape() + '\"'
	else:
		if skip_quotes:
			return value
		else:
			return '\"' + value + '\"'
