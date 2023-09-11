class_name Core

# core functions implemented in GDScript
static var ns_gd := {
	"+": (
	## Returns the sum of the contents of addends.
	##
	## Returns 0 if called with no arguments.
	func add(addends: Array) -> StType:
		if addends.is_empty():
			return StInt.new(0)

		for i in addends.size():
			if (not addends[i] is StInt) and (not addends[i] is StFloat):
				return StErr.new("+ argument " + str(i+1) + " is not int or float")

		var values = addends.map(func(a: StType): return a.value)
		var result = values.reduce(func(sum, x): return sum + x)

		if result is float:
			return StFloat.new(result)

		return StInt.new(result)),

	"-": (
	## Returns the difference between the first element of
	## subtrahends and the sum of the rest.
	##
	## In other words, it subtracts each element
	## from the first one, in order.
	## Returns 0 if called with no arguments.
	func sub(subtrahends: Array) -> StType:
		if subtrahends.is_empty():
			return StInt.new(0)

		for i in subtrahends.size():
			if (not subtrahends[i] is StInt) and (not subtrahends[i] is StFloat):
				return StErr.new("- argument " + str(i+1) + " is not int or float")

		if subtrahends.size() == 1:
			return StInt.new(-subtrahends[0])

		var first_value = subtrahends[0].value
		var rest_values = subtrahends.slice(1).map(func(s: StType): return s.value)
		var sum_of_rest = rest_values.reduce(func(sum, x): return sum + x)
		var result = first_value - sum_of_rest

		if result is float:
			return StFloat.new(result)

		return StInt.new(result)),

	"*": (
	## Returns the product of the elements in factors.
	##
	## Returns 1 if called with no arguments.
	func mul(factors: Array) -> StType:
		if factors.is_empty():
			return StInt.new(1)

		for i in factors.size():
			if (not factors[i] is StInt) and (not factors[i] is StInt):
				return StErr.new("* argument " + str(i+1) + " is not int or float")

		var values = factors.map(func(f: StType): return f.value)
		var result = values.reduce(func(product, x): return product * x)

		if result is float:
			return StFloat.new(result)

		return StInt.new(result)),

	"/": (
	## Returns the quotient of dividing the first element in divs
	## by the product of the rest.
	##
	## In other words, it divides the first element by each following one,
	## in order.
	## Returns the multiplicative inverse of the first element if called with
	## only one argument. This will be StInt if the element is an int, and
	## StFloat if the element is a float.
	func div(divs: Array) -> StType:
		if divs.is_empty():
			return StErr.new("/ expected at least 1 argument, got 0")

		for i in divs.size():
			if (not divs[i] is StInt) and (not divs[i] is StFloat):
				return StErr.new("/ argument " + str(i+1) + " is not int or float")

		var values = divs.map(func(d: StType): return d.value)
		var result

		if divs.size() == 1:
			result = 1 / values[0]
		else:
			var first = values[0]
			var product_of_rest = values.slice(1).reduce(func(product, x): return product * x)
			result = first / product_of_rest

		if result is float:
			return StFloat.new(result)

		return StInt.new(result)),

	"prn": (
	## Prints each of the arguments and returns nil.
   	func prn(args: Array) -> StNil:
		# args elements as strings, joined by spaces
		var joined := " ".join(
			args.map(func(a: StType) -> String:
				return StType.pr_str(a, true)))

		Codespace.print_to_output(joined)
		return StNil.new()),

	"list": (
	## Returns a list containing the arguments.
	func list(args: Array) -> StList:
		return StList.new(args)),

	"list?": (
	## Returns whether the first argument is a list.
	##
	## This returns false for vectors.
	func is_list(args: Array) -> StType:
		if args.size() != 1:
			return StErr.new("list? expected 1 argument, got " + str(args.size()))

		return StBool.new(args[0] is StList and not args[0] is StVector)),

	"empty?": (
	## Returns whether the first argument (list) is empty.
	func is_empty(args: Array) -> StType:
		if args.size() != 1:
			return StErr.new("empty? expected 1 argument, got " + str(args.size()))
		if not args[0] is StList:
			return StErr.new("empty? argument 1 is not list or vector")

		return StBool.new(args[0].elements.is_empty())),

	"count": (
	## Returns the number of elements in the first argument (list).
	func count(args: Array) -> StType:
		if args.size() != 1:
			return StErr.new("count expected 1 argument, got " + str(args.size()))
		if not args[0] is StList:
			return StErr.new("count argument 1 is not list or vector")

		return StInt.new(args[0].elements.size())),

	"=": (
	## Returns whether all arguments contain the same value(s).
	##
	## For lists that contain lists, this check is recursive.
	func equals(args: Array) -> StType:
		if args.is_empty():
			return StErr.new("= expected at least 1 argument, got 0")

		# at least one argument is a list
		if args.any(func(a): return a is StList):
			# every argument is a list; they could be equal
			if args.all(func(a): return a is StList):
				return StBool.new(args[0].equals(args[1]))
			# the types don't match, there's no way they're equal
			else:
				return StBool.new(false)

		# check if they're all equal to the first element (i.e. they're all the same)
		for i in range(1, args.size()):
			if args[i].value != args[0].value:
				return StBool.new(false)

		return StBool.new(true)),

	"<": (
	## Returns whether each argument is less than the last.
	##
	## Returns true if there is only one argument.
	func less_than(args: Array) -> StType:
		if args.is_empty():
			return StErr.new("< expected at least 1 argument, got 0")
		for i in args.size():
			if (not args[i] is StInt) and (not args[i] is StFloat):
				return StErr.new("< argument " + str(i+1) + " is not int or float")

		if args.size() == 1:
			return StBool.new(true)

		for i in range(1, args.size()):
			if not args[i-1].value < args[i].value:
				return StBool.new(false)

		return StBool.new(true)),

	"<=": (
	## Returns whether each argument is less than or equal to the last.
	##
	## Returns true if there is only one argument.
	func less_than_or_greater(args: Array) -> StType:
		if args.is_empty():
			return StErr.new("<= expected at least 1 argument, got 0")
		for i in args.size():
			if (not args[i] is StInt) and (not args[i] is StFloat):
				return StErr.new("<= argument " + str(i+1) + " is not int or float")

		if args.size() == 1:
			return StBool.new(true)

		for i in range(1, args.size()):
			if not args[i-1].value <= args[i].value:
				return StBool.new(false)

		return StBool.new(true)),

	">": (
	## Returns whether each argument is greater than the last.
	##
	## Returns true if there is only one argument.
	func greater_than(args: Array) -> StType:
		if args.is_empty():
			return StErr.new("> expected at least 1 argument, got 0")
		for i in args.size():
			if (not args[i] is StInt) and (not args[i] is StFloat):
				return StErr.new("> argument " + str(i+1) + " is not int or float")

		if args.size() == 1:
			return StBool.new(true)

		for i in range(1, args.size()):
			if not args[i-1].value > args[i].value:
				return StBool.new(false)

		return StBool.new(true)),

	">=": (
	## Returns whether each argument is greater than or equal to the last.
	##
	## Returns true if there is only one argument.
	func greater_than_or_greater(args: Array) -> StType:
		if args.is_empty():
			return StErr.new(">= expected at least 1 argument, got 0")
		for i in args.size():
			if (not args[i] is StInt) and (not args[i] is StFloat):
				return StErr.new(">= argument " + str(i+1) + " is not int or float")

		if args.size() == 1:
			return StBool.new(true)

		for i in range(1, args.size()):
			if not args[i-1].value >= args[i].value:
				return StBool.new(false)

		return StBool.new(true)),
}

# core functions implemented in Stutter
static var ns := [
	"
	(def! not (fn* [v]
		(if v false true)))
	",
]
