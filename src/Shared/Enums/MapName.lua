export type MapName = "Castle" | "Hill" | "Temple" | "Cuba"

--- List of defined map names.
local MapName = table.freeze({
	Castle = "Castle" :: MapName,
	Hill = "Hill" :: MapName,
	Temple = "Temple" :: MapName,
	Cuba = "Cuba" :: MapName,
})

return MapName
