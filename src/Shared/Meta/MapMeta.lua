local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maps = ReplicatedStorage.Assets.Maps

local MapName = require("@Enums/MapName")
type MapName = MapName.MapName

export type MapEntry = {
	--- Programmatic name of the map.
	--- WARNING: This is not displayed to clients directly! Map names are
	---  localized, and this is used as a key to look up the localized name.
	mapName: string,
	--- Debug name of the client, used in logs.
	debugName: string,

	--- Reference to the map instance in the DataModel.
	mapRef: Instance,
}

type Map<K, V> = { [K]: V }

local MapMeta: Map<MapName, MapEntry> = {}

MapMeta[MapName.Crossroads] = {
	mapName = "crossroads",
	debugName = "Crossroads",
	mapRef = Maps.Crossroads,
}

return MapMeta
