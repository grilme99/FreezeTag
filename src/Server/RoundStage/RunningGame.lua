local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Log = require("@Packages/Log").new()

local LobbyService = require("@Services/LobbyService")
local TeamService = require("@Services/TeamService")

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
local HIDE_TIME = Duration.fromSecs(15)

local RunningGame = {}
RunningGame.__index = RunningGame

local GameRng = Random.new()

local function assignPlayerTeams()
	local shuffledPlayers = RandomUtils.ShuffleArray(Players:GetPlayers(), GameRng)

	local taggerCount = 1 -- math.ceil(#shuffledPlayers / 4)
	local taggers = table.create(taggerCount)
	for i = 1, taggerCount do
		taggers[i] = shuffledPlayers[i]
	end

	local runners = table.create(#shuffledPlayers - taggerCount)
	for i = 1, #runners do
		runners[i] = shuffledPlayers[i + taggerCount]
	end

	return taggers, runners
end

local function getFilteredSpawns(tag: string, mapObj: Instance)
	local spawns = CollectionService:GetTagged(tag)

	local filteredSpawns = {}
	for _, spawnPart in ipairs(spawns) do
		if spawnPart:IsDescendantOf(mapObj) then
			table.insert(filteredSpawns, spawnPart)
		end
	end

	if #filteredSpawns == 0 then
		error(`Attempted to get match spawn location, but no parts have the {tag} tag`)
	end

	return filteredSpawns
end

function RunningGame.new(transition: Transition)
	local self = setmetatable({}, RunningGame)

	self.transition = transition
	self.startedAt = os.time()

	self.taggersReleasedAt = self.startedAt + HIDE_TIME:asSecs()
	self.taggersReleased = false

	self.roundName = "running_game"
	self.debugName = "Running Game"

	TeamService.InitTeams()

	local taggers, runners = assignPlayerTeams()
	for _, tagger in taggers do
		TeamService.SetPlayerTeam(tagger, "Tagger")
	end
	for _, runner in runners do
		TeamService.SetPlayerTeam(runner, "Runner")
	end

	self.taggers = taggers
	self.runners = runners

	local chosenMap: MapName = LobbyService.GetChosenMap()
	local mapData = assert(MapMeta[chosenMap], `Map data for map "{chosenMap}" not found`)

	local mapRef =
		assert(ServerStorage.Assets.Maps:FindFirstChild(mapData.mapName), `Map "{mapData.mapName}" not found`)

	self.mapObj = mapRef:Clone()
	self.mapObj.Parent = workspace

	-- Cache match spawns now so that we don't have to make expensive queries
	-- every player spawn.
	self.runnerSpawns = getFilteredSpawns(Tags.RunnerSpawn, self.mapObj)
	self.taggerSpawns = getFilteredSpawns(Tags.TaggerSpawn, self.mapObj)

	Workspace:SetAttribute("RoundName", self.roundName)
	Workspace:SetAttribute("RoundStage", self.debugName)
	Workspace:SetAttribute("TaggersReleasedAt", self.taggersReleasedAt)
	Workspace:SetAttribute("RoundEndTime", self.startedAt + GAME_LENGTH:asSecs())

	return self
end

export type RunningGame = RoundStage & typeof(RunningGame.new(...))

function RunningGame.OnTick(self: RunningGame)
	local now = os.time()
	local elapsedTime = now - self.startedAt

	-- Release seekers if they haven't been released yet
	if not self.taggersReleased and now >= self.taggersReleasedAt then
		self.taggersReleased = true

		Log:AtInfo():Log("Releasing taggers from tagger spawn")

		local seekerDoor = self.mapObj:FindFirstChild("TaggerDoor")
		if seekerDoor then
			seekerDoor:Destroy()
		end
	end

	if elapsedTime < GAME_LENGTH:asSecs() then
		return
	end

	Log:AtInfo():Log("Round over, transitioning to intermission")
	self.transition("Intermission")
end

function RunningGame.GetSpawnLocation(self: RunningGame, player: Player)
	local role = TeamService.GetPlayerTeam(player)
	local spawnGroup = if role == "Tagger" then self.taggerSpawns else self.runnerSpawns

	local spawnPart = RandomUtils.RandomInArray(spawnGroup, GameRng)
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
	Workspace:SetAttribute("TaggersReleasedAt", nil)
	Workspace:SetAttribute("RoundEndTime", nil)

	TeamService.ResetTeams()

	-- Give all players a chance to teleport back to the lobby
	task.delay(3, function()
		self.mapObj:Destroy()
	end)
end

return (RunningGame :: any) :: RoundStageStatics
