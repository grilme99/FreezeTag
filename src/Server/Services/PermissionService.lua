local PermissionService = {}

function PermissionService.IsPlayerDeveloper(player: Player)
	return player.UserId == 75380482
end

return PermissionService
