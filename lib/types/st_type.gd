class_name StType
extends RefCounted

static func pr_str(input: StType) -> String:
	if input is StType:
		return input.to_string()
	else:
		push_error("Unhandled type")
		return ""
