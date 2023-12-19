local Players = game:GetService("Players")

local Log = require("@Packages/Log").new()
local Signal = require("@Packages/Signal")

local PermissionService = require("@Services/PermissionService")
local RoundService = require("@Services/RoundService")

local FreezeTagPlayer = require("@Server/Classes/Player")
export type FreezeTagPlayer = FreezeTagPlayer.FreezeTagPlayer

type Array<T> = { T }
type Map<K, V> = { [K]: V }

local PlayerService = {}
PlayerService.OnPlayerAdded = Signal.new() :: Signal.Signal<FreezeTagPlayer>

local PlayerClasses = {} :: Map<Player, FreezeTagPlayer>

local function OnPlayerAdded(player: Player)
	Log:AtInfo():Log(`Player {player.Name} has joined the game.`)

	local freezeTagPlayer = FreezeTagPlayer.new(player)
	PlayerClasses[player] = freezeTagPlayer

	local function loadCharacter()
		freezeTagPlayer:LoadCharacterAsync({
			-- The character will always be spawned in the lobby during this
			-- loop, since the player has just joined the game or has just died.
			destination = "lobby",
		})
	end
	task.delay(1, loadCharacter)

	local function onCharacterAdded(character: Model)
		local humanoid = character:WaitForChild("Humanoid")

		if humanoid and humanoid:IsA("Humanoid") then
			humanoid.Died:Connect(function()
				-- Setting the player's character to nil matches behavior from
				-- the default player spawn loop and suppresses warnings from
				-- the character controller scripts.
				player.Character = nil

				task.delay(1, function()
					character:Destroy()
					loadCharacter()
				end)
			end)
		else
			Log:AtWarning():Log(`Character model {character.Name} does not have a Humanoid instance.`)
		end
	end

	player.CharacterAdded:Connect(onCharacterAdded)

	if PermissionService.IsPlayerDeveloper(player) then
		player:SetAttribute("IsDeveloper", true)
	end

	PlayerService.OnPlayerAdded:Fire(freezeTagPlayer)
end

local function OnPlayerRemoving(player: Player)
	Log:AtInfo():Log(`Player {player.Name} has left the game.`)

	local playerClass = PlayerService.GetPlayer(player)
	playerClass:Destroy()

	PlayerClasses[player] = nil
end

function PlayerService.OnInit()
	Players.PlayerAdded:Connect(OnPlayerAdded)
	Players.PlayerRemoving:Connect(OnPlayerRemoving)
end

function PlayerService.OnStart()
	-- Respawn players when the round stage changes
	RoundService.OnRoundStageChanged:Connect(function(newRoundStage)
		task.wait(1)

		for _, playerClass in pairs(PlayerClasses) do
			if newRoundStage == "Intermission" and playerClass.currentCharacterLocation == "lobby" then
				continue
			end

			playerClass:LoadCharacterAsync({
				destination = if newRoundStage == "Intermission" then "lobby" else "game",
			})
		end
	end)
end

--- Returns an array of all players who have been allocated a FreezeTagPlayer
--- class.
function PlayerService.GetPlayers(): Array<FreezeTagPlayer>
	local players = {} :: Array<FreezeTagPlayer>

	for _, playerClass in PlayerClasses do
		table.insert(players, playerClass)
	end

	return players
end

--- Returns the FreezeTagPlayer class for the given player. This function will
--- error if the player does not have a FreezeTagPlayer class, but this should
--- not be possible unless the method is called after the player has left the
--- game.
function PlayerService.GetPlayer(player: Player): FreezeTagPlayer
	return assert(
		PlayerClasses[player],
		`Attempted to get player {player.Name}, but they do not have a FreezeTagPlayer class.`
	)
end

return PlayerService
