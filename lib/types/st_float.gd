class_name StFloat
extends StType

var value: float


func _init(p_value: float = 0.0) -> void:
	value = p_value


func _to_string() -> String:
	if abs(value) == INF or is_nan(value):
		return str(value)

	return str(value).pad_decimals(1)
