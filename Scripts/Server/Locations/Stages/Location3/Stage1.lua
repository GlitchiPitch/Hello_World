local Lighting = game:GetService("Lighting")

local BASEPLATE_MOVE_SPEED = 0.005

local function createMaze(nIter: number, startPosition: Vector3, cellSize: Vector3)
	local nodes = {}
	for x = 1, nIter do
		nodes[x] = {}
		for z = 1, nIter do
			table.insert(nodes[x], Vector3.new(x * cellSize.X - cellSize.X / 2, 0, z * cellSize.Z - cellSize.Z / 2) + startPosition)
		end
	end

	for j, p in pairs(nodes) do
		for i, pp in pairs(p) do
			if i % 2 == 0 and j == nIter or i % 2 == 1 and j == 1 then continue end
			local p = Instance.new('Part')
			p.Parent = workspace
			p.Anchored = true
			p.Size = Vector3.new(cellSize.X, cellSize.Y, 1)
			p.Color = Color3.new(0,0,1)
			p.Position = pp - Vector3.new(0, 0, cellSize.Z / 2)
		end
	end


	-- return nodes
end

local function createPart(parent, position, size)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Size = size
	part.Position = position
	part.Color = Color3.new(0,1,0)
	part.Anchored = true

	return part
end

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
	local self = setmetatable({}, Stage)

	self.Game = game_
	self.Map = map
	self.Resourses = resourses
	self.IsReady = true
	self.PlayerSpawnPoint = nil

	self:Init()
	return self
end

function Stage:Init()
	print("stage 1 is started")

	-- self:CreateMaze()
	self:SpawnRoom()
	self:ChangeCharacterSize()
	if self.Game.Player.Character.HumanoidRootPart and self.PlayerSpawnPoint then
		self.Game.Player.Character.HumanoidRootPart.CFrame = self.PlayerSpawnPoint.Value
	end

	repeat wait() until self.IsReady

	print("stage is ready")
end


function Stage:SpawnRoom()
	local roomProperties = {
		roomSize = 100,
		wallHeight = 50
	}

	self.Room, roomSize, pivot = self:CreateRoom(roomProperties)
	self:CreateContent(roomProperties, self.Room, roomSize, pivot)
end

function Stage:CreateContent(roomProperties, room, roomSize, pivot)
	local cellSize = Vector3.new(10,roomProperties.wallHeight - 10,10) -- roomSize.Y - 20
	local startVector = Vector3.new(pivot.X - roomSize.X / 2, pivot.Y - 5, pivot.Z - roomSize.Z / 2 + cellSize.Z / 2)

	local spawn_ = createPart(room, Vector3.new(pivot.X + roomSize.X / 2 - 2.5, pivot.Y + 20, pivot.Z - roomSize.Z / 2 + 2.5), Vector3.new(5,1,5))
	spawn_.Color = Color3.new(1,1,0)
	self.PlayerSpawnPoint = Instance.new('CFrameValue')
	self.PlayerSpawnPoint.Value = CFrame.new(0, 15, 0) * spawn_.CFrame

	local finishPoint = createPart(room, Vector3.new(pivot.X - roomSize.X / 2 + 2.5, pivot.Y + 20, pivot.Z + roomSize.Z / 2 - 2.5), Vector3.new(5,5,5))
	finishPoint.Color = Color3.new(0,0,0)

	createMaze(roomProperties.roomSize / 10, startVector, cellSize)
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

	return model, roomSize, pivot
end

function Stage:ChangeCharacterSize()
	self.Game.Player.Character:ScaleTo(.2)
end

function Stage:MoveBaseplate()
	local baseplate = Instance.new("Part") -- self.Map.Baseplate
	local roof = Instance.new("Part") -- self.Map.Roof
	local startPosition = Vector3.new(0, 0, 0)
	baseplate.Position = startPosition

	self.MoveBaseplate = game:GetService("RunService").Heartbeat:Connect(function()
		baseplate.Position += Vector3.new(0, BASEPLATE_MOVE_SPEED, 0)
	end)
end

function Stage:UpdateState()
	local current
end

return Stage
