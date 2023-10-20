-- THIS IS FINAL STAGE --

local function createPart(parent, position, size)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Size = size
	part.Position = position
	part.Anchored = true

	return part
end

local function createRoom(parent, roomProperties, isCorridor)
	
	local sides = { {1, 0}, {-1, 0}, {0, 1}, {0, -1} }
	local model = parent

	for i, side in pairs(sides) do
		local pos = Vector3.new(side[1] * roomProperties.roomSize / 2, roomProperties.wallHeight / 2, side[2] * roomProperties.roomSize / (isCorridor and 1 or 2))
		local size = Vector3.new(side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize), roomProperties.wallHeight, side[1] == 0 and 1 or math.abs(side[1] * roomProperties.roomSize) + (isCorridor and roomProperties.roomSize or 0))
		local wall = createPart(model, pos, size)
		wall.Material = roomProperties.material
		wall.Color = Color3.new(0.478431, 0.788235, 0.466666)
	end

	local pivot, roomSize = model:GetBoundingBox()

	local roof = createPart(model, pivot.Position + Vector3.new(0, roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	local bottom = createPart(model, pivot.Position + Vector3.new(0, -roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	roof.Color, bottom.Color = Color3.new(.5,.5,.5), Color3.new(.5,.5,.5)
	roof.Material, bottom.Material = roomProperties.material, roomProperties.material
	roof.Name, bottom.Name = 'roof', 'bottom'
	roof.CanCollide = false

end

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
	local self = setmetatable({}, Stage)
	self.Game = game_
	self.SpawnPivot = nil

	self.IsReady = false

	self:Init()
	return self
end

function Stage:Setup() 
	self.Game.Player.Character:ScaleTo(.1)
end

function Stage:CreateCorridor()
	local corridorModel, blackRoom = Instance.new("Model"), Instance.new('Model')
	corridorModel.Parent, blackRoom.Parent = workspace, workspace

	createRoom(blackRoom, {
		roomSize = 10,
		wallHeight = 20,
		material = Enum.Material.Rubber
	}, false)

	blackRoom:PivotTo(self.SpawnPivot[1] * CFrame.new(0, -self.SpawnPivot[2].Y, 0)) --* CFrame.new(0, -50, 0)

	createRoom(corridorModel, {
		roomSize = 25,
		wallHeight = 20,
		material = Enum.Material.Rubber
	}, true)

	corridorModel:PivotTo(self.SpawnPivot[1] * CFrame.new(0, -self.SpawnPivot[2].Y,100)) -- * CFrame.new(0, -50, 100)
end

function Stage:CreateBlackRoomContent(room)
	local pos = Vector3.new()
	local size = Vector3.new()
	local portal = createPart(room, pos, size)

	local changeSizeConnect
	changeSizeConnect = game:GetService('RunService').Heartbeat:Connect(function(deltaTime)
		
	end)
end

function Stage:SubscribeEvents()

	-- self.Game.Events.Remotes.
end

function Stage:FinishAction(result)
	if result == "Fail" then
		print("not ok")
	elseif result == "Success" then
		print("ok")
	end
end

function Stage:Init() 
	print('start final stage')

	local pivot, size = game:GetService("CollectionService"):GetTagged("PrevRoom")[1]:GetBoundingBox()
	game:GetService("CollectionService"):GetTagged("PrevRoom")[1]:Destroy()
	self.SpawnPivot = {pivot, size}

	self:CreateCorridor()
	self:Setup()

	repeat wait() until self.IsReady

	print('finish final stage')
end

return Stage
