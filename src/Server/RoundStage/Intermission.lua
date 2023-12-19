local Workspace = game:GetService("Workspace")

local Log = require("@Packages/Log").new()

local LobbyService = require("@Services/LobbyService")

local Duration = require("@Shared/Utils/Duration")

local Types = require("./Types")
type RoundStageStatics = Types.RoundStageStatics
type RoundStage = Types.RoundStage
type Transition = Types.Transition

local INTERMISSION_LENGTH = Duration.fromSecs(10)

local Intermission = {}
Intermission.__index = Intermission

function Intermission.new(transition: Transition)
	local self = setmetatable({}, Intermission)

	self.transition = transition
	self.startedAt = os.time()

	self.roundName = "intermission"
	self.debugName = "Intermission"

	Workspace:SetAttribute("RoundName", self.roundName)
	Workspace:SetAttribute("RoundStage", self.debugName)
	Workspace:SetAttribute("IntermissionEndTime", self.startedAt + INTERMISSION_LENGTH:asSecs())

	return self
end

export type Intermission = RoundStage & typeof(Intermission.new(...))

function Intermission.OnTick(self: Intermission)
	local now = os.time()
	local elapsedTime = now - self.startedAt

	if elapsedTime < INTERMISSION_LENGTH:asSecs() then
		return
	end

	Log:AtInfo():Log("Intermission over, transitioning to next round")

	self.transition("RunningGame")
end

function Intermission.GetSpawnLocation(_self: Intermission, _player: Player)
	return LobbyService.GetSpawnLocation()
end

function Intermission.Destroy(_self: Intermission)
	Workspace:SetAttribute("RoundName", nil)
	Workspace:SetAttribute("RoundStage", nil)
	Workspace:SetAttribute("IntermissionEndTime", nil)
end

return (Intermission :: any) :: RoundStageStatics
