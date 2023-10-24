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
		wall.Name = 'wall'
	end

	local pivot, roomSize = model:GetBoundingBox()

	local roof = createPart(model, pivot.Position + Vector3.new(0, roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	local bottom = createPart(model, pivot.Position + Vector3.new(0, -roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	roof.Color, bottom.Color = Color3.new(.5,.5,.5), Color3.new(.5,.5,.5)
	roof.Material, bottom.Material = roomProperties.material, roomProperties.material
	roof.Name, bottom.Name = 'roof', 'bottom'
	roof.CanCollide = false

	return model
end

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
	local self = setmetatable({}, Stage)
	self.Game = game_
	self.SpawnPivot = nil
	self.BlackRoom = nil
	self.Corridor = nil

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

	self.BlackRoom = createRoom(blackRoom, {
		roomSize = 10,
		wallHeight = 10,
		material = Enum.Material.Rubber
	}, false)


	blackRoom:PivotTo(self.SpawnPivot[1] * CFrame.new(0, -self.SpawnPivot[2].Y, 0)) --* CFrame.new(0, -50, 0)

	self.Corridor = createRoom(corridorModel, {
		roomSize = 25,
		wallHeight = 10,
		material = Enum.Material.Rubber
	}, true)

	corridorModel:PivotTo(self.SpawnPivot[1] * CFrame.new(0, -self.SpawnPivot[2].Y,100)) -- * CFrame.new(0, -50, 100)
end

function Stage:CreateCorridorContent(corridor)
	
end

function Stage:CreateBlackRoomContent()
	local cf, size = self.BlackRoom:GetBoundingBox()
	local walls = {}
	for _, obj in pairs(self.BlackRoom:GetChildren()) do if obj.Name == 'wall' then table.insert(walls, obj) end end
	local currentWall = walls[math.random(#walls)]
	local pos = currentWall.Size.Z == 1 and (currentWall.CFrame.X < cf.X and currentWall.Position + Vector3.new(1,0,0) or currentWall.Position - Vector3.new(1,0,0)) or
				(currentWall.CFrame.Z < cf.Z and currentWall.Position + Vector3.new(0,0,1) or currentWall.Position - Vector3.new(0,0,1))
	local size = Vector3.new(1,1,1)
	local targetSize = currentWall.Size
	local portal = createPart(self.BlackRoom, pos, size)

	local changeSizeConnect
	local characterPos = self.Game.Player.Character:GetPivot().Position
	changeSizeConnect = game:GetService('RunService').Heartbeat:Connect(function(deltaTime)
		-- local charPos, portalPos
		-- if math.abs(Vector3.new(charPos.X, 0, charPos.Z) - math.abs(portalPos).Magnitude) < 5 then
		-- 	portal.Size = targetSize
		-- else
		local mag = (Vector3.new(characterPos.X, 0, characterPos.Z) - Vector3.new(portal.Position.X, 0, portal.Position.Z)).Magnitude
		portal.Size *= Vector3.new(targetSize.X == 1 and 1 or mag / 10, mag / 10, targetSize.Z == 1 and 1 or mag / 10)
		-- print((Vector3.new(characterPos.X, 0, characterPos.Z) - Vector3.new(portal.Position.X, 0, portal.Position.Z)).Magnitude)
	end)
end

function Stage:Action()
	self:CreateBlackRoomContent()
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
	self:Action()

	repeat wait() until self.IsReady

	print('finish final stage')
end

return Stage
