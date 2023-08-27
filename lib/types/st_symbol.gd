class_name StSymbol
extends StType

var value: String

func _init(p_value: String = "") -> void:
	value = p_value

func _to_string() -> String:
	return value
