local Log = require("@Packages/Log").new()

local RoundService = require("@Services/RoundService")

return function(context, newRoundStage: string)
	Log:AtInfo():Log(`User {context.Executor.Name} set the round stage to {newRoundStage}`)
	RoundService.TransitionStage(newRoundStage :: any)
end
