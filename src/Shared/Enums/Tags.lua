export type Tag = "LobbySpawn" | "MatchSpawn" | "PlayerCharacter"

--- List of defined CollectionService tags.
local Tags = table.freeze({
	LobbySpawn = "LobbySpawn",
	MatchSpawn = "MatchSpawn",

	PlayerCharacter = "PlayerCharacter",
})

return Tags
