class_name StFloat
extends StType

var value: float


func _init(p_value: float = 0.0) -> void:
	value = p_value


func _to_string() -> String:
	return str(value).pad_decimals(1)
