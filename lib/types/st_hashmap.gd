class_name StHashmap
extends StType

var elements: Dictionary


func _init(p_elements: Dictionary = {})-> void:
	elements = p_elements


func pr_to_string(print_readably := false) -> String:
	var processed := "{"

	var pairs := []
	for key in elements:
		pairs.push_back(StType.pr_str(key))
		pairs.push_back(StType.pr_str(elements[key]))
	processed += " ".join(pairs)

	processed += "}"
	return processed


static func from_seq(seq: StList) -> StType:
	var hashmap := StHashmap.new()
	
	if seq.elements.is_empty():
		return hashmap

	# treat every pair of elements here as a key and its value
	for i in range(seq.elements.size()):
		# key (element is odd)
		if (i+1) % 2 != 0:
			if not seq.elements[i] is StString:
				return StErr.new("Key is not string or keyword")
			if seq.elements[i] == seq.elements[-1]:
				return StErr.new("Missing value of key " + StType.pr_str(seq.elements[-1]))
		# value (element is even)
		else:
			hashmap.elements[seq.elements[i-1]] = seq.elements[i]

	return hashmap
