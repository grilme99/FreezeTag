local React = require("@Packages/React")

local Root = require("@Components/Core/Root")

local MatchStatus = require("@Components/MatchStatus/init")

local e = React.createElement

local function UIRoot()
	return e(React.Fragment, {}, {
		MatchStatus = e(Root, {}, {
			UIRoot = e(MatchStatus, {}),
		}),
	})
end

return UIRoot
