local Log = require("@Packages/Log").new()

local ClientRoot = script:FindFirstAncestor("Client")
local Components: Folder = ClientRoot.Components

local ComponentsController = {}

function ComponentsController.OnStart()
	for _, componentModule in Components:GetDescendants() do
		if not componentModule:IsA("ModuleScript") then
			continue
		end

		local _ = require(componentModule) :: any

		Log:AtTrace():Log(`Loaded component ${componentModule.Name}`)
	end
end

return ComponentsController
