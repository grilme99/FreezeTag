local ServerStorage = game:GetService("ServerStorage")

local Loader = require("@Packages/Loader")
local Log = require("@Packages/Log").new()

local Services = ServerStorage.Server.Services
local LoadedModules = Loader.LoadDescendants(Services, Loader.MatchesName("Service$"))

Loader.SpawnAll(LoadedModules, "OnInit")
Loader.SpawnAll(LoadedModules, "OnStart")

Log:AtInfo():Log("Loaded all server services")
