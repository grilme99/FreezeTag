local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local TeamService = {}

function TeamService.OnInit()
	local taggerTeam = Instance.new("Team")
	taggerTeam.Name = "Tagger"
	taggerTeam.TeamColor = BrickColor.new("Bright red")
	taggerTeam.AutoAssignable = false
	taggerTeam.Parent = nil

	local runnerTeam = Instance.new("Team")
	runnerTeam.Name = "Runner"
	runnerTeam.TeamColor = BrickColor.new("Bright blue")
	runnerTeam.AutoAssignable = false
	runnerTeam.Parent = nil

	local lobbyTeam = Instance.new("Team")
	lobbyTeam.Name = "Lobby"
	lobbyTeam.TeamColor = BrickColor.new("Medium stone grey")
	lobbyTeam.AutoAssignable = true
	lobbyTeam.Parent = Teams

	TeamService.LobbyTeam = lobbyTeam
	TeamService.TaggerTeam = taggerTeam
	TeamService.RunnerTeam = runnerTeam
end

function TeamService.InitTeams()
	TeamService.TaggerTeam.Parent = Teams
	TeamService.RunnerTeam.Parent = Teams
end

function TeamService.SetPlayerTeam(player: Player, teamName: "Tagger" | "Runner")
	if teamName == "Tagger" then
		player.Team = TeamService.TaggerTeam
	elseif teamName == "Runner" then
		player.Team = TeamService.RunnerTeam
	end
end

function TeamService.GetPlayerTeam(player: Player): "Tagger" | "Runner" | "Lobby"
	if player.Team == TeamService.TaggerTeam then
		return "Tagger"
	elseif player.Team == TeamService.RunnerTeam then
		return "Runner"
	else
		return "Lobby"
	end
end

function TeamService.ResetTeams()
	for _, player in Players:GetPlayers() do
		player.Team = TeamService.LobbyTeam
	end

	TeamService.TaggerTeam.Parent = nil
	TeamService.RunnerTeam.Parent = nil
end

return TeamService
