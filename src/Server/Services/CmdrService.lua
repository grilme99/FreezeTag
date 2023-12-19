--!nocheck

local Cmdr = require("@ServerPackages/Cmdr")
local Log = require("@Packages/Log").new()

local PermissionService = require("@Services/PermissionService")

local ServerRoot = script:FindFirstAncestor("Server")
local CmdrCommands = ServerRoot.Cmdr.Commands
local CmdrTypes = ServerRoot.Cmdr.Types

local CmdrService = {}

function CmdrService.OnStart()
	Cmdr:RegisterDefaultCommands()

	for _, module in CmdrCommands:GetDescendants() do
		if not module:IsA("ModuleScript") then
			continue
		end

		-- Cmdr commands are made up of two modules: a definition and an
		-- executor. The executor module is suffixed with "Server", so we skip
		-- any module whose name ends with "Server" here.
		if module.Name:match("Server$") then
			continue
		end

		local definitionModule = module
		local executorModule = CmdrCommands:FindFirstChild(`{module.Name}Server`)

		Cmdr.Registry:RegisterCommand(definitionModule, executorModule)
		Log:AtTrace():Log(`Registered command {definitionModule.Name}`)
	end

	Cmdr.Registry:RegisterTypesIn(CmdrTypes)

	Cmdr.Registry:RegisterHook("BeforeRun", function(context)
		local executor = context.Executor
		if not PermissionService.IsPlayerDeveloper(executor) then
			return "You do not have permission to run this command."
		end

		return nil
	end)
end

return CmdrService
