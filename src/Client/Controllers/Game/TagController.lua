local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local BridgeNet = require("@Packages/BridgeNet")
local ImGizmo = require("@Packages/ImGizmo")
local Log = require("@Packages/Log").new()

local RoundController = require("@Controllers/Game/RoundController")

local ClientFeatureFlags = require("@Client/ClientFeatureFlags")

local CollisionGroup = require("@Enums/CollisionGroup")

local TagNetworking = BridgeNet.ClientBridge("TagNetworking")

local TagController = {}
TagController.OverlapParams = nil :: OverlapParams?

function TagController.OnInit()
	RunService.Heartbeat:Connect(TagController.OnStep)

	local overlapParams = OverlapParams.new()
	overlapParams.CollisionGroup = CollisionGroup.TagQuery
	overlapParams.MaxParts = 10

	TagController.OverlapParams = overlapParams
end

function TagController.OnStep()
	if not RoundController.IsRoundRunning then
		return
	end

	-- Check if there is a player in front of our character and report it to
	-- the server to freeze or unfreeze them.
	local player = Players.LocalPlayer
	local rootPart = player.Character and player.Character.PrimaryPart
	if not rootPart then
		return
	end

	local isTagger = RoundController.LocalPlayerTeam == "Tagger"

	-- Project a 3D box in front of the character, which will act as our hitbox
	local boxSize = Vector3.new(3, 5, 3)
	local boxCf = rootPart.CFrame * CFrame.new(0, -0.5, -boxSize.Z * 0.5)

	if ClientFeatureFlags.ShowDebugGizmos then
		ImGizmo.PushProperty("Color3", Color3.new(1, 0, 0))
		ImGizmo.Box:Draw(boxCf, boxSize, true)
	end

	local hitObjects = Workspace:GetPartBoundsInBox(boxCf, boxSize, TagController.OverlapParams)
	for _, object in hitObjects do
		local targetCharacter = object.Parent :: Model
		local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
		if not targetPlayer or targetPlayer == player then
			continue
		end

		local isTargetFrozen = targetCharacter:GetAttribute("Frozen") == true
			or targetCharacter:GetAttribute("LocalTagDebounce") == true

		if (isTargetFrozen and isTagger) or (not isTargetFrozen and not isTagger) then
			continue
		end

		-- There's going to be a network delay before the server can act on our
		-- tag request. This attribute acts as a cooldown between tag requests
		-- to prevent spamming the server.
		targetCharacter:SetAttribute("LocalTagDebounce", true)
		task.delay(5, function()
			if targetCharacter then
				targetCharacter:SetAttribute("LocalTagDebounce", nil)
			end
		end)

		Log:AtDebug():Log(`Caught player {targetPlayer.Name} in tag hitbox`)

		if isTagger then
			TagNetworking:Fire({
				action = "Tag",
				targetPlayer = targetPlayer,
			})
		else
			TagNetworking:Fire({
				action = "Untag",
				targetPlayer = targetPlayer,
			})
		end
	end
end

return TagController
