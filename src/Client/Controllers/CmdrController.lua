local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cmdr is a pretty icky in terms of setup and command replication. We have to
-- import CmdrClient dynamically and lose all types/autocomplete as a result.
local CmdrClient = require(ReplicatedStorage:WaitForChild("CmdrClient")) :: any

local CmdrController = {}

function CmdrController.OnStart()
	CmdrClient:SetActivationKeys({ Enum.KeyCode.F2 })
	CmdrClient:SetPlaceName("Freeze Tag")
end

return CmdrController
