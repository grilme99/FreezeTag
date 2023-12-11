local Players = game:GetService("Players")

local Component = require("@Packages/Component")
local Log = require("@Packages/Log").new()

local Tags = require("@Enums/Tags")

local PlayerCharacter = Component.new({
	Tag = Tags.PlayerCharacter,
	Ancestors = { workspace },
})

function PlayerCharacter:Construct()
	local character = self.Instance :: Model
	local humanoid: Humanoid = character:WaitForChild("Humanoid")
	local rootPart: BasePart = character:WaitForChild("HumanoidRootPart")

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
			local iceBlock = Instance.new("Part")
			iceBlock.Name = "IceBlock"
			iceBlock.Size = Vector3.new(6, 10, 6)
			iceBlock.Color = Color3.fromRGB(0, 162, 255)
			iceBlock.Transparency = 0.3
			iceBlock.Material = Enum.Material.Ice
			iceBlock.Anchored = true
			iceBlock.CanCollide = false
			iceBlock.Position = rootPart.Position
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
