class_name StSymbol
extends StType

var value: String


func _init(p_value: String = "") -> void:
	value = p_value


func pr_to_string(print_readably := false) -> String:
	return value
