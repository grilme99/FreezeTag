local Workspace = game:GetService("Workspace")

local React = require("@Packages/React")

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

		MatchStatus = e("TextLabel", {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Text = roundStage or "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = rem(42),
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			TextGradient = e("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(112, 189, 240)),
				}),
			}),

			Stroke = e("UIStroke", {
				Thickness = rem(2),
				Color = Color3.fromRGB(112, 189, 240),
			}),
		}),

		Duration = e("TextLabel", {
			LayoutOrder = 2,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			Text = formattedTimeRemaining,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = rem(28),
			TextXAlignment = Enum.TextXAlignment.Center,
		}, {
			TextGradient = e("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(112, 189, 240)),
				}),
			}),

			Stroke = e("UIStroke", {
				Thickness = rem(2),
				Color = Color3.fromRGB(112, 189, 240),
			}),
		}),
	})
end

return MatchStatus
