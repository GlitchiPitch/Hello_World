-- THIS IS FINAL STAGE --

local function createPart(parent, size, position)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Size = size
	part.Position = position
	part.Anchored = true

	return part
end

local function createRoom(parent, roomProperties, mainPivot, isCorridor)
	
	local sides = { {1, 0}, {-1, 0}, {0, 1}, {0, -1} }
	local model = Instance.new('Model')
	model.Parent = parent

	for i, side in pairs(sides) do
		local pos = Vector3.new(side[1] * roomProperties.roomSize / 2, mainPivot.Y, side[2] * roomProperties.roomSize / (isCorridor and 1 or 2))
		local size = Vector3.new(side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize), roomProperties.wallHeight, side[1] == 0 and 1 or math.abs(side[1] * roomProperties.roomSize))
		local wall = createPart(model, pos, size)
		wall.Material = roomProperties.material
		wall.Color = Color3.new(0.4, 0.3, 0.2)
	end

	local _, roomSize = model:GetBoundingBox()
	local pivot = model:GetPivot()

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

function Stage:Setup() end

function Stage:CreateCorridor()
	local corridorModel, blackRoom = Instance.new("Model"), Instance.new('Model')
	corridorModel.Parent, blackRoom.Parent = workspace, workspace

	createRoom(blackRoom, {
		roomSize = 50,
		wallHeight = 20,
		material = Enum.Material.Rubber
	}, self.SpawnPivot, false)


	createRoom(corridorModel, {
		roomSize = 50,
		wallHeight = 20,
		material = Enum.Material.Rubber
	}, self.SpawnPivot * CFrame.new(100,0,0), true)
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

	self.SpawnPivot = game:GetService("CollectionService"):GetTagged("PrevRoom")[1]:GetPivot()
	game:GetService("CollectionService"):GetTagged("PrevRoom")[1]:Destroy()
	-- print(game:GetService("CollectionService"):GetTagged("Pivot"))
	-- print(self.SpawnPivot)

	self:CreateCorridor()

	repeat wait() until self.IsReady

	print('finish final stage')
end

return Stage
