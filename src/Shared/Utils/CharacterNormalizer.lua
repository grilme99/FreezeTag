--!nonstrict

-- https://gist.github.com/EgoMoose/95d00bed113a2503f4811284fd8a4d1a

--[[
MIT License
Copyright (c) 2021 EgoMoose
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

local function getObjectValue(parent, name, default)
	local found = parent:FindFirstChild(name)
	if found then
		return found.Value
	end
	return default
end

local function matchHeadToMesh(head, headMesh)
	for _, child in pairs(head:GetChildren()) do
		if child:IsA("Attachment") and not headMesh:FindFirstChild(child.Name) then
			local vec3Copy = Instance.new("Vector3Value")
			vec3Copy.Name = child.Name
			vec3Copy.Value = child.Position
			vec3Copy.Parent = headMesh
		end
	end

	local partScaleType = head:FindFirstChild("AvatarPartScaleType")
	if partScaleType and not headMesh:FindFirstChild("AvatarPartScaleType") then
		partScaleType:Clone().Parent = headMesh
	end
end

local function getMaxHeight(humanoid)
	local hrp = humanoid.RootPart
	local character = humanoid.Parent

	local upperTorso = character.UpperTorso
	local head = character.Head

	local root = character.LowerTorso.Root
	local waist = upperTorso.Waist
	local neck = head.Neck

	-- part0 * c0 == part1 * c1
	local lowerTorsoCF = root.C0 * root.C1:Inverse()
	local upperTorsoCF = lowerTorsoCF * waist.C0 * waist.C1:Inverse()
	local headCF = upperTorsoCF * neck.C0 * neck.C1:Inverse()

	local upperTorsoTop = upperTorsoCF.Y + upperTorso.Size.Y / 2
	local headTop = headCF.Y + head.Size.Y / 2

	-- Sometimes the upper torso is higher than the head.
	-- For example: https://www.roblox.com/bundles/429/Magma-Fiend
	return math.max(upperTorsoTop, headTop) + hrp.Size.Y / 2 + humanoid.HipHeight
end

local function rthroScaleFix(character: Model, heightTarget: number)
	local humanoid = character:WaitForChild("Humanoid")
	local hrp = humanoid.RootPart

	local floorCF = hrp.CFrame * CFrame.new(0, -(hrp.Size.Y / 2 + humanoid.HipHeight), 0)

	local height = getMaxHeight(humanoid)
	local scale = (heightTarget / height) * getObjectValue(humanoid, "BodyHeightScale", 1)

	local head = character:WaitForChild("Head")
	local headMesh = head:FindFirstChildWhichIsA("SpecialMesh")
	local isFileMesh = false

	if headMesh then
		isFileMesh = (headMesh.MeshType == Enum.MeshType.FileMesh)
	end

	local accessories = {}
	for _, accessory in pairs(character:GetChildren()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChildWhichIsA("BasePart")
			local weld = handle:FindFirstChild("AccessoryWeld")
			weld:Destroy()
			accessory.Parent = nil
			accessories[accessory] = true
		end
	end

	if headMesh then
		matchHeadToMesh(head, headMesh)
	end

	for _, child in pairs(character:GetDescendants()) do
		if child:IsA("Motor6D") then
			local p0 = child.C0.Position
			local p1 = child.C1.Position
			child.C0 = (child.C0 - p0) + p0 * scale
			child.C1 = (child.C1 - p1) + p1 * scale
		elseif child:IsA("Attachment") then
			child.Position = child.Position * scale
			child.OriginalPosition.Value = child.OriginalPosition.Value * scale
		elseif child.Name == "OriginalSize" then
			local parent = child.Parent

			if parent:IsA("BasePart") then
				parent.Size = parent.Size * scale
				child.Value = child.Value * scale
			elseif headMesh and parent == headMesh then
				for _, v3 in pairs(parent:GetChildren()) do
					if v3:IsA("Vector3Value") and v3 ~= child then
						v3.Value = v3.Value * scale
					end
				end

				if isFileMesh then
					parent.Scale = parent.Scale * scale
					child.Value = child.Value * scale
				end
			end
		end
	end

	for accessory, _ in pairs(accessories) do
		local handle = accessory:FindFirstChildWhichIsA("BasePart")
		handle.OriginalSize.Value = handle.OriginalSize.Value * scale
		humanoid:AddAccessory(accessory)
	end

	humanoid.HipHeight = humanoid.HipHeight * scale
	hrp.CFrame = floorCF * CFrame.new(0, hrp.Size.Y / 2 + humanoid.HipHeight, 0)
end

return {
	normalize = rthroScaleFix,
}
