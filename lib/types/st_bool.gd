class_name StBool
extends StType

var value: bool

func _init(p_value: bool = false) -> void:
	value = p_value

func _to_string() -> String:
	return str(value)
