local Character = {}
Character.__index = Character

function Character.new(characterModel: Model)
	local self = setmetatable({}, Character)
	self.characterModel = characterModel

	return self
end

export type Character = typeof(Character.new(...))

function Character.Destroy(self: Character)
	self.characterModel:Destroy()
end

return Character
