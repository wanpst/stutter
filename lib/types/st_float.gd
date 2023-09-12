class_name StFloat
extends StType

var value: float


func _init(p_value: float = 0.0) -> void:
	value = p_value


func pr_to_string(print_readably := false) -> String:
	if abs(value) == INF or is_nan(value):
		return str(value)

	if step_decimals(value) == 0:
		return str(value) + ".0"

	return str(value)
