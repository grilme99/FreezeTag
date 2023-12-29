local RunService = game:GetService("RunService")

local Component = require("@Packages/Component")

local Tags = require("@Enums/Tags")

local DebugPart = Component.new({
	Tag = Tags.DebugPart,
	Ancestors = { workspace },
})

function DebugPart:Construct()
	local obj = self.Instance :: BasePart
	obj.CanCollide = false
	obj.CanTouch = false
	obj.CanQuery = false
	obj.Anchored = true

	if RunService:IsStudio() then
		obj.Transparency = 0.8
	else
		obj.Transparency = 1
	end
end

return DebugPart
