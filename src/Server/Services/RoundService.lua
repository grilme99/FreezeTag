local RunService = game:GetService("RunService")

local Log = require("@Packages/Log").new()
local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

local LobbyService = require("@Services/LobbyService")

local Intermission = require("@Server/RoundStage/Intermission")
local RunningGame = require("@Server/RoundStage/RunningGame")

local RoundStageTypes = require("@Server/RoundStage/Types")
type RoundStageStatics = RoundStageTypes.RoundStageStatics
type RoundStage = RoundStageTypes.RoundStage

local RoundService = {}
RoundService.CurrentRoundStage = nil :: RoundStage?
RoundService.OnRoundStageChanged = Signal.new() :: Signal<"Intermission" | "RunningGame">

function RoundService.OnStart()
	RunService.Heartbeat:Connect(RoundService.Tick)
	RoundService.TransitionStage("Intermission")
end

function RoundService.TransitionStage(newRoundClass: "Intermission" | "RunningGame")
	local roundClass = if newRoundClass == "Intermission" then Intermission else RunningGame
	local newRound = roundClass.new(RoundService.TransitionStage)

	Log:AtInfo():Log(`Transitioning to new round stage: {newRound.debugName}`)

	if RoundService.CurrentRoundStage then
		Log:AtDebug():Log(`Destroying old round stage: {RoundService.CurrentRoundStage.debugName}`)
		RoundService.CurrentRoundStage:Destroy()
	end

	RoundService.CurrentRoundStage = newRound
end

function RoundService.GetSpawnLocation(player: Player): Vector3
	local function getFallbackLocation()
		return LobbyService.GetSpawnLocation()
	end

	if RoundService.CurrentRoundStage then
		local location = RoundService.CurrentRoundStage:GetSpawnLocation(player)
		return location or getFallbackLocation()
	else
		return getFallbackLocation()
	end
end

function RoundService.Tick(dt: number)
	if RoundService.CurrentRoundStage then
		RoundService.CurrentRoundStage:OnTick(dt)
	end
end

return RoundService
