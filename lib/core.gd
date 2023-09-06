class_name Core

static var ns := {
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
}
