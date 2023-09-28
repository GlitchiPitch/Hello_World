local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")

local function createPart(position, size, parent)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Anchored = true
	part.Position = position
	part.Size = size

	return part
end

local function nodes(value, y)
	local nodesPositions = {
		{ value, y, 0 },
		{ 0, y, value },
		{ -value, y, 0 },
		{ 0, y, -value },
	}
	return nodesPositions
end


local Stage = {}

-- этот этап переходный между локациями, после его прохождения игрок попадает на след локацию
-- надо как-то отправить сигнал наверх что игра закончилась, а просто отправить self не получается, он отправлять детальку к которой касание происходит, меня почему-то это бесит

-- надо спавнить три комнаты с разными размерами
-- надо спавнить разное количество сигналов и в разных местах
-- надо спавнить комнаты после касания к телепорту

Stage.__index = Stage

function Stage.Create(game_, map, resourses, event)
	local self = setmetatable({}, Stage)

	self.Game = game_
	self.Map = map
	self.Resourses = resourses
	self.IsReady = false
	self.Event = event
	self.Room = nil

	print(self.Event)
	self.Signals = {}
	self.SignalList = {
		Long = {},
		Short = {},
	}

	self.Level = 2

	self.PlayerSpawnPoint = nil
	self:Init()

	return self
end

function Stage:Init()
	self:CreatePort()
	self:CreateSignalFolders()
	print("Stage 2 init")

	repeat
		wait()
	until self.IsReady
	print(" Stage 2 is ready")
	self:FinishAction()
end

function Stage:FinishAction()
	for singalName, item in pairs(self.SignalList) do
		item.Parent = singalName == self.SignalList.Long.Name and self.LongSignalFolder or self.ShortSignalFolder
		-- table remove item
	end
	-- self.Location.IsReady = true
	-- self.Event:Fire()
	-- delete signals
end

function Stage:CreateSignalFolders()
	self.ShortSignalFolder, self.LongSignalFolder = Instance.new("Folder"), Instance.new("Folder")
	self.ShortSignalFolder.Parent, self.LongSignalFolder.Parent = ServerStorage, ServerStorage
	self.ShortSignalFolder.Name, self.LongSignalFolder.Name = "ShortSignal", "LongSignal"
end

function Stage:SetupSignals(particle, bit)
	local lengthOfFlash = 2
	local tInfo = TweenInfo.new(
		bit == 0 and lengthOfFlash / 2 or lengthOfFlash,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1,
		true
	)
	TweenService:Create(particle, tInfo, { ImageTransparency = 1 }):Play()
end

function Stage:SetupSignalPlatform(signalPlatform, bit)
	local signalPlatformType = bit == 0 and self.SignalList.Short or self.SignalList.Long
	signalPlatform.touchedPart.Touched:Connect(function(hitPart)
		if game:GetService("CollectionService"):HasTag(hitPart, "Interact") then
			table.insert(signalPlatformType, hitPart)
		end
	end)

	signalPlatform.touchedPart.TouchEnded:Connect(function(hitPart)
		if table.find(signalPlatformType, hitPart, 1) and game:GetService("CollectionService"):HasTag(hitPart, "Interact") then
			table.remove(signalPlatformType, table.find(signalPlatformType, hitPart, 1))
		end
	end)
end

function Stage:CreateSingals(p1, p2)

	-- they are different in the different level
	-- на первом уровне они получают кубики и создают потом папку, на след уровне они должны проверять что кубки им положили правильные 
	-- вторую комнату будет прикольно сделать с дырками в полу, которые будут определять каждую букву и когда игрок будет туда кидать нужные кубики, то кубик затухает 
	-- и в чате пишется буква 
	-- в следующих комнатах сигналы будут вглядеть как платформы на глубине с неоновым светом и туда надо кидать кубики

	local l = { p1.Position, p2.Position }

	for i, pos in pairs(l) do
		local model = Instance.new("Model")
		model.Parent = workspace

		local part = Instance.new("Part")
		part.Parent = model
		part.Size = Vector3.new(1, 1, 1)
		part.Transparency = 1
		part.CanCollide, part.CanQuery, part.CanTouch = false, false, false
		part.Anchored = true
		part.Position = pos + Vector3.new(0,11,0)

		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromScale(4, 4)
		gui.Parent = part

		local particle = Instance.new("ImageLabel")
		particle.BackgroundTransparency = 1
		particle.Image = "rbxassetid://11815755770"
		particle.Size = UDim2.fromScale(1, 1)
		particle.Parent = gui
		self:SetupSignals(particle, (i - 1))

		local signalPlatform = self.Resourses.Items:FindFirstChild("SignalPlatform"):Clone()
		signalPlatform.Parent = model
		signalPlatform:PivotTo(CFrame.new(part.CFrame.Position - Vector3.new(0, 5, 0)) * signalPlatform:GetPivot().Rotation)
		self:SetupSignalPlatform(signalPlatform, (i - 1))

		table.insert(self.Signals, model)
	end
end

function Stage:CreateRoom(properties, roomModel, existFloor)
	local value = properties.wallsPositionValue
		local y = 10
		local wallHeight = properties.wallHeight

		local nodesPositions = nodes(value, y)

		local model = Instance.new("Model")
		model.Parent = roomModel

		local multiplyValue = 2

		for i = 1, not existFloor and 5 or 6 do
			if nodesPositions[i] then
				local sidePosition = Vector3.new(table.unpack(nodesPositions[i]))

				local x, y, z =
				sidePosition.X == 0 and math.abs(sidePosition.Z) * multiplyValue or 1,
				wallHeight,
				sidePosition.Z == 0 and math.abs(sidePosition.X) or 1
				local sideSize = Vector3.new(x, y, z)

				sidePosition = Vector3.new(
					sidePosition.Z == 0 and (sidePosition.X / 2) * multiplyValue or sidePosition.X,
					sidePosition.Y,
					sidePosition.X == 0 and sidePosition.Z / 2 or sidePosition.Z
				)
					
				createPart(sidePosition, sideSize, model)
			else
				local _, modelSize = model:GetBoundingBox()
				local pos = model:GetPivot().Position
					+ (i % 2 == 1 and Vector3.new(0, modelSize.Y / 2, 0) or Vector3.new(0, -modelSize.Y / 2, 0))
				local size = Vector3.new(modelSize.X, 1, modelSize.Z)
				createPart(pos, size, model)
			end
		end
end

function Stage:CreatePyramid(contentModel, roomModel)
	local function createPyramid()
		local pyramidModel = Instance.new("Model")
		pyramidModel.Parent = contentModel

		local value = 10
		local y = 10

		local nodesPositions = nodes(value, y)
		local size = Vector3.new(10, 10, 10)

		for i = 1, 6 do
			if nodesPositions[i] then
				local pos = Vector3.new(table.unpack(nodesPositions[i]))
				local orientation = pos.X == 0 and (pos.Z < 0 and Vector3.new(0, 0, 0) or Vector3.new(0, 180, 0))
					or pos.Z == 0 and (pos.X < 0 and Vector3.new(0, 90, 0) or Vector3.new(0, -90, 0))
				local wedge = createPart(pos, size, pyramidModel)
				wedge.Shape = Enum.PartType.Wedge
				wedge.Orientation = orientation
				wedge.Color = Color3.new(1, 0, 0)
			else
				local vector1 = i % 2 == 0 and Vector3.new(table.unpack(nodesPositions[1]))
					or Vector3.new(table.unpack(nodesPositions[3]))
				local vector2 = i % 2 == 0 and Vector3.new(table.unpack(nodesPositions[2]))
					or Vector3.new(table.unpack(nodesPositions[4]))
				local pos = Vector3.new(vector1.X, 0, vector1.Z)
					+ Vector3.new(vector2.X, 0, vector2.Z)
					+ Vector3.new(0, y, 0)

				local function corner(pos, orientation)
					local cornerWedge = createPart(pos, size, pyramidModel)
					cornerWedge.Shape = Enum.PartType.CornerWedge
					cornerWedge.Color = Color3.new(0, 1, 0)
					cornerWedge.Orientation = orientation

					return cornerWedge
				end

				local c = corner(pos, pos.Z < 0 and Vector3.new(0, -90, 0) or Vector3.new(0, 90, 0))
				c.Color = Color3.new(1, 1, 0)
				c.Name = i
				local c2 = corner(
					pos.Z < 0 and Vector3.new(pos.X, pos.Y, math.abs(pos.Z)) or Vector3.new(pos.X, pos.Y, -pos.Z),
					pos.Z < 0 and Vector3.new(0, 0, 0) or Vector3.new(0, 180, 0)
				)
				c2.Color = Color3.new(1, 0, 1)
				c2.Name = i .. "2"
			end
			local pos = Vector3.new(0, y, 0)
			createPart(pos, size, pyramidModel)
		end
		
		return pyramidModel
	end

	local roomPivot = roomModel:GetPivot()
	local _, roomSize = roomModel:GetBoundingBox()
	local pyramid1 = createPyramid()
	local _, size = pyramid1:GetBoundingBox()
	pyramid1:PivotTo(
		CFrame.new(
			-(roomPivot.X + roomSize.X / 2) + 1 + size.X / 2,
			(roomPivot.Y - roomSize.Y / 2) + 1 + size.Y / 2,
			roomPivot.Z
		)
	)
	local pyramid2 = createPyramid()
	local _, size = pyramid2:GetBoundingBox()
	pyramid2:PivotTo(
		CFrame.new(
			(roomPivot.X + roomSize.X / 2) - 1 - size.X / 2,
			(roomPivot.Y - roomSize.Y / 2) + 1 + size.Y / 2,
			roomPivot.Z
		)
	)

	self:CreateSingals(pyramid1:GetPivot(), pyramid2:GetPivot())
end

function Stage:CreateSignalsField(contentModel, roomModel)

	local value = 11
	local startVector = roomModel:GetPivot().Position
	local _, sizeRoom = roomModel:GetBoundingBox()
	startVector = Vector3.new(startVector.X - sizeRoom.X / 2, startVector.Y - sizeRoom.Y / 2, startVector.Z - sizeRoom.Z / 2)

	local fieldModel = Instance.new('Model')
	fieldModel.Parent = contentModel

	print(math.floor(sizeRoom.X / 8))
	print(math.floor(sizeRoom.Z / 8))

	local function createNodes()
        local nodes = {}
        for x = 1, math.floor(sizeRoom.X / 4) - 5 do
            for z = 1, math.floor(sizeRoom.Z / 4) - 2 do 
                    table.insert(nodes, {x, 0, z})
            end
        end
        return nodes
    end
	
	for i, node in pairs(createNodes()) do
		local isSignalPart = node[1] % 2 == 0 and node[1] < value and node[3] % 2 == 0 and node[3] < value --(i > value and i < value ^ 2) and i % 2 == 0
		local size = Vector3.new(5,1,5)
		local pos = (startVector - Vector3.new(size.X / 2, 0, size.Z / 2)) + (Vector3.new(table.unpack(node)) * -- очень прикольно получилось умножать на этот вектор
		Vector3.new(size.X, 0, size.Z)) + 
		Vector3.new(
			0,
			isSignalPart and -10 or 0,
			0
		)
		local part = createPart(pos, size, fieldModel)
		part.Color = Color3.new(0,1,1)
		if isSignalPart then 
			local singalPart = part:Clone()
			singalPart.Parent = part.Parent
			singalPart.Material, singalPart.Color = Enum.Material.Neon, Color3.new(1,1,1)
			part.Transparency = 1
		end
	end

end

function Stage:CreateRoomContent(roomModel)
	local contentModel = Instance.new("Model")
	contentModel.Parent = roomModel

		-- надо получать разное количество граней у горок, разные позицию для них и разное количество

	-- self:CreatePyramid(contentModel, roomModel)	
	-- self:CreatePortalBetweenRooms(roomModel)
	self:CreateSignalsField(contentModel, roomModel)
	-- self:CreateCubes(roomModel)
end

function Stage:CreatePortalBetweenRooms(roomModel)
	local roomPivot = roomModel:GetPivot()
	local _, roomSize = roomModel:GetBoundingBox()
	local size = Vector3.new(10,10,10)
	local pos = Vector3.new(roomPivot.X, roomPivot.Y - roomSize.Y / 2 + size.Y, roomPivot.Z - roomSize.Z / 2)
	local door = createPart(pos, size, roomModel)
	door.Color = Color3.new(1,1,0)
	door.Material = Enum.Material.Neon

	door.Touched:Connect(function(hitPart)
		if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
		if #self.LongSignalFolder == 0 or #self.ShortSignalFolder == 0 then return end
		-- положить в папки в сторадж кубики и удалить предыдущие комнату
	end)
end

function Stage:CreateCubes(roomModel)
	local roomPivot = roomModel:GetPivot()
	local IceCubesFolder = Instance.new('Folder')
	IceCubesFolder.Parent = roomModel
	for i = 1, math.random(10, 20) do
		local cube = createPart(roomPivot.Position + Vector3.new(math.random(-roomPivot.Position.X / 4, roomPivot.Position.X / 4), 0, math.random(-roomPivot.Position.Z / 4, roomPivot.Position.Z / 4)), Vector3.new(1,1,1), IceCubesFolder)
		cube.Anchored = false
		cube.BrickColor = BrickColor.random()
		CollectionService:AddTag(cube, 'Interact')
		-- wait(2)
	end
end

function Stage:SpawnRoom()
	local roomModel = Instance.new("Model")
	roomModel.Parent = workspace

	local properties = {
		wallsPositionValue = 50,
		wallHeight = 40,
	}

	self:CreateRoom(properties, roomModel, self.Level == 2 and false)
	self:CreateRoomContent(roomModel)

	return roomModel
end



function Stage:CreatePort()
	-- local mapPivot = self.Map:GetPivot()
	local portModel = Instance.new("Part") -- after it will be model
	portModel.Parent = workspace
	portModel.Position = Vector3.new(0, 5, 0)
	portModel.Color = Color3.new(0, 1, 0)
	portModel.Size = Vector3.new(10, 10, 10)

	portModel.Touched:Connect(function(hitPart)
		if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then
			return
		end
		
		self.Room = self:SpawnRoom()
		portModel:Destroy()
	end)

	local finishTrigger = Instance.new("Part")
	finishTrigger.Parent = workspace
	finishTrigger.Position = Vector3.new(0, 5, 0)
	finishTrigger.Color = Color3.new(1, 0, 1)
	finishTrigger.Size = Vector3.new(10, 10, 10)

	finishTrigger.Touched:Connect(function(hitPart)
		if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
		self.IsReady = true
		finishTrigger:Destroy()
	end)
end

return Stage

--[[

it's like a hole 

local orientation = pos.X == 0 and (pos.Z > 0 and Vector3.new(0,0,0) or Vector3.new(0,180,0)) or 
                                        pos.Z == 0 and (pos.X > 0 and Vector3.new(0,90,0) or Vector3.new(0,-90,0))
]]
