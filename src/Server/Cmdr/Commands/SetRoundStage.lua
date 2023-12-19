return {
	Name = "set_round_stage",
	Aliases = {},
	Description = "Transitions the server to a new round stage",
	Group = "Admin",
	Args = {
		{
			Type = "roundStage",
			Name = "Round Stage",
			Description = "The round stage to transition to",
		},
	},
}
