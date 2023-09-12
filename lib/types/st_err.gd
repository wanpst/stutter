class_name StErr
extends StType

var what: String


func _init(p_what: String = "") -> void:
	what = p_what


func pr_to_string(print_readably := false) -> String:
	return "ERROR: " + what
