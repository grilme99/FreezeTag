local MapName = require("@Enums/MapName")
type MapName = MapName.MapName

export type MapEntry = {
	--- Programmatic name of the map.
	--- WARNING: This is not displayed to clients directly! Map names are
	---  localized, and this is used as a key to look up the localized name.
	mapName: string,
	--- Debug name of the client, used in logs.
	debugName: string,
}

type Map<K, V> = { [K]: V }

local MapMeta: Map<MapName, MapEntry> = {}

MapMeta[MapName.Castle] = {
	mapName = "castle",
	debugName = "Castle",
}

MapMeta[MapName.Hill] = {
	mapName = "hill",
	debugName = "Hill",
}

MapMeta[MapName.Temple] = {
	mapName = "temple",
	debugName = "Temple",
}

MapMeta[MapName.Cuba] = {
	mapName = "cuba",
	debugName = "Cuba",
}

return MapMeta
