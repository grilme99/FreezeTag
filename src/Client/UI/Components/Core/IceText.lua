local React = require("@Packages/React")

local useRem = require("@Hooks/useRem")

local e = React.createElement

export type Props = React.ElementProps<TextLabel> & {
	anchorPoint: Vector2?,
	position: UDim2?,
	size: UDim2?,
	automaticSize: Enum.AutomaticSize?,

	text: string,
	textSize: number?,

	layoutOrder: number?,
}

local function IceText(props: Props)
	local rem = useRem()

	return e("TextLabel", {
		AnchorPoint = props.anchorPoint,
		Position = props.position,
		Size = props.size,
		AutomaticSize = props.automaticSize,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		Text = props.text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = props.textSize or rem(12),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		LayoutOrder = props.layoutOrder,
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
	}, props.children)
end

return React.memo(IceText)
