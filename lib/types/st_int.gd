class_name StInt
extends StType

var value: int


func _init(p_value: int = 0) -> void:
	value = p_value


func pr_to_string(print_readably := false) -> String:
	return str(value)
