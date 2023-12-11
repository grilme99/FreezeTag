local Workspace = game:GetService("Workspace")

local Log = require("@Packages/Log").new()

local Duration = require("@Shared/Utils/Duration")

local Types = require("./Types")
type RoundStageStatics = Types.RoundStageStatics
type RoundStage = Types.RoundStage
type Transition = Types.Transition

local GAME_LENGTH = Duration.fromSecs(5)

local RunningGame = {}
RunningGame.__index = RunningGame

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
	return Vector3.zero
end

function RunningGame.Destroy(_self: RunningGame)
	Workspace:SetAttribute("RoundName", nil)
	Workspace:SetAttribute("RoundStage", nil)
	Workspace:SetAttribute("GameEndTime", nil)
end

return (RunningGame :: any) :: RoundStageStatics
