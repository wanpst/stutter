class_name Library


## Returns the sum of the contents of [param addends].
##
## Returns 0 if called with no arguments.
static func add(addends: Array) -> StType:
	if addends.is_empty():
		return StInt.new(0)
	
	for i in addends.size():
		if (not addends[i] is int) and (not addends[i] is float):
			return StErr.new("+ argument " + str(i+1) + " is not int or float")

	var result = addends.reduce(func(sum, x): return sum + x)

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


## Returns the difference between the first element of
## [param subtrahends] and the sum of the rest.
##
## In other words, it subtracts each element
## from the first one, in order.[br]
## Returns 0 if called with no arguments.
static func sub(subtrahends: Array) -> StType:
	if subtrahends.is_empty():
		return StInt.new(0)

	for i in subtrahends.size():
		if (not subtrahends[i] is int) and (not subtrahends[i] is float):
			return StErr.new("- argument " + str(i+1) + " is not int or float")
	
	if subtrahends.size() == 1:
		return StInt.new(-subtrahends[0])
	
	var first = subtrahends[0]
	var sum_of_rest = subtrahends.slice(1).reduce(func(sum, x): return sum + x)
	var result = first - sum_of_rest

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


## Returns the product of the elements in [param factors].
##
## Returns 1 if called with no arguments.
static func mul(factors: Array) -> StType:
	if factors.is_empty():
		return StInt.new(1)

	for i in factors.size():
		if (not factors[i] is int) and (not factors[i] is float):
			return StErr.new("* argument " + str(i+1) + " is not int or float")

	var result = factors.reduce(func(sum, x): return sum * x)

	if result is float:
		return StFloat.new(result)

	return StInt.new(result)


## Returns the quotient of dividing the first element in [param divs]
## by the product of the rest.
##
## In other words, it divides the first element by each following one,
## in order.[br]
## Returns the multiplicative inverse of the first element if called with
## only one argument. This will be [StInt] if the element is an int, and
## [StFloat] if the element is a float.
static func div(divs: Array) -> StType:
	if divs.is_empty():
		return StErr.new("/ expected at least 1 argument, got 0")

	for i in divs.size():
		if (not divs[i] is int) and (not divs[i] is float):
			return StErr.new("/ argument " + str(i+1) + " is not int or float")

	var result

	if divs.size() == 1:
		result = 1 / divs[0]
	else:
		var first = divs[0]
		var product_of_rest = divs.slice(1).reduce(func(sum, x): return sum * x)
		result = first / product_of_rest
	
	if result is float:
		return StFloat.new(result)

	return StInt.new(result)
