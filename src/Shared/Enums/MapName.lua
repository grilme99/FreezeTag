export type MapName = "Castle" | "Hill" | "Temple"

--- List of defined map names.
local MapName = table.freeze({
	Castle = "Castle" :: MapName,
	Hill = "Hill" :: MapName,
	Temple = "Temple" :: MapName,
})

return MapName
