--- This module is used to avoid circular dependencies between controllers on
--- the client by storing all signals here.

local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

local ClientSignals = {}

ClientSignals.OnRoundChanged = Signal.new() :: Signal<boolean>
ClientSignals.OnTeamChanged = Signal.new() :: Signal<"Tagger" | "Runner" | "Lobby">

return ClientSignals
