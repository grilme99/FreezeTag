--- This module is used to avoid circular dependencies between services on the
--- server by storing all signals here.

local Signal = require("@Packages/Signal")
type Signal<T...> = Signal.Signal<T...>

local Character = require("@Server/Classes/Character")
type Character = Character.Character

-- Note: Can't import FreezeTagPlayer because it would cause a circular dependency.
type FreezeTagPlayer = any

local ServerSignals = {}

ServerSignals.OnPlayerAdded = Signal.new() :: Signal<FreezeTagPlayer>
ServerSignals.OnCharacterAdded = Signal.new() :: Signal<FreezeTagPlayer, Character>

ServerSignals.OnRoundStageChanged = Signal.new() :: Signal<"Intermission" | "RunningGame">

return ServerSignals
