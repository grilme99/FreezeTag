local RunService = game:GetService("RunService")

local Log = require("@Packages/Log").new()
local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

local LobbyService = require("@Services/LobbyService")

local RoundStageTypes = require("@Server/RoundStage/Types")
type RoundStageStatics = RoundStageTypes.RoundStageStatics
type RoundStage = RoundStageTypes.RoundStage

local CachedIntermission
local CachedRunningGame

local RoundService = {}
RoundService.CurrentRoundStage = nil :: RoundStage?
RoundService.OnRoundStageChanged = Signal.new() :: Signal<"Intermission" | "RunningGame">

function RoundService.OnStart()
	RunService.Heartbeat:Connect(RoundService.Tick)
	RoundService.TransitionStage("Intermission")
end

function RoundService.TransitionStage(newRoundClass: "Intermission" | "RunningGame")
	-- Note: We use require() here to avoid circular dependencies.
	if not CachedIntermission then
		CachedIntermission = require("@Server/RoundStage/Intermission")
	end
	if not CachedRunningGame then
		CachedRunningGame = require("@Server/RoundStage/RunningGame")
	end

	local Intermission = CachedIntermission
	local RunningGame = CachedRunningGame

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
