local Log = require("@Packages/Log").new()

local TagService = require("@Services/TagService")

return function(context, target: Player)
	Log:AtInfo():Log(`User {context.Executor.Name} has unfrozen ${target.Name}`)
	TagService.UntagPlayer(target)
end
