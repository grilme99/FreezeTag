local Duration = {}
Duration.__index = Duration

--- Creates a new `Duration` from the specified number of whole seconds and
--- additional nanoseconds.
---
--- If the number of nanoseconds is greater than 1 billion (the number of
--- nanoseconds in a second), then it will carry over into the seconds provided.
function Duration.new(secs: number, nanos: number)
	local self = setmetatable({}, Duration)
	self.secs = secs
	self.nanos = nanos
	return self
end

export type Duration = typeof(Duration.new(...))

--- Creates a new `Duration` from the specified number of whole seconds.
function Duration.fromSecs(secs: number): Duration
	return Duration.new(secs, 0)
end

--- Creates a new `Duration` from the specified number of milliseconds.
function Duration.fromMillis(millis: number): Duration
	return Duration.new(millis / 1000, (millis % 1000) * 1000000)
end

--- Creates a new `Duration` from the specified number of microseconds.
function Duration.fromMicros(micros: number): Duration
	return Duration.new(micros / 1000000, (micros % 1000000) * 1000)
end

--- Creates a new `Duration` from the specified number of nanoseconds.
function Duration.fromNanos(nanos: number): Duration
	return Duration.new(nanos / 1000000000, nanos % 1000000000)
end

--- Returns true if this `Duration` spans no time.
function Duration.isZero(self: Duration): boolean
	return self.secs == 0 and self.nanos == 0
end

--- Returns the number of seconds contained by this `Duration`.
function Duration.asSecs(self: Duration): number
	return self.secs + self.nanos / 1000000000
end

--- Returns the fractional part of this `Duration`, in whole milliseconds.
---
--- This method does **not** return the length of the duration when represented
--- by milliseconds. The returned number always represents a fractional
--- portion of a second (i.e., it is less than one thousand).
function Duration.subsecMillis(self: Duration): number
	return self.nanos / 1000000
end

--- Returns the fractional part of this `Duration`, in whole microseconds.
---
--- This method does **not** return the length of the duration when represented
--- by microseconds. The returned number always represents a fractional
--- portion of a second (i.e., it is less than one million).
function Duration.subsecMicros(self: Duration): number
	return self.nanos / 1000
end

--- Returns the fractional part of this `Duration`, in whole nanoseconds.
---
--- This method does **not** return the length of the duration when represented
--- by nanoseconds. The returned number always represents a fractional
--- portion of a second (i.e., it is less than one billion).
function Duration.subsecNanos(self: Duration): number
	return self.nanos
end

--- Returns the total number of whole milliseconds contained by this `Duration`.
function Duration.asMillis(self: Duration): number
	return self.secs * 1000 + self.nanos / 1000000
end

--- Returns the total number of whole microseconds contained by this `Duration`.
function Duration.asMicros(self: Duration): number
	return self.secs * 1000000 + self.nanos / 1000
end

--- Returns the total number of whole nanoseconds contained by this `Duration`.
function Duration.asNanos(self: Duration): number
	return self.secs * 1000000000 + self.nanos
end

return Duration
