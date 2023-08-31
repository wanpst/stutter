class_name StType
extends RefCounted


static func pr_str(input: StType, print_readably := false) -> String:
	if input is StString:
		return input.pretty_to_string(print_readably)

	return str(input)
