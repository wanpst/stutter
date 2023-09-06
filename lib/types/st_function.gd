class_name StFunction
extends StType

var value: Callable


func _init(p_value: Callable = Callable()) -> void:
	value = p_value


func _to_string() -> String:
	return "#<function>"
