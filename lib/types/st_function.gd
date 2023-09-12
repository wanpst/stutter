class_name StFunction
extends StType

var value: Callable


func _init(p_value: Callable = Callable()) -> void:
	value = p_value


func pr_to_string(print_readably := false) -> String:
	return "#<function>"
