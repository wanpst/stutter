class_name StType
extends RefCounted

static func pr_str(input: StType, print_readably := false) -> String:
	# FIXME: ideally, this would be in StString's _to_string. but Godot says
	# it takes no arguments, and making a replacement function to use for
	# every single StType just to move one block of code seems even worse
	if input is StString:
		if print_readably:
			# NOTE: c_escape() will escape single quotes; this is close enough!
			return '\"' + input.value.json_escape() + '\"'
		else:
			return input.value
	
	return str(input)
