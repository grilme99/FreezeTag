return function(registry)
	registry:RegisterType(
		"roundStage",
		registry.Cmdr.Util.MakeEnumType("roundStage", { "Intermission", "RunningGame" })
	)
end
