export type CollisionGroup = "Default" | "PlayerCharacter" | "TagQuery"

local CollisionGroup = table.freeze({
	Default = "Default" :: CollisionGroup,

	TagQuery = "TagQuery" :: CollisionGroup,
	PlayerCharacter = "PlayerCharacter" :: CollisionGroup,
})

return CollisionGroup
