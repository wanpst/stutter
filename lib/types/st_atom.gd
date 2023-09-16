class_name StAtom
extends StType

var value: StType


func _init(p_value: StType = null) -> void:
	value = p_value

func pr_to_string(print_readably := false) -> String:
	return "(atom " + value.pr_to_string() + ")"
