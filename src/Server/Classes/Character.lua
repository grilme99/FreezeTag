local CollectionService = game:GetService("CollectionService")

local Tags = require("@Enums/Tags")

local Character = {}
Character.__index = Character

function Character.new(characterModel: Model)
	local self = setmetatable({}, Character)
	self.characterModel = characterModel

	-- Add `PlayerCharacter` tag to the character so that it can be queried
	CollectionService:AddTag(characterModel, Tags.PlayerCharacter)

	return self
end

export type Character = typeof(Character.new(...))

function Character.Freeze(self: Character)
	local character = self.characterModel
	character:SetAttribute("Frozen", true)
end

function Character.Unfreeze(self: Character)
	local character = self.characterModel
	character:SetAttribute("Frozen", false)
end

function Character.Destroy(self: Character)
	self.characterModel:Destroy()
end

return Character
