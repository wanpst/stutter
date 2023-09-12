class_name StType
extends RefCounted


static func pr_str(input: StType, print_readably := false, skip_quotes := false) -> String:
	if input is StString:
		return input.pretty_to_string(print_readably, skip_quotes)

	return str(input)
