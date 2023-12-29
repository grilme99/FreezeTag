local BridgeNet = require("@Packages/BridgeNet")
local Log = require("@Packages/Log").new()
local t = require("@Packages/t")

local PlayerService = require("@Services/PlayerService")
local TeamService = require("@Services/TeamService")

local TagNetworking = BridgeNet.ServerBridge("TagNetworking")

local function validatePlayerIsTagger(player: Player)
	return TeamService.GetPlayerTeam(player) == "Tagger"
end

local function validatePlayerIsRunner(player: Player)
	return TeamService.GetPlayerTeam(player) == "Runner"
end

local TagService = {}

function TagService.OnInit()
	TagNetworking:Connect(function(player, message: any)
		local validator = t.strictInterface({
			action = t.union(t.literal("Tag"), t.literal("Untag")),
			targetPlayer = t.instanceIsA("Player"),
		})

		if not validator(message) then
			Log:AtWarning():Log(`Invalid message received from {player.Name}: {message}`)
			return
		end

		if message.action == "Tag" and not validatePlayerIsTagger(player) then
			Log:AtWarning():Log(`{player.Name} attempted to tag {message.targetPlayer.Name} but is not a tagger`)
			return
		elseif message.action == "Untag" and not validatePlayerIsRunner(player) then
			Log:AtWarning():Log(`{player.Name} attempted to untag {message.targetPlayer.Name} but is not a runner`)
			return
		end

		-- TODO: Introduce character validation, this is wide open for exploits right now (#1).

		if message.action == "Tag" then
			TagService.TagPlayer(message.targetPlayer)
		else
			TagService.UntagPlayer(message.targetPlayer)
		end
	end)
end

function TagService.TagPlayer(player: Player)
	local player = PlayerService.GetPlayer(player)
	local character = player.character

	if character then
		character:Freeze()
	end
end

function TagService.UntagPlayer(player: Player)
	local player = PlayerService.GetPlayer(player)
	local character = player.character

	if character then
		character:Unfreeze()
	end
end

return TagService
