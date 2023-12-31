local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")


-- fix color correction
-- fix gradient
-- передать в этап 1_1 последний цвет комнаты
-- телепорт на следующую комнату будет как vpx портал ведущий на локацию2.1

local SOUND_LEVELS = 4
local COLOR_LEVELS = SOUND_LEVELS + 4
local RIGHT_ORDER = {4, 2, 3, 1, 2, 1, 2, 1}

local url = "rbxassetid://"
local SOUNDS_ID = { url .. 9112854440, url .. 9114625745, url .. 9112775175, url .. 9125351901}

local AMBIENT = Color3.new(.2,.2,.2)

local WALL_COLOR = Color3.new(1, 0, 0)

local Stage = {}

Stage.__index = Stage

function Stage.Create(location)
	local self = setmetatable({}, Stage)

	self.Location = location
	self.Game = location.Game
	self.IsReady = true
	self.Level = 1
    self.Sounds = {}
	self.StagePortal = location.CurrentPortal

	self.PlayerSpawnPoint = nil
	self:Init()

	return self
end

function Stage:Init()
	print("Stage 1 init")
    self:Setup()
	self:SpawnRoom()
	if self.Game.Player.Character.HumanoidRootPart and self.PlayerSpawnPoint then
		self.Game.Player.Character.HumanoidRootPart.CFrame = self.PlayerSpawnPoint.CFrame
	end

    repeat wait() until self.IsReady
	self:FinishAction()
    print('finish stage')
end

function Stage:FinishAction()
	local portal = Instance.new('Part')
	portal.Parent = self.Room
	portal.Size = Vector3.new(10,15,10)
	portal.Anchored = true
	portal.Position = self.Room:GetPivot().Position - Vector3.new(0, portal.Size.Y / 2, 0)

	portal.Touched:Connect(function(hitPart)
		local player = game.Players:GetPlayerFromCharacter(hitPart.Parent)
		if not player then return end
		self.Room:Destroy()

		for _, obj in pairs(self.Teleports) do
			obj:Destroy()
		end
		require(script.Parent.Stage1_1).Create(self.Location)
	end)
end

function Stage:Setup()
    Lighting.FogStart = 20
    Lighting.ClockTime = 21
    Lighting.OutdoorAmbient = AMBIENT

	self.RightChoice = false

    self:CreateSounds()
end

function Stage:CreateSounds()
    for _, soundId in pairs(SOUNDS_ID) do
        local sound = Instance.new('Sound')
        sound.Volume = .1
        sound.SoundId = soundId
        sound.Parent = SoundService
        table.insert(self.Sounds, sound)
    end
end

function Stage:ChangeLevel()
    print('Change level')
    if self.RightChoice and self.Level <= SOUND_LEVELS then
        for i = 1, self.Level do
            if self.Sounds[i].Playing then continue end
            self.Sounds[i]:Play()   
        end
		self.Level += 1
    elseif self.RightChoice and self.Level >= SOUND_LEVELS and self.Level <= COLOR_LEVELS then
        for _, object in pairs(self.Room:GetDescendants()) do
            if object:IsA('Part') then 
				object.Color = Color3.new(object.Color.R + (object.Color.R * .2), object.Color.G + (object.Color.G * .2), object.Color.B + (object.Color.B * .2))
			end
        end
		self.Level += 1
    else
        for _, sound in pairs(self.Sounds) do
            print('stop sound')
            sound:Stop()
        end
        for _, object in pairs(self.Room:GetDescendants()) do
            print('remove color')
            if object:IsA('Part') then object.Color = WALL_COLOR end
        end
		self.Level = 1
    end

    if self.Level == 8 then self.IsReady = true end
end

function Stage:SpawnRoom()
	print("Room is created")
	-- возможно переписать без удаления и создания новой комнаты, просто обращаться к меодельке конмнаты и именять позицию и размеры, можно еще это сделать с твином,
	-- но контент надо удалять или тоже просто пермещать, посмотрим
	local properties = {
		wallsPositionValue = 50,
		wallHeight = 40,
	}

	self.Room, self.Teleports = self:CreateRoom(properties)
	self:CreateContent(self.Room)
end

function Stage:CreateRoom(properties)
	-- next rooms will be have more holes into walls
	-- perhaps replace illsuion func to change player gui or lighting for more darker ambient
	-- i need to redesigh spawn room function cuz walls must have holes into it
	local value = properties.wallsPositionValue
	local Y = 10
	local wallHeight = properties.wallHeight
	local wallsPositions = {
		{ value, Y, 0 },
		{ 0, Y, value },
		{ -value, Y, 0 },
		{ 0, Y, -value },
	}
	local model = Instance.new("Model")
	model.Parent = workspace

	local function createWall(position, size)
		local wall = Instance.new("Part")
		wall.Parent = model
		wall.Anchored = true
		wall.Position = position
		wall.Size = size

		return wall
	end

	local teleportList = {}
	local function setupIllusionSurface(illusionWall)
		illusionWall.Parent = workspace -- other parent
		illusionWall.CanCollide = false
		illusionWall.Transparency = 1
		table.insert(teleportList, illusionWall)
		local surface = Instance.new("SurfaceGui")
		surface.Parent = illusionWall
		local solid = Instance.new("Frame")
		solid.Parent = surface
		solid.BackgroundColor3 = Color3.new(0, 0, 0)
		solid.Size = UDim2.fromScale(1, 1)
		surface.Face = illusionWall.Size.X > 1
				and (illusionWall.Position.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front)
			or illusionWall.Size.Z > 1
				and (illusionWall.Position.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left)
	end

	local function createWallGradient(wall)
		local surface = Instance.new("SurfaceGui")
		surface.Parent = wall
		local frame = Instance.new("Frame")
		frame.Parent = surface
		frame.Size = UDim2.fromScale(1, 1)
		local gradient = Instance.new("UIGradient")
		gradient.Parent = frame

		gradient.Color = ColorSequence.new(wall.Color, Color3.new(0, 0, 0))

		surface.Face = wall.Size.X > 1 and (wall.Position.Z > 0 and Enum.NormalId.Back or Enum.NormalId.Front)
			or wall.Size.Z > 1 and (wall.Position.X > 0 and Enum.NormalId.Right or Enum.NormalId.Left)
	end
    local corridorFolder = Instance.new('Folder')
	local function setupCorridorPart(wall)
		wall.Color = Color3.new(1, 0, 0)
		wall.Parent = corridorFolder
		createWallGradient(wall)
	end
    
	local function setupTeleport(teleport, index)
		if teleport.Size.X > 1 then
			teleport:SetAttribute(
				"TeleportFace",
				teleport.Position.Z > 0 and Enum.NormalId.Back.Name or Enum.NormalId.Front.Name
			)
			teleport:SetAttribute(
				"TeleportPos",
				teleport.Position
					+ (
						teleport.Position.Z > 0 and Vector3.new(0, 0, -20)
						or Vector3.new(0, 0, 20)
					)
			)
            elseif teleport.Size.Z > 1 then
                teleport:SetAttribute(
                    "TeleportFace",
                    teleport.Position.X > 0 and Enum.NormalId.Right.Name or Enum.NormalId.Left.Name
                )
                teleport:SetAttribute(
                    "TeleportPos",
                    teleport.Position
					+ (
                        teleport.Position.X > 0 and Vector3.new(-20, 0, 0)
						or Vector3.new(20, 0, 0)
					)
                )
            end
        teleport:SetAttribute('Order', index)
        teleport.Name = teleport:GetAttribute('TeleportFace')
        teleportList[teleport.Name] = teleport
        teleport.Touched:Connect(function(hitPart)
            local player = game.Players:GetPlayerFromCharacter(hitPart.Parent)
            if not player then return end
            teleport.CanTouch = false
            player.Character:MoveTo(
            (teleport.Name or teleport:GetAttribute('TeleportFace')) == 'Front' and teleportList['Back']:GetAttribute('TeleportPos') or 
            (teleport.Name or teleport:GetAttribute('TeleportFace')) == 'Back' and teleportList['Front']:GetAttribute('TeleportPos') or
            (teleport.Name or teleport:GetAttribute('TeleportFace')) == 'Right' and teleportList['Left']:GetAttribute('TeleportPos') or
            (teleport.Name or teleport:GetAttribute('TeleportFace')) == 'Left' and teleportList['Right']:GetAttribute('TeleportPos')
            )
            print(teleport:GetAttribute('Order'))
            self.RightChoice = RIGHT_ORDER[self.Level] == teleport:GetAttribute('Order') and true or false
            self:ChangeLevel()
            task.wait(1)
            teleport.CanTouch = true
        end)

		-- for _, obj in pairs(teleportList) do
        --     if obj:GetAttribute('Order') == 1 then obj.Color = Color3.new(1,0,0) end
        --     if obj:GetAttribute('Order') == 2 then obj.Color = Color3.new(0,1,0) end
        --     if obj:GetAttribute('Order') == 3 then obj.Color = Color3.new(0,0,1) end
        --     if obj:GetAttribute('Order') == 4 then obj.Color = Color3.new(1,1,1) end
        -- end
	end
	local function createCorridor(sidePosition, holeSize, index)
		local corridorLength = 50

		local x = sidePosition.X > 0 and sidePosition.X + corridorLength / 2
			or sidePosition.X < 0 and sidePosition.X - corridorLength / 2
		local z = sidePosition.Z > 0 and sidePosition.Z + corridorLength / 2
			or sidePosition.Z < 0 and sidePosition.Z - corridorLength / 2
		local y = sidePosition.Y / 2

		local centralPos = Vector3.new(x, y, z)

		setupIllusionSurface(createWall(sidePosition, holeSize))

		for i = 1, 2 do
			local x1 = (sidePosition.Z > 0 or sidePosition.Z < 0) and (i % 2 == 0 and holeSize.X / 2 or -holeSize.X / 2)
				or 0
			local z1 = (sidePosition.X > 0 or sidePosition.X < 0) and (i % 2 == 0 and holeSize.Z / 2 or -holeSize.Z / 2)
				or 0
			local pos = centralPos + Vector3.new(x1, y, z1)

			local z1s = (sidePosition.Z > 0 or sidePosition.Z < 0) and corridorLength or 1
			local x1s = (sidePosition.X > 0 or sidePosition.X < 0) and corridorLength or 1

			local size = Vector3.new(x1s, holeSize.Y, z1s)

			setupCorridorPart(createWall(pos, size)) -- side

			local y1 = i % 2 == 0 and sidePosition.Y + holeSize.Y / 2 or sidePosition.Y - holeSize.Y / 2
			local pos = Vector3.new(centralPos.X, y1, centralPos.Z)
			local z2s = (sidePosition.Z > 0 or sidePosition.Z < 0) and corridorLength or holeSize.Z
			local x2s = (sidePosition.X > 0 or sidePosition.X < 0) and corridorLength or holeSize.X
			local size = Vector3.new(x2s, 1, z2s)
			setupCorridorPart(createWall(pos, size)) -- roof or bottom
		end
		local w3 = createWall(centralPos * 1.2, holeSize) -- teleport wall ( its not good because .38 )
		w3.Parent = workspace
		w3.Color = Color3.new(0, 0, 0)
        setupTeleport(w3, index)
	end
	-- model:PivotTo(Location.CFrame)  здесь взять центр локации в трех векторах и спавнить по середине эту комнату.
	-- возможно как-то можно еще укоротить генер стен обьеденив с 73 по 75 с 78 по 79
	for i = 1, 6 do
		if wallsPositions[i] then
			local sidePosition = Vector3.new(table.unpack(wallsPositions[i]))

			local x, y, z =
				sidePosition.X == 0 and math.abs(sidePosition.Z) * 2 or 1,
				wallHeight,
				sidePosition.Z == 0 and math.abs(sidePosition.X) * 2 or 1
			local sideSize = Vector3.new(x, y, z)

			local wallSize =
				Vector3.new(sideSize.X > 1 and sideSize.X / 3 or 1, sideSize.Y, sideSize.Z > 1 and sideSize.Z / 3 or 1)

			createCorridor(sidePosition, wallSize, i)

			for i = 1, 2 do
				local x = sideSize.X > 1 and (i % 2 == 0 and wallSize.X or -wallSize.X) or 0
				local z = sideSize.Z > 1 and (i % 2 == 0 and wallSize.Z or -wallSize.Z) or 0
				local pos = sidePosition + Vector3.new(x, 0, z)
				createWall(pos, wallSize)
			end
		else
			local _, modelSize = model:GetBoundingBox()
			local pos = model:GetPivot().Position
				+ (i % 2 == 0 and Vector3.new(0, modelSize.Y / 2, 0) or Vector3.new(0, -modelSize.Y / 2, 0))
			local size = Vector3.new(modelSize.X, 1, modelSize.Z)
			createWall(pos, size)
		end
	end
    for _, obj in pairs(corridorFolder:GetChildren()) do
        obj.Parent = model
    end
	corridorFolder:Destroy()
	return model, teleportList
end

function Stage:CreateContent(room)

	local function setupSpawnPoint()
		print("Spawn is created")
		local spawn_ = Instance.new("Part")
		spawn_.Parent = room
		spawn_.Anchored = true
		spawn_.CanCollide, spawn_.CanQuery, spawn_.CanTouch = false, false, false
		spawn_.Material = Enum.Material.Neon
		spawn_.CFrame = room:GetPivot()
		spawn_.CFrame *= CFrame.Angles(math.rad(math.random(0, 2)), 0, math.rad(math.random(0, 2)))
		self.PlayerSpawnPoint = spawn_
	end

	setupSpawnPoint()
end

return Stage

--[[

если развить то можно получить неплохой вариант генерации множества комнат

local a = 50
        for i = 1, 2 do
            local x = sidePosition.X > 0 and (i % 2 == 0 and sidePosition.X + a or sidePosition.X - a ) or 0
            local z = sidePosition.Z > 0 and (i % 2 == 0 and sidePosition.Z + a or sidePosition.Z - a ) or 0
            local y = sidePosition.Y
            local size = Vector3.new(10,10,10)

            local pos = sidePosition + Vector3.new(x, y, z)

            local wall = createWall(pos, size) -- side
            wall.Color = Color3.new(1,0,0)
            wall.Name = 'cor'
            -- createWall() -- roof or bottom
        end

]]
