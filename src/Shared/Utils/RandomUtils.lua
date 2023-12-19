type Array<T> = { T }

local RandomUtils = {}

function RandomUtils.RandomInArray<T>(arr: Array<T>, rng: Random?): T
	if rng == nil then
		rng = Random.new(os.time() * os.clock())
	end

	local len = #arr
	local randomIndex = (rng :: Random):NextInteger(1, len)

	local element = arr[randomIndex]
	if element == nil then
		error("Random index was nil, this shouldn't be possible")
	end

	return element
end

function RandomUtils.RandomInObject<T, Y>(obj: { [T]: Y }, rng: Random?): (T, Y)
	-- Convert the keys of the object to an array
	-- Not the most efficient impl, but should be good enough for our uses
	local keys: { T } = {}
	for key, _ in obj do
		table.insert(keys, key)
	end

	local randomKey = RandomUtils.RandomInArray(keys, rng)
	local randomValue = obj[randomKey]

	return randomKey, randomValue
end

function RandomUtils.RandomInRegion(position: CFrame, size: Vector3, rng: Random?): Vector3
	if rng == nil then
		rng = Random.new(os.time() * os.clock())
	end

	local halfSize = size * 0.5

	-- TODO Luau: Remove type asserts once Luau respects guard clauses
	local randX = (rng :: Random):NextNumber(-halfSize.X, halfSize.X)
	local randY = (rng :: Random):NextNumber(-halfSize.Y, halfSize.Y)
	local randZ = (rng :: Random):NextNumber(-halfSize.Z, halfSize.Z)

	local offset = Vector3.new(randX, randY, randZ)
	return position * offset
end

function RandomUtils.ShuffleArray<T>(arr: Array<T>, rng_: Random?): Array<T>
	local rng = rng_ or Random.new(os.time() * os.clock())

	local shuffled = table.create(#arr)

	for index, value in arr do
		local randomIndex = rng:NextInteger(1, index)
		shuffled[index] = shuffled[randomIndex]
		shuffled[randomIndex] = value
	end

	return shuffled
end

return RandomUtils
