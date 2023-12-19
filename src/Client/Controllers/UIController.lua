local RunService = game:GetService("RunService")

local DEV = RunService:IsStudio()
if DEV then
	-- Enables React dev mode, must be set before initial import of React
	_G.__DEV__ = true
end

local Log = require("@Packages/Log").new()
local React = require("@Packages/React")
local ReactRoblox = require("@Packages/ReactRoblox")

local UIRoot = require("@UI/UIRoot")

local e = React.createElement

local UIController = {}

function UIController.OnStart()
	local root = ReactRoblox.createRoot(Instance.new("Folder"))

	local element = if DEV
		then e(React.StrictMode, {}, {
			e(UIRoot, {}),
		})
		else e(UIRoot, {})

	root:render(element)

	Log:AtDebug():Log("Mounted React UI root")
end

return UIController
