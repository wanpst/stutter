class_name StVector
extends StList


func _init(p_elements: Array[StType] = []) -> void:
	super(p_elements)


func _to_string() -> String:
	return "[" + " ".join(elements.map(StType.pr_str)) + "]"
