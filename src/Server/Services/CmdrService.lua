--!nocheck

local Cmdr = require("@ServerPackages/Cmdr")

local PermissionService = require("@Services/PermissionService")

local CmdrService = {}

function CmdrService.OnStart()
	Cmdr:RegisterDefaultCommands()

	Cmdr.Registry:RegisterHook("BeforeRun", function(context)
		local executor = context.Executor
		if not PermissionService.IsPlayerDeveloper(executor) then
			return "You do not have permission to run this command."
		end

		return nil
	end)
end

return CmdrService
