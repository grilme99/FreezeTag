local React = require("@Packages/React")

local useState = React.useState
local useEffect = React.useEffect

local function useAttribute(instance: Instance, attribName: string): any
	local attribValue, setAttribValue = useState(instance:GetAttribute(attribName))

	useEffect(function()
		local connection = instance:GetAttributeChangedSignal(attribName):Connect(function()
			setAttribValue(instance:GetAttribute(attribName))
		end)

		return function()
			connection:Disconnect()
		end
	end, { instance, attribName } :: { any })

	return attribValue
end

return useAttribute
