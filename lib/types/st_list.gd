class_name StList
extends StType

var elements: Array[StType]


func _init(p_elements: Array = []) -> void:
	elements.assign(p_elements)


func pr_to_string(print_readably := false) -> String:
	return "(" + " ".join(elements.map(
		func (e: StType) -> String: return e.pr_to_string(print_readably))) + ")"


func push_back(value: StType) -> void:
	elements.push_back(value)


func equals(other: StList) -> bool:
	if other.elements.size() != elements.size():
		return false
	
	for i in elements.size():
		if elements[i] is StList:
			if not other.elements[i] is StList:
				return false
			if not elements[i].equals(other.elements[i]):
				return false
		else:
			if elements[i].value != other.elements[i].value:
				return false

	return true
