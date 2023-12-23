return {
	Name = "unfreeze_player",
	Aliases = { "thaw_player" },
	Description = "Thaws a player character in ice",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "Target",
			Description = "The player to thaw",
		},
	},
}
