local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MapName = require("@Enums/MapName")
local RandomUtils = require("@Utils/RandomUtils")
local Tags = require("@Enums/Tags")
type MapName = MapName.MapName

local LobbyTemplate = ReplicatedStorage.Assets.Models.Lobby

local LobbyService = {}
local LobbyRng = Random.new()

function LobbyService.OnStart()
	local lobbyObj = LobbyTemplate:Clone()
	lobbyObj.Parent = Workspace
end

--- Returns a random spawn location for the lobby.
function LobbyService.GetSpawnLocation(): Vector3
	local lobbySpawns = CollectionService:GetTagged(Tags.LobbySpawn)
	if #lobbySpawns == 0 then
		error("Attempted to get lobby spawn location, but no parts in Workspace have the LobbySpawn tag.")
	end

	local spawnPart = RandomUtils.RandomInArray(lobbySpawns, LobbyRng)
	if not spawnPart:IsA("BasePart") then
		error("Attempted to get lobby spawn location, but the selected LobbySpawn object is not a BasePart.")
	end

	-- TODO: Spawn in a random position inside the spawnPart, rather than in
	--  just the center of the part. This will help prevent players from
	--  spawning inside each other.
	local spawnPosition = spawnPart.Position + Vector3.new(0, 10, 0)

	return spawnPosition
end

function LobbyService.GetChosenMap(): MapName
	return MapName.Hill
end

return LobbyService
