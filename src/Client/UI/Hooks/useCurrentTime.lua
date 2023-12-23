local Workspace = game:GetService("Workspace")

local React = require("@Packages/React")

local useState = React.useState
local useRef = React.useRef

local function getTime()
	return Workspace:GetServerTimeNow()
end

export type Props = {
	--- How often to update the state, in seconds.
	updateFrequency: number?,
}

local function useCurrentTime(props: Props): number
	local updateFrequency = props.updateFrequency

	local currentTime, setCurrentTime = useState(getTime())
	local currentTimeRef = useRef(currentTime)

	React.useEffect(function()
		local connection = game:GetService("RunService").Heartbeat:Connect(function()
			local now = getTime()
			if updateFrequency and now - currentTimeRef.current < updateFrequency then
				return
			end

			setCurrentTime(getTime())
			currentTimeRef.current = now
		end)

		return function()
			connection:Disconnect()
		end
	end, { updateFrequency })

	return currentTime
end

return useCurrentTime
