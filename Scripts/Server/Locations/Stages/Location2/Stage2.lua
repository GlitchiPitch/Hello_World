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

local binaryCode = {}
local code = '100010011000111011100001111110011001111'
for char in code:gmatch(".") do
	table.insert(binaryCode, char)
 end	

local binaryToLetter = {
	['1'] = 'A',
	['1000'] = 'H',
	['1001'] = 'I',
	['1101'] = 'M',
	['10000'] = 'P',
	['1111'] = 'O',
	['1100'] = 'L'
}

local Stage = {}

-- этот этап переходный между локациями, после его прохождения игрок попадает на след локацию
-- надо как-то отправить сигнал наверх что игра закончилась, а просто отправить self не получается, он отправлять детальку к которой касание происходит, меня почему-то это бесит

-- надо спавнить три комнаты с разными размерами
-- надо спавнить разное количество сигналов и в разных местах
-- надо спавнить комнаты после касания к телепорту

Stage.__index = Stage

function Stage.Create(game_, map, resourses, ...)
	local self = setmetatable({}, Stage)

	self.Game = game_
	self.Map = map
	self.Resourses = resourses
	self.IsReady = false
	self.Events = self.Game.Events
	self.Room = nil

	self.Signals = {}
	self.SignalList = {
		LongColor = Color3.new(0,0,0),
		ShortColor = Color3.new(0,0,0),
	}

	self.Level = 1

	self.PlayerSpawnPoint = nil
	self:Init()

	return self
end

function Stage:Init()
	self:CreatePort()
	self:CreateSignalVars()
	self:SubscribeEvents()
	print("Stage 2 init")
	repeat wait() until self.IsReady
	print(" Stage 2 is ready")
	self:FinishAction()
end

function Stage:SubscribeEvents()

	self.Events.Remotes.Interact.OnServerEvent:Connect(function(player, role, ...)
		if role == 'door' then
			if self.Level == 1 then
				if self.SignalList.LongColor == Color3.new(0,0,0) and self.SignalList.ShortColor == Color3.new(0,0,0) then return end
				self.SignalList.LongColor = self.Signals[1].Color self.SignalList.ShortColor = self.Signals[2].Color
				self.Level += 1
				table.clear(self.Signals)
				self.Room:Destroy()
				self.Room = self:SpawnRoom()
				self.Game.Player.Character:MoveTo(self.Room:GetPivot().Position)
			else
				for _, signalPart in pairs(self.Signals) do
					if signalPart.Color == self.SignalList.LongColor and signalPart:GetAttribute('Byte') == 1 or 
					signalPart.Color == self.SignalList.ShortColor and signalPart:GetAttribute('Byte') == 0 then 
						continue
					else 
						return	
					end
				end
				self.Room:Destroy()
				table.clear(self.Signals)
				-- self.Room = self:SpawnRoom()
				self.Game.Player.Character:MoveTo(Vector3.new(0,100,0))
			end
			
		elseif role == 'signal' then

			local colors = {Color3.new(1,0,0), Color3.new(0,1,0)}

			local signal = ...
			-- signal.Color = signal.BrickColor == BrickColor.White() and colors[math.random(#colors)] or signal.Color == colors[1] and colors[2] or colors[1]
			-- поиск цвета и поиск в таблице следующег цвета, если цвет не нашелся то ханово запускаем поиск
			local clrs = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(0,1,0), Color3.new(1,0,1)}
			-- print(table.find(clrs, {table.pack(signal.Color)[1]}, 1))
			-- print({table.pack(signal.Color)[1]})
			-- print(table.find(clrs, signal.Color, 1))
			local nextIndex = table.find(clrs, signal.Color, 1) and table.find(clrs, signal.Color, 1) + 1 or 1
			print(nextIndex)

			signal.Color = signal.BrickColor == BrickColor.White() and clrs[1] or clrs[nextIndex] ~= nil and clrs[nextIndex] or clrs[1]
			if signal:GetAttribute('Byte') == 0 then self.SignalList.ShortColor = signal.Color else self.SignalList.LongColor = signal.Color end
		end

	end)
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

function Stage:CreateSignalVars()
	self.ShortSignal, self.LongSignal = Instance.new('Color3Value'), Instance.new("Color3Value")
	self.LongSignal.Parent, self.LongSignal.Parent = ServerStorage, ServerStorage
	self.LongSignal.Name, self.LongSignal.Name = "ShortSignal", "LongSignal"
end

function Stage:SetupSignals(signal, byte)
	local lengthOfFlash = 2
	local tInfo = TweenInfo.new(
		byte == 0 and lengthOfFlash / 2 or lengthOfFlash,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		-1,
		true
	)
	TweenService:Create(signal, tInfo, { Transparency = 1 }):Play()
	CollectionService:AddTag(signal, 'Interact')
	signal:SetAttribute('Role', 'signal')
	if self.Level > 1 then signal:SetAttribute('Byte', byte) end
end



function Stage:CreateSingals(positions, roomModel, bytes, size)

	local signalFolder = Instance.new('Folder')
	signalFolder.Parent = roomModel
	-- they are different in the different level
	-- вторую комнату будет прикольно сделать с дырками в полу, которые будут определять каждую букву и когда игрок будет туда кидать нужные кубики, то кубик затухает 
	-- и в чате пишется буква 
	-- в следующих комнатах сигналы будут вглядеть как платформы на глубине с неоновым светом и туда надо кидать кубики
	-- local size = Vector3.new(5,5,5)
	
	for i = 1, #bytes do
		local signalPart = createPart(positions[i], size, signalFolder)
		signalPart.BrickColor = BrickColor.White()
		signalPart.Material = Enum.Material.Neon
		self:SetupSignals(signalPart, bytes[i])
		table.insert(self.Signals, signalPart)
	end
	-- print(self.Signals)
end

function Stage:CreateRoom(properties, roomModel)
	local value = properties.wallsPositionValue
		local y = 10
		local wallHeight = properties.wallHeight

		local nodesPositions = nodes(value, y)

		local model = Instance.new("Model")
		model.Parent = roomModel

		local multiplyValue = 2

		for i = 1, 6 do
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
	
	self:CreateSingals({pyramid1:GetPivot().Position + Vector3.new(0,size.Y, 0), pyramid2:GetPivot().Position + Vector3.new(0,size.Y, 0)}, roomModel, {1, 0}, Vector3.new(5,5,5))
end

function Stage:CreateSignalsField(contentModel, roomModel)

	local startVector = roomModel:GetPivot().Position
	local _, sizeRoom = roomModel:GetBoundingBox()
	startVector = Vector3.new(startVector.X - sizeRoom.X / 2, startVector.Y - sizeRoom.Y / 2, startVector.Z - sizeRoom.Z / 2)

	local fieldModel = Instance.new('Model')
	fieldModel.Parent = contentModel

	local function createNodes()
        local nodes = {}
        for x = 1, math.floor(sizeRoom.X / 4) - 5 do
            for z = 1, math.floor(sizeRoom.Z / 4) - 2 do
                table.insert(nodes, {x, 0, z})
            end
        end
        return nodes
    end
	
	local nodesForSignals = {}
	for i, node in pairs(createNodes()) do
		-- в сигнал парт еще добавить рандом, который будет зависеть от 0 и 1 нужных для того чтобы написать послание и парт либо будет сигналом либо нет
		local size = Vector3.new(5,1,5)
		local pos = (startVector + Vector3.new(-size.X / 2, 10, -size.Z / 2)) + (Vector3.new(table.unpack(node)) * -- очень прикольно получилось умножать на start вектор
		Vector3.new(size.X, 0, size.Z))
		if node[1] % 2 == 0 and node[1] and node[3] % 2 == 0 and node[3] then -- and math.random(2) == 1 
			table.insert(nodesForSignals, pos)
		end
	end
	
	self:CreateSingals(nodesForSignals, roomModel, binaryCode, Vector3.new(1,1,1))
end

function Stage:CreateRoomContent(roomModel)
	local contentModel = Instance.new("Model")
	contentModel.Parent = roomModel
	if self.Level == 1 then self:CreatePyramid(contentModel, roomModel) else self:CreateSignalsField(contentModel, roomModel) end
	self:CreatePortalBetweenRooms(roomModel)
end

function Stage:CreatePortalBetweenRooms(roomModel)
	local roomPivot = roomModel:GetPivot()
	local _, roomSize = roomModel:GetBoundingBox()
	local size = Vector3.new(10,10,10)
	local pos = Vector3.new(roomPivot.X, roomPivot.Y - roomSize.Y / 2 + size.Y, roomPivot.Z - roomSize.Z / 2)
	local door = createPart(pos, size, roomModel)
	door.Color = Color3.new(1,1,0)
	door.Material = Enum.Material.Neon

	CollectionService:AddTag(door, 'Interact')
	door:SetAttribute('Role', 'door')
end

function Stage:SpawnRoom()
	local roomModel = Instance.new("Model")
	roomModel.Parent = workspace

	-- размеры будут зависеть от уровня
	local properties = {
		wallsPositionValue = 50,
		wallHeight = 40,
	}

	self:CreateRoom(properties, roomModel)
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
		self.Game.Player.Character:MoveTo(self.Room:GetPivot().Position)
		portModel:Destroy()
	end)

	-- local finishTrigger = Instance.new("Part")
	-- finishTrigger.Parent = workspace
	-- finishTrigger.Position = Vector3.new(0, 5, 0)
	-- finishTrigger.Color = Color3.new(1, 0, 1)
	-- finishTrigger.Size = Vector3.new(10, 10, 10)

	-- finishTrigger.Touched:Connect(function(hitPart)
	-- 	if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
	-- 	self.IsReady = true
	-- 	finishTrigger:Destroy()
	-- end)
end

return Stage

--[[

it's like a hole 

local orientation = pos.X == 0 and (pos.Z > 0 and Vector3.new(0,0,0) or Vector3.new(0,180,0)) or 
                                        pos.Z == 0 and (pos.X > 0 and Vector3.new(0,90,0) or Vector3.new(0,-90,0))
]]
