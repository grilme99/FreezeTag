export type Transition = (newRound: "Intermission" | "RunningGame") -> ()

export type RoundStageStatics = {
	__index: RoundStage,
	new: (transition: Transition) -> RoundStage,
}

export type RoundStage = {
	--- Programmatic name of the round.
	--- WARNING: This is not displayed to clients directly! Round names are
	---  localized, and this is used as a key to look up the localized name.
	roundName: string,

	--- Debug name of the client, used in logs
	debugName: string,

	--- Executed every heartbeat to tick the round stage forward.
	OnTick: (self: RoundStage, dt: number) -> (),

	--- Returns a location to spawn a player. If nil, the player will be spawned
	--- in the lobby.
	GetSpawnLocation: (self: RoundStage, player: Player) -> Vector3?,

	--- Clean up artifacts created by this round stage when it is ended.
	Destroy: (self: RoundStage) -> (),
}

return nil
