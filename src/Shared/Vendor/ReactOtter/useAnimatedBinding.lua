--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Vendor = script.Parent.Parent

local React = require(Packages.React)
type Binding<T> = React.Binding<T>

local Otter = require(Vendor.Otter)
type Callback<T> = Otter.MotorCallback<T>

local useMotor = require(script.Parent.useMotor)
type SetGoal<G> = useMotor.SetGoal<G>

local function useAnimatedBinding<V, G>(
	initialValue: V,
	onComplete: Callback<V>?
): (Binding<V>, SetGoal<G>)
	local value, setValue = React.useBinding(initialValue)
	local setGoal = useMotor(initialValue, setValue, onComplete)

	return value, setGoal
end

return useAnimatedBinding
