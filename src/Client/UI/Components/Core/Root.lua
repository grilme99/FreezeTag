local Players = game:GetService("Players")

local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local e = React.createElement

local function Root(props: React.ElementProps<ScreenGui>)
	local element = e("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	}, props.children)

	local container = Players.LocalPlayer.PlayerGui
	return ReactRoblox.createPortal(element, container)
end

return React.memo(Root)
