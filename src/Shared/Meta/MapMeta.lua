local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maps = ReplicatedStorage.Assets.Maps

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

local MapMeta: Map<string, MapEntry> = {}

MapMeta.Crossroads = {
	mapName = "crossroads",
	debugName = "Crossroads",
	mapRef = Maps.Crossroads,
}

return MapMeta
