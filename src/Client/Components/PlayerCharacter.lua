local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require("@Packages/Component")
local Log = require("@Packages/Log").new()

local Tags = require("@Enums/Tags")

local IceCubeTemplate = ReplicatedStorage.Assets.Models.IceCube

local PlayerCharacter = Component.new({
	Tag = Tags.PlayerCharacter,
	Ancestors = { workspace },
})

function PlayerCharacter:Construct()
	local character = self.Instance :: Model
	local humanoid: Humanoid = character:WaitForChild("Humanoid")

	local isLocalCharacter = character == Players.LocalPlayer.Character

	local function setCharacterAnchored(isFrozen: boolean)
		for _, obj in character:GetDescendants() do
			if obj:IsA("BasePart") then
				obj.Anchored = isFrozen
			end
		end
	end

	Log:AtTrace():Log(`Created PlayerCharacter component for {character:GetFullName()}`)

	character:GetAttributeChangedSignal("Frozen"):Connect(function()
		local isFrozen = character:GetAttribute("Frozen")

		-- Apply physics changes to the character only if it belongs to us.
		if isLocalCharacter then
			if isFrozen then
				humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				setCharacterAnchored(true)
			else
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				setCharacterAnchored(false)
			end
		end

		-- Apply visual frozen effect
		if isFrozen then
			local characterCf = character:GetBoundingBox()

			local iceBlock = IceCubeTemplate:Clone()
			iceBlock.CFrame = characterCf
			iceBlock.Anchored = true
			iceBlock.Parent = character

			self.iceBlock = iceBlock
		elseif not isFrozen and self.iceBlock then
			local iceBlock = self.iceBlock

			-- First, let the ice block fall some before destroying it.
			iceBlock.Anchored = false
			self.iceBlock = nil

			task.delay(2, function()
				iceBlock:Destroy()
			end)
		end
	end)
end

function PlayerCharacter:Stop()
	if self.iceBlock then
		self.iceBlock:Destroy()
		self.iceBlock = nil
	end
end

return PlayerCharacter
