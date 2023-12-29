local PhysicsService = game:GetService("PhysicsService")

local Log = require("@Packages/Log").new()

local CollisionGroup = require("@Enums/CollisionGroup")
local ServerSignals = require("@Server/ServerSignals")

local CollisionService = {}

function CollisionService.OnInit()
	PhysicsService:RegisterCollisionGroup(CollisionGroup.PlayerCharacter)
	PhysicsService:RegisterCollisionGroup(CollisionGroup.TagQuery)

	PhysicsService:CollisionGroupSetCollidable(CollisionGroup.Default, CollisionGroup.TagQuery, false)
	PhysicsService:CollisionGroupSetCollidable(CollisionGroup.PlayerCharacter, CollisionGroup.TagQuery, true)

	Log:AtDebug():Log("Registered collision groups")
end

function CollisionService.OnStart()
	ServerSignals.OnCharacterAdded:Connect(function(_, character)
		local rootPart = character.characterModel:WaitForChild("HumanoidRootPart") :: BasePart
		rootPart.CollisionGroup = CollisionGroup.PlayerCharacter

		Log:AtDebug():Log(`Set collision group of {character.characterModel} to {CollisionGroup.PlayerCharacter}`)
	end)
end

return CollisionService
