local Workspace = game:GetService("Workspace")

local React = require("@Packages/React")

local IceText = require("@Components/Core/IceText")

local useAttribute = require("@Hooks/useAttribute")
local useCurrentTime = require("@Hooks/useCurrentTime")
local useRem = require("@Hooks/useRem")

local e = React.createElement

local function MatchStatus()
	local rem = useRem()

	local currentTime = useCurrentTime({ updateFrequency = 1 })

	local roundStage = useAttribute(Workspace, "RoundStage")
	local roundEndTime = useAttribute(Workspace, "RoundEndTime") or currentTime

	local timeRemaining = roundEndTime - currentTime
	local formattedTimeRemaining = string.format("%02d:%02d", timeRemaining / 60, timeRemaining % 60)

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, rem(8)),
		Size = UDim2.fromScale(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		ListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, rem(8)),
		}),

		MatchStatus = e(IceText, {
			layoutOrder = 1,
			automaticSize = Enum.AutomaticSize.XY,
			text = roundStage or "",
			textSize = rem(42),
		}),

		Duration = e(IceText, {
			layoutOrder = 2,
			automaticSize = Enum.AutomaticSize.XY,
			text = formattedTimeRemaining,
			textSize = rem(28),
		}),
	})
end

return MatchStatus
