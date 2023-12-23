local Workspace = game:GetService("Workspace")

local React = require("@Packages/React")
local ReactOtter = require("@Vendor/ReactOtter/init")

local IceText = require("@Components/Core/IceText")

local useAttribute = require("@Hooks/useAttribute")
local useCurrentTime = require("@Hooks/useCurrentTime")
local useRem = require("@Hooks/useRem")

local useAnimatedBinding = ReactOtter.useAnimatedBinding

local e = React.createElement
local useEffect = React.useEffect

local function TaggerReleaseCountdown(): React.Node
	local rem = useRem()

	local currentTime = useCurrentTime({ updateFrequency = 1 })
	local taggersReleasedAt = useAttribute(Workspace, "TaggersReleasedAt")

	local timeRemaining = math.floor(taggersReleasedAt - currentTime)

	local textScale, setTextScale = useAnimatedBinding(1)
	useEffect(function()
		-- Impulse the text size when the countdown progresses
		local impulseAmount = if timeRemaining <= 5 then 1.5 else 1.3

		setTextScale(ReactOtter.instant(impulseAmount) :: any)
		task.delay(0, function()
			setTextScale(ReactOtter.spring(1, {
				frequency = 3,
				dampingRatio = 1,
			}))
		end)
	end, { timeRemaining })

	if timeRemaining < 0 then
		return nil
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, rem(-12)),
		Size = UDim2.fromScale(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		ListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, rem(8)),
		}),

		Title = e(IceText, {
			layoutOrder = 1,
			automaticSize = Enum.AutomaticSize.XY,
			text = "Taggers Released In:",
			textSize = rem(24),
		}),

		DurationWrapper = e("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromOffset(rem(50), rem(50)),
			BackgroundTransparency = 1,
		}, {
			Duration = e(IceText, {
				anchorPoint = Vector2.new(0.5, 0.5),
				position = UDim2.fromScale(0.5, 0.5),
				automaticSize = Enum.AutomaticSize.XY,
				text = timeRemaining,
				textSize = rem(42),
			}, {
				Scale = e("UIScale", {
					Scale = textScale,
				}),
			}),
		}),
	})
end

return TaggerReleaseCountdown
