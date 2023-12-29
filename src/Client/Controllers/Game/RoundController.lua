local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Log = require("@Packages/Log").new()

local ClientSignals = require("@Client/ClientSignals")

export type Team = "Tagger" | "Runner" | "Lobby"

local RoundController = {}
RoundController.IsRoundRunning = false
RoundController.LocalPlayerTeam = "Lobby" :: Team

function RoundController.OnInit()
	local function reconcileRoundChange()
		local roundName = Workspace:GetAttribute("RoundName")
		local isRoundRunning = roundName == "running_game"

		RoundController.IsRoundRunning = isRoundRunning
		ClientSignals.OnRoundChanged:Fire(isRoundRunning)

		Log:AtInfo():Log(`Round changed to {roundName}`)
	end

	Workspace:GetAttributeChangedSignal("RoundName"):Connect(reconcileRoundChange)
	reconcileRoundChange()

	local player = Players.LocalPlayer
	local function reconcilePlayerTeamChange()
		local team = player.Team

		if team then
			RoundController.LocalPlayerTeam = team.Name
		else
			RoundController.LocalPlayerTeam = "Lobby"
		end

		ClientSignals.OnTeamChanged:Fire(RoundController.LocalPlayerTeam :: Team)
		Log:AtInfo():Log(`Local player team changed to {RoundController.LocalPlayerTeam}`)
	end

	player:GetPropertyChangedSignal("Team"):Connect(reconcilePlayerTeamChange)
	reconcilePlayerTeamChange()
end

return RoundController
