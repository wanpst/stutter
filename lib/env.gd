class_name Env
extends RefCounted

var outer: Env
var data: Dictionary = {}


func _init(p_outer: Env = null, binds: StList = null, exprs: Array = []) -> void:
	outer = p_outer
	if binds == null:
		return

	for i in binds.elements.size():
		# variadic parameter
		if binds.elements[i].value == "&":
			# do nothing if the & symbol is the last parameter
			if binds.elements[i] == binds.elements[-1]:
				continue

			eset(binds.elements[i+1], StList.new(exprs.slice(i)))

			# any symbols after one that is a variadic parameter will be ignored
			break

		eset(binds.elements[i], exprs[i])


func eset(key: StSymbol, value: StType) -> void:
	data[key.value] = value


func find(key: StSymbol) -> Env:
	if key.value in data:
		return self

	if outer != null:
		return outer.find(key)

	return null


func eget(key: StSymbol) -> StType:
	var env := find(key)
	if env == null:
		return StErr.new("Unknown symbol `" + key.value + "`")

	return env.data[key.value]
