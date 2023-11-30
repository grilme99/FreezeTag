local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require("@Packages/Loader")

local Controllers = ReplicatedStorage.Client.Controllers
local LoadedModules = Loader.LoadDescendants(Controllers, Loader.MatchesName("Controller$"))

Loader.SpawnAll(LoadedModules, "OnInit")
Loader.SpawnAll(LoadedModules, "OnStart")
