class_name StVector
extends StList


func _init(p_elements: Array[StType] = []) -> void:
	super(p_elements)


func pr_to_string(print_readably := false) -> String:
	return "[" + " ".join(elements.map(
		func (e: StType) -> String: return e.pr_to_string(print_readably))) + "]"
