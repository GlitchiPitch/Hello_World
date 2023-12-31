local Lighting = game:GetService("Lighting")

local BASEPLATE_MOVE_SPEED = 0.01

local function createMaze(nIter: number, startPosition: Vector3, cellSize: Vector3)
	local nodes = {}
	for x = 1, nIter do
		nodes[x] = {}
		for z = 1, nIter do
			table.insert(nodes[x], Vector3.new(x * cellSize.X - cellSize.X / 2, 0, z * cellSize.Z - cellSize.Z / 2) + startPosition)
		end
	end
	local mazeModel = Instance.new('Model')
	for j, p in pairs(nodes) do
		for i, pp in pairs(p) do
			if i % 2 == 0 and j == nIter or i % 2 == 1 and j == 1 then continue end
			local p = Instance.new('Part')
			p.Parent = mazeModel
			p.Anchored = true
			p.Size = Vector3.new(cellSize.X, cellSize.Y, 1)
			p.Color = Color3.new(.2,.2,.2)
			p.Position = pp - Vector3.new(0, 0, cellSize.Z / 2)
		end
	end

	return mazeModel
end

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

function Stage.Create(location)
	local self = setmetatable({}, Stage)

	self.Game = location.Game
	self.IsReady = false
	self.PlayerSpawnPoint = nil
	self.MoveBaseplate = nil -- connect

	self:Init()
	return self
end

function Stage:Init()
	print("stage 1 is started")

	-- self:CreateMaze()
	self:SetupStage()
	self:SpawnRoom()
	if self.Game.Player.Character.HumanoidRootPart and self.PlayerSpawnPoint then
		self.Game.Player.Character.HumanoidRootPart.CFrame = self.PlayerSpawnPoint.Value
	end

	repeat wait() until self.IsReady
	self:FinishAction()
	print("stage is ready")
end

function Stage:FinishAction()
	self.MoveBaseplate:Disconnect()
	self.Room:Destroy()
end

function Stage:SetupStage()
	Lighting.Ambient, Lighting.OutdoorAmbient = Color3.new(.1,.1,.1), Color3.new(.1,.1,.1)
	Lighting.Brightness, Lighting.ExposureCompensation = 0, 0
	Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale = 0, 0

	self.Game.Player.Character:ScaleTo(.2)

end

function Stage:SpawnRoom()
	local roomProperties = {
		roomSize = 100,
		wallHeight = 100
	}

	self.Room, roomSize, pivot, bottom, roof = self:CreateRoom(roomProperties)
	self:CreateContent(roomProperties, self.Room, roomSize, pivot, roof)
	self:MoveBaseplate(bottom, roof)
end

function Stage:CreateContent(roomProperties, room, roomSize, pivot, roof)
	local cellSize = Vector3.new(10,roomProperties.wallHeight - 10,10) -- roomSize.Y - 20
	local startVector = Vector3.new(pivot.X - roomSize.X / 2, pivot.Y - 5, pivot.Z - roomSize.Z / 2 + cellSize.Z / 2)

	local spawn_ = createPart(room, Vector3.new(pivot.X + roomSize.X / 2 - 2.5, roof.Position.Y - 20, pivot.Z - roomSize.Z / 2 + 2.5), Vector3.new(5,1,5))
	spawn_.Color = Color3.new(1,1,0)
	self.PlayerSpawnPoint = Instance.new('CFrameValue')
	self.PlayerSpawnPoint.Value = spawn_.CFrame

	local finishPoint = createPart(room, Vector3.new(pivot.X - roomSize.X / 2 + 1.5, roof.Position.Y - 20, pivot.Z + roomSize.Z / 2 - 3.5), Vector3.new(5,40,4.5))
	finishPoint.Color = Color3.new(0,0,0)
	finishPoint.CanCollide = false

	finishPoint.Touched:Connect(function(hitPart)
		if self.Game.Player.Character == hitPart.Parent then
			task.wait(1)
			self.IsReady = true
		end
	end)

	local maze = createMaze(roomProperties.roomSize / 10, startVector, cellSize)
	maze.Parent = room
end

function Stage:CreateRoom(roomProperties)
	

	local sides = { {1, 0}, {-1, 0}, {0, 1}, {0, -1} }
	local model = Instance.new('Model')
	model.Parent = workspace
	for _, side in pairs(sides) do
		local pos = Vector3.new(side[1] * roomProperties.roomSize / 2, roomProperties.wallHeight / 2, side[2] * roomProperties.roomSize / 2)
		local size = Vector3.new(side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize), roomProperties.wallHeight, side[1] == 0 and 1 or math.abs(side[1] * roomProperties.roomSize))
		createPart(model, pos, size)
	end

	local _, roomSize = model:GetBoundingBox()
	local pivot = model:GetPivot()
	local roof = createPart(model, pivot.Position + Vector3.new(0, roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	local bottom = createPart(model, pivot.Position + Vector3.new(0, -roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))


	local light = Instance.new('SurfaceLight')
	light.Parent = roof
	light.Face = Enum.NormalId.Bottom
	light.Color = Color3.new(1,1,1)
	light.Brightness = 5
	light.Angle = 0
	light.Range = 100
	roof.Color = Color3.new(1,1,1)
	roof.Material = Enum.Material.Neon

	bottom.Color = Color3.new(0,0,0)

	return model, roomSize, pivot, bottom, roof
end

function Stage:MoveBaseplate(baseplate, roof)
	local changeLight = true
	local val = .001
	self.MoveBaseplate = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
		baseplate.Position += Vector3.new(0, BASEPLATE_MOVE_SPEED, 0)
		if Lighting.Brightness <= 10 then Lighting.Brightness += val end
		if Lighting.ExposureCompensation <= 3 then Lighting.ExposureCompensation += val end
		if baseplate.Position.Y >= roof.Position.Y - 10 then self.MoveBaseplate:Disconnect() end
		if baseplate.Position.Y >= roof.Position.Y - 50 and changeLight then 
			local currentColor = roof.SurfaceLight.Color
			roof.SurfaceLight.Color, roof.Color = roof.SurfaceLight.Color:Lerp(Color3.new(1,0,0), val), roof.Color:Lerp(Color3.new(1,0,0), val)
			Lighting.Ambient, Lighting.OutdoorAmbient = Lighting.Ambient:Lerp(Color3.new(1,0,0), val), Lighting.OutdoorAmbient:Lerp(Color3.new(1,0,0), val)
			Lighting.ColorShift_Bottom, Lighting.ColorShift_Top = Lighting.ColorShift_Bottom:Lerp(Color3.new(1,0,0), val), Lighting.ColorShift_Top:Lerp(Color3.new(1,0,0), val)
			if currentColor == roof.SurfaceLight.Color then changeLight = false print('over change light') end
		end
	end)
end

return Stage
