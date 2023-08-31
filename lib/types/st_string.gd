class_name StString
extends StType

var value: String


func _init(p_value: String = "") -> void:
	value = p_value


func pretty_to_string(print_readably := false) -> String:
	if value.begins_with("\u029e"):
		return ":" + value.substr(1)

	if print_readably:
		# NOTE: c_escape() will escape single quotes; this is close enough!
		return '\"' + value.json_escape() + '\"'
	else:
		return '\"' + value + '\"'
