local Character = require("./Character")
type Character = Character.Character

local LobbyService = require("@Services/LobbyService")
local RoundService = require("@Services/RoundService")

local ServerSignals = require("@Server/ServerSignals")

local DEFAULT_CHARACTER_HEIGHT = 5

local FreezeTagPlayer = {}
FreezeTagPlayer.__index = FreezeTagPlayer

function FreezeTagPlayer.new(player: Player)
	local self = setmetatable({}, FreezeTagPlayer)

	self.player = player
	self.character = nil :: Character?

	self.currentCharacterLocation = nil :: "lobby" | "game" | nil

	return self
end

export type FreezeTagPlayer = typeof(FreezeTagPlayer.new(...))

export type LoadCharacterOptions = {
	--- Where the character should be spawned. If `nil`, the character will be
	--- spawned in the lobby. If `game`, the character will be spawned in the
	--- currently running match. If `game`, but no game is running, the
	--- character will be spawned in the lobby.
	destination: "lobby" | "game" | nil,
}

--- Loads the player's character and returns a character class. Note that this
--- function yields until the character is loaded and spawned in the world.
function FreezeTagPlayer.LoadCharacterAsync(self: FreezeTagPlayer, options: LoadCharacterOptions): Character
	local function getSpawnLocation(): Vector3
		if options.destination == "game" then
			-- Spawn the character in the current match. If there is no current
			-- match, spawn the character in the lobby. The fallback behavior
			-- is handled by `RoundService`.
			return RoundService.GetSpawnLocation(self.player)
		else
			return LobbyService.GetSpawnLocation()
		end
	end

	local spawnLocation = getSpawnLocation()
	self.player:LoadCharacter()

	local characterModel = self.player.Character or self.player.CharacterAdded:Wait()
	characterModel:PivotTo(CFrame.new(spawnLocation))

	local character = Character.new(characterModel)

	-- Normalize the character in a new thread. This will likely yield as it
	-- waits for the character parts to load in.
	task.spawn(character.NormalizeHeightAsync, character, DEFAULT_CHARACTER_HEIGHT)

	-- At this point, loading the new character was a success so we should
	-- destroy the old character if it exists.
	if self.character then
		self.character:Destroy()
	end

	self.character = character
	self.currentCharacterLocation = options.destination

	ServerSignals.OnCharacterAdded:Fire(self, character)

	local connection
	connection = character.destroying:Connect(function()
		connection:Destroy()
		self.character = nil
		self.currentCharacterLocation = nil
	end)

	return character
end

function FreezeTagPlayer.Destroy(self: FreezeTagPlayer)
	if self.character then
		self.character:Destroy()
	end
end

return FreezeTagPlayer
