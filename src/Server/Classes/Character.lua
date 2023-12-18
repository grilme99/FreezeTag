local CollectionService = game:GetService("CollectionService")

local Signal = require("@Packages/Signal")

local CharacterNormalizer = require("@Utils/CharacterNormalizer")
local Tags = require("@Enums/Tags")

local Character = {}
Character.__index = Character

function Character.new(characterModel: Model)
	local self = setmetatable({}, Character)
	self.characterModel = characterModel
	self.destroying = Signal.new()

	-- Add `PlayerCharacter` tag to the character so that it can be queried
	CollectionService:AddTag(characterModel, Tags.PlayerCharacter)

	-- Add `Frozen` attribute to the character so that it can be viewed in the
	-- properties panel before the character is actually frozen for the first
	-- time.
	characterModel:SetAttribute("Frozen", false)

	return self
end

export type Character = typeof(Character.new(...))

--- Normalize the character so that all characters are the same height. This is
--- essential for fair gameplay with custom avatars. Only needs to be called
--- once per spawn. This can yield if the character is not loaded yet.
function Character.NormalizeHeightAsync(self: Character, heightTarget: number)
	CharacterNormalizer.normalize(self.characterModel, heightTarget)
end

function Character.Freeze(self: Character)
	local character = self.characterModel
	character:SetAttribute("Frozen", true)
end

function Character.Unfreeze(self: Character)
	local character = self.characterModel
	character:SetAttribute("Frozen", false)
end

function Character.Destroy(self: Character)
	self.destroying:Fire()
	self.characterModel:Destroy()
end

return Character
