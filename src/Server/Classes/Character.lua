local CollectionService = game:GetService("CollectionService")

local Signal = require("@Packages/Signal")

local CharacterNormalizer = require("@Utils/CharacterNormalizer")
local Tags = require("@Enums/Tags")

type Map<K, V> = { [K]: V }

local Character = {}
Character.__index = Character

function Character.new(characterModel: Model)
	local self = setmetatable({}, Character)
	self.characterModel = characterModel
	self.destroying = Signal.new()

	self.baseWalkSpeed = 16
	self.walkSpeedMultipliers = {} :: Map<string, number>

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

function Character.SetBaseWalkSpeed(self: Character, walkSpeed: number)
	self.baseWalkSpeed = walkSpeed
	self:_reconcileWalkSpeed()
end

function Character.AddWalkSpeedMultiplier(self: Character, name: string, multiplier: number)
	self.walkSpeedMultipliers[name] = multiplier
	self:_reconcileWalkSpeed()
end

function Character.RemoveWalkSpeedMultiplier(self: Character, name: string)
	self.walkSpeedMultipliers[name] = nil
	self:_reconcileWalkSpeed()
end

function Character._reconcileWalkSpeed(self: Character)
	local newWalkSpeed = self.baseWalkSpeed
	for _, multiplier in pairs(self.walkSpeedMultipliers) do
		newWalkSpeed *= multiplier
	end

	local humanoid = self.characterModel:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = newWalkSpeed
	end
end

function Character.Destroy(self: Character)
	self.destroying:Fire()
	self.characterModel:Destroy()
end

return Character
