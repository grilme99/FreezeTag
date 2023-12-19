export type Tag = "LobbySpawn" | "RunnerSpawn" | "TaggerSpawn" | "PlayerCharacter"

--- List of defined CollectionService tags.
local Tags = table.freeze({
	LobbySpawn = "LobbySpawn" :: Tag,
	RunnerSpawn = "RunnerSpawn" :: Tag,
	TaggerSpawn = "TaggerSpawn" :: Tag,

	PlayerCharacter = "PlayerCharacter" :: Tag,
})

return Tags
