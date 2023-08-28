class_name StList
extends StType

var elements: Array[StType]


func _init(p_elements: Array[StType] = []) -> void:
	elements = p_elements


func _to_string() -> String:
	return "(" + " ".join(elements.map(StType.pr_str)) + ")"


func push_back(value: StType) -> void:
	elements.push_back(value)
