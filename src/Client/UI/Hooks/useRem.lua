local Workspace = game:GetService("Workspace")

local React = require("@Packages/React")

local useProperty = require("@Hooks/useProperty")

local useMemo = React.useMemo
local useCallback = React.useCallback

local BASE_REM = 16
local MIN_REM = 10
-- This is the resolution that UI is designed at.
local BASE_RESOLUTION = Vector2.new(900, 750)
local DOMINANT_AXIS = 0.5

--- `useRem` is a React hook for scaling values based on viewport size. It returns a function to
--- scale values based on the current REM size.
---
--- ### Scaling modes:
--- - `scale`: This mode is used when the value needs to maintain a consistent proportion relative
---		to the base REM size, regardless of the actual viewport size. It is useful for scaling
---		values that need to adjust dynamically with screen size but maintain their relative sizing.
---		For example, if you want an element's size to grow or shrink in a responsive design, keeping
---		the same proportion to the base screen size, you would use this mode.
---
--- - `unit`: This mode is used for direct scaling based on the current REM size. It's suitable for
---		defining sizes (like margins, paddings, or font sizes) that need to scale directly with
---		changes in the viewport size. It ensures that the sizing is consistent with the dynamic
---		REM size, providing a more straightforward approach to responsive design elements.
---
--- @param value number The value to be scaled.
--- @param mode_ `scale` | `unit` | `nil` Determines the scaling mode.
--- @return number The scaled value.
local function useRem()
	local camera: Camera = useProperty(Workspace, "CurrentCamera")
	local viewportSize: Vector2 = useProperty(camera, "ViewportSize")

	local rem = useMemo(function()
		local width = math.log(viewportSize.X / BASE_RESOLUTION.X, 2)
		local height = math.log(viewportSize.Y / BASE_RESOLUTION.Y, 2)
		local centered = width + (height - width) * DOMINANT_AXIS

		return math.max(BASE_REM * math.pow(2, centered), MIN_REM)
	end, { viewportSize })

	return useCallback(function(value: number, mode_: "scale" | "unit" | nil)
		local mode = mode_ or "scale"
		return if mode == "unit" then value * rem else value * (rem / BASE_REM)
	end, { rem })
end

return useRem
