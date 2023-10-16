local Lighting = game:GetService("Lighting")

local function createPart(parent, position, size)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Size = size
	part.Position = position
	part.Color = Color3.new(.5,.5,.5)
	part.Anchored = true

	return part
end


local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
	local self = setmetatable({}, Stage)

	self.Game = game_
	self.Room = nil
	self.IsReady = false

	self:Init()
	return self
end

-- bottom of the room will need to respawn and make holes into it

function Stage:Init()
	print("stage 3 is started")
	self.Room = game:GetService("CollectionService"):GetTagged("Heaven")[1]
	self:SetupRoom()
	repeat
		wait()
	until self.IsReady
	self:FinishAction()
end

function Stage:Setup()
    Lighting.ClockTime = 0
end

function Stage:CreateTower(bottom)
    local towerModel = Instance.new('Model')
    towerModel.Parent = self.Room

    local gridTable = {}

    local blockSize = Vector3.new(5,5,5)
    local startVector = Vector3.new(bottom.Position.X - bottom.Size.X / 2 + blockSize.X / 2, bottom.Position.Y - blockSize.Y / 2 + .5, bottom.Position.Z - bottom.Size.Z / 2 + blockSize.Z / 2)

    local deepValue = 10
    for x = 1, math.floor(bottom.Size.X / 5) do
        gridTable[x] = {}
        for z = 1, math.floor(bottom.Size.Z / 5) do
            gridTable[x][z] = {}
            for y = 1, deepValue do
                local part = createPart(towerModel, Vector3.new(startVector.X + (blockSize.X * (x - 1)), startVector.Y - (blockSize.Y * (y - 1)), startVector.Z + (blockSize.Z * (z - 1)) ), blockSize)
                part.Color = Color3.new(1,0,0)
                gridTable[x][z][y] = part
            end
        end
    end

    print(gridTable)
    local r = math.random
    local s = {r(#gridTable), r(#gridTable), 1}
    local start = gridTable[s[1]][s[2]][s[3]]
    local function next(cellIndex: table)
        local nextCell
    end

    bottom:Destroy()


end

function Stage:SetupRoom()
	for _, obj in pairs(self.Room:GetChildren()) do
		if obj:IsA("Part") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Color = Color3.new(0.5, 0.5, 0.5)
			if obj.Name == "Part" or obj.Name == 'roof' then
				if obj.Name == 'Part' then obj.SurfaceLight:Destroy() end
				local tween = game:GetService("TweenService"):Create(
					obj,
					TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 2),
					{ Transparency = 1 }
				)
				tween:Play()
                obj.CanCollide = false
            else
                self:CreateTower(obj)
			end
		end
	end
end

function Stage:FinishAction() end

return Stage
