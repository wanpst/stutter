class_name StBool
extends StType

var value: bool


func _init(p_value: bool = false) -> void:
	value = p_value


func pr_to_string(print_readably := false) -> String:
	return str(value)
