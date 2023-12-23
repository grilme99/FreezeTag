local PlayerService = require("@Services/PlayerService")
local TeamService = require("@Services/TeamService")

local Networking = require("@Server/Networking")

local function validatePlayerIsTagger(player: Player)
	return TeamService.GetPlayerTeam(player) == "Tagger"
end

local TagService = {}

function TagService.OnInit()
	Networking.TagPlayer.SetCallback(function(tagger, target)
		if not validatePlayerIsTagger(tagger) then
			return
		end

		-- TODO: Introduce character validation, this is wide open for exploits right now (#1).

		TagService.TagPlayer(target)
	end)

	Networking.UntagPlayer.SetCallback(function(tagger, target)
		if not validatePlayerIsTagger(tagger) then
			return
		end

		-- TODO: Introduce character validation, this is wide open for exploits right now (#1).

		TagService.UntagPlayer(target)
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
