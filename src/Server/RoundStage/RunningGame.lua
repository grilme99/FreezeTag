local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Log = require("@Packages/Log").new()

local Duration = require("@Utils/Duration")
local RandomUtils = require("@Utils/RandomUtils")

local Tags = require("@Enums/Tags")

local Types = require("./Types")
type RoundStageStatics = Types.RoundStageStatics
type RoundStage = Types.RoundStage
type Transition = Types.Transition

local GAME_LENGTH = Duration.fromSecs(5)

local RunningGame = {}
RunningGame.__index = RunningGame

local GameRng = Random.new()

function RunningGame.new(transition: Transition)
	local self = setmetatable({}, RunningGame)

	self.transition = transition
	self.startedAt = os.time()

	self.roundName = "running_game"
	self.debugName = "Running Game"

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

function RunningGame.GetSpawnLocation(_self: RunningGame, _player: Player)
	local matchSpawns = CollectionService:GetTagged(Tags.MatchSpawn)
	if #matchSpawns == 0 then
		error("Attempted to get match spawn location, but no parts in Workspace have the MatchSpawn tag.")
	end

	local spawnPart = RandomUtils.RandomInArray(matchSpawns, GameRng)
	if not spawnPart:IsA("BasePart") then
		error("Attempted to get match spawn location, but the selected MatchSpawn object is not a BasePart.")
	end

	-- TODO: Spawn in a random position inside the spawnPart, rather than in
	--  just the center of the part. This will help prevent players from
	--  spawning inside each other.
	local spawnPosition = spawnPart.Position + Vector3.new(0, 10, 0)

	return spawnPosition
end

function RunningGame.Destroy(_self: RunningGame)
	Workspace:SetAttribute("RoundName", nil)
	Workspace:SetAttribute("RoundStage", nil)
	Workspace:SetAttribute("GameEndTime", nil)
end

return (RunningGame :: any) :: RoundStageStatics
