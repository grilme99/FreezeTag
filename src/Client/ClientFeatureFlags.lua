local RunService = game:GetService("RunService")

local ClientFeatureFlags = {}

ClientFeatureFlags.ShowDebugGizmos = RunService:IsStudio()

return ClientFeatureFlags
