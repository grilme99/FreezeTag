local Workspace = game:GetService("Workspace")

local React = require("@Packages/React")

local Root = require("@Components/Core/Root")

local MatchStatus = require("@Components/MatchStatus")
local TaggerReleaseCountdown = require("@Components/TaggerReleaseCountdown")

local useAttribute = require("@Hooks/useAttribute")

local e = React.createElement

local function UIRoot()
	local taggersReleasedAt = useAttribute(Workspace, "TaggersReleasedAt")

	return e(React.Fragment, {}, {
		MatchStatus = e(Root, {}, {
			UIRoot = e(MatchStatus, {}),
		}),

		TaggerReleaseCountdown = taggersReleasedAt and e(Root, {}, {
			UIRoot = e(TaggerReleaseCountdown, {}),
		}),
	})
end

return UIRoot
