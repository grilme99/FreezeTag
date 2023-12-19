local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Log = require("@Packages/Log").new()

local Duration = require("@Utils/Duration")
local RandomUtils = require("@Utils/RandomUtils")

local MapMeta = require("@Meta/MapMeta")

local MapName = require("@Enums/MapName")
local Tags = require("@Enums/Tags")
type MapName = MapName.MapName

local Types = require("./Types")
type RoundStageStatics = Types.RoundStageStatics
type RoundStage = Types.RoundStage
type Transition = Types.Transition

local GAME_LENGTH = Duration.fromSecs(120)

local RunningGame = {}
RunningGame.__index = RunningGame

local GameRng = Random.new()

function RunningGame.new(transition: Transition)
	local self = setmetatable({}, RunningGame)

	self.transition = transition
	self.startedAt = os.time()

	self.roundName = "running_game"
	self.debugName = "Running Game"

	local chosenMap: MapName = assert(Workspace:GetAttribute("ChosenMap"), "ChosenMap attribute not set")
	local mapData = assert(MapMeta[chosenMap], `Map data for map "{chosenMap}" not found`)

	-- Note: We don't clone the map instance to save memory on the server and
	-- clients. This means that the map instance can be modified in-place, which
	-- is a risk. Any changes made to the map during a round will persist into
	-- the later rounds.
	self.mapObj = mapData.mapRef
	self.mapObjOriginalParent = self.mapObj.Parent

	self.mapObj.Parent = workspace

	-- Cache match spawns now so that we don't have to make expensive queries
	-- every player spawn.
	local matchSpawns = CollectionService:GetTagged(Tags.MatchSpawn)
	if #matchSpawns == 0 then
		error("Attempted to get match spawn location, but no parts in Workspace have the MatchSpawn tag.")
	end

	-- Filter `matchSpawns` to only include spawns for our chosen map
	local ourMatchSpawns = {}
	for _, spawnPart in ipairs(matchSpawns) do
		if spawnPart:IsDescendantOf(self.mapObj) then
			table.insert(ourMatchSpawns, spawnPart)
		end
	end

	self.matchSpawns = ourMatchSpawns

	Workspace:SetAttribute("RoundName", self.roundName)
	Workspace:SetAttribute("RoundStage", self.debugName)
	Workspace:SetAttribute("GameEndTime", self.startedAt + GAME_LENGTH:asSecs())

	return self
end

export type RunningGame = RoundStage & typeof(RunningGame.new(...))

function RunningGame.OnTick(self: RunningGame)
	local now = os.time()
	local elapsedTime = now - self.startedAt

	if elapsedTime < GAME_LENGTH:asSecs() then
		return
	end

	Log:AtInfo():Log("Round over, transitioning to intermission")
	self.transition("Intermission")
end

function RunningGame.GetSpawnLocation(self: RunningGame, _player: Player)
	local spawnPart = RandomUtils.RandomInArray(self.matchSpawns, GameRng)
	if not spawnPart:IsA("BasePart") then
		error("Attempted to get match spawn location, but the selected MatchSpawn object is not a BasePart.")
	end

	-- TODO: Spawn in a random position inside the spawnPart, rather than in
	--  just the center of the part. This will help prevent players from
	--  spawning inside each other.
	local spawnPosition = spawnPart.Position + Vector3.new(0, 10, 0)

	return spawnPosition
end

function RunningGame.Destroy(self: RunningGame)
	Workspace:SetAttribute("RoundName", nil)
	Workspace:SetAttribute("RoundStage", nil)
	Workspace:SetAttribute("GameEndTime", nil)

	-- Give all players a chance to teleport back to the lobby
	task.delay(5, function()
		self.mapObj.Parent = self.mapObjOriginalParent
	end)
end

return (RunningGame :: any) :: RoundStageStatics
