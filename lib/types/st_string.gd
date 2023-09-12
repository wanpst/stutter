class_name StString
extends StType

var value: String


func _init(p_value: String = "") -> void:
	value = p_value


func pr_to_string(print_readably := false) -> String:
	if value.begins_with("\u029e"):
		return ":" + value.substr(1)

	if print_readably:
		var string_escaped := value \
			.replace('\\', '\\\\') \
			.replace('"', '\\"') \
			.replace('\n', '\\n')
		return '"' + string_escaped + '"'
	else:
		return value
