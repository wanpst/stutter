class_name StList
extends StType

var value: Array[StType]

func _init(p_value: Array[StType] = []) -> void:
	value = p_value

func _to_string() -> String:
	return "(" + " ".join(value.map(StType.pr_str)) + ")"
