local Lighting = game:GetService("Lighting")
-- at this stage we will need make a cosmos 


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

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
	self.Map = map
	self.Resourses = resourses
	self.IsReady = false
    self.PlayerSpawnPoint = nil
	self.Keys = {}

	self.PianoSound = Instance.new('Sound') -- if to use sine wave with no length of playing, (the playing of sound is constant, may change playback speed )
	-- self.PianoSound:Stop

    self:Init()
    return self
end

local MAIN_COLOR = Color3.new(0.905882, 0.894117, 0.721568)

function Stage:Init()
    print("stage 1 is started")

	self:SetupStage()
	self:SpawnRoom()
	-- self:ChangeCharacterSize()
	if self.Game.Player.Character.HumanoidRootPart and self.PlayerSpawnPoint then
		self.Game.Player.Character:MoveTo(self.PlayerSpawnPoint.Value)
	end

	repeat wait() until self.IsReady
	self:FinishAction()
	print("stage is ready")
end

function Stage:FinishAction()
    game:GetService('CollectionService'):AddTag(self.Room, 'Heaven')
	self.PianoSound:Destroy()
	for _, key in pairs(self.Keys) do
		key:Destroy()
	end
	self.Event:Disconnect()
end

-- every cube will send pitch for the piano sound i need to calculate pitch for every note 

function Stage:SubscribeEvents()

	local function activatedKey(key)
		key.Material = Enum.Material.Neon
		game:GetService('CollectionService'):RemoveTag(key, 'Interact')
		local tween = game:GetService('TweenService'):Create(key, TweenInfo.new(1), {Color = Color3.new(1,1,1)}) 
		tween:Play()
	end

	local function disabledKeys()
		for _, key in pairs(self.Keys) do
			key.Color, key.Material = Color3.new(0,0,0), Enum.Material.SmoothPlastic
			game:GetService('CollectionService'):AddTag(key, 'Interact')
		end
	end

	local prevIndex = 0
	self.Event = self.Game.Events.Remotes.Interact.OnServerEvent:Connect(function(player,  pitch, key)
		if pitch - prevIndex == 1 then
			prevIndex = pitch
			activatedKey(key)
		else
			prevIndex = 0
			self.PianoSound:Stop()
			disabledKeys()
			return
		end

		self.PianoSound.PlaybackSpeed = pitch
		self.PianoSound:Play()

		if prevIndex == 7 then self.IsReady = true end
	end)
	
end

function Stage:SetupStage()
    Lighting.Ambient, Lighting.OutdoorAmbient = Color3.new(.5,.5,.5), Color3.new(.5,.5,.5)
    Lighting.Brightness, Lighting.ExposureCompensation = 0, 0
    Lighting.ColorShift_Bottom, Lighting.ColorShift_Top = Color3.new(0,0,0), Color3.new(0,0,0)

	self.PianoSound.Looped = true
	self.PianoSound.SoundId = 'rbxassetid://4462044869'
	self.PianoSound.Volume = .1
	self.PianoSound.Parent = self.Game.Player.Character.Head

	self.Game.PlayerManager.SetupCharacter(self.Game.Player, {
		Character = {
			WalkSpeed = 16,
			CanRunning = true
		}, 
	
		Camera = {
			FieldOfView = 60
		}
	})
	self.Game.Player.Character:ScaleTo(.2)

	self:SubscribeEvents()

end

function Stage:SpawnRoom()
    
    self.Room, roomSize, pivot, bottom = self:CreateRoom()
    self:CreateContent(self.Room, roomSize, pivot, bottom)
end

function Stage:CreateContent(room, roomSize, pivot, bottom)
    self.PlayerSpawnPoint = Instance.new('Vector3Value')
    self.PlayerSpawnPoint.Value = room:GetPivot().Position

	local model = Instance.new('Model')
	model.Parent = room

	local startVector = pivot.Position
	local poses = {{1, 0}, {-1, 1}, {-1, -1}, {2, 2}, {2, -2}, {-2, 2}, {-2, -2}}
	for i, pos in pairs(poses) do
		local key = createPart(model, Vector3.new(startVector.X + (10 * pos[1]), bottom.Position.Y + .6,startVector.Z  + (10 * pos[2])), Vector3.new(20,.1,5))
		self:SetupKey(key, i)
	end
end

function Stage:SetupKey(key, index)
	game:GetService('CollectionService'):AddTag(key, 'Interact')
	key:SetAttribute('Role', index)
	key.Color = Color3.new(0,0,0)
	key.Material = Enum.Material.SmoothPlastic
	table.insert(self.Keys, key)
end

function Stage:CreateRoom()

    local roomProperties = {
		roomSize = 100,
		wallHeight = 50
	}

    local sides = { {1, 0}, {-1, 0}, {0, 1}, {0, -1} }
	local model = Instance.new('Model')
	model.Parent = workspace
	local faces = Enum.NormalId:GetEnumItems()
	for i, side in pairs(sides) do
		local pos = Vector3.new(side[1] * roomProperties.roomSize / 2, roomProperties.wallHeight / 2, side[2] * roomProperties.roomSize / 2)
		local size = Vector3.new(side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize), roomProperties.wallHeight, side[1] == 0 and 1 or math.abs(side[1] * roomProperties.roomSize))
		local wall = createPart(model, pos, size)
		wall.Material = Enum.Material.Neon
		wall.Color = MAIN_COLOR

		local light = Instance.new('SurfaceLight')
		light.Parent = wall
		light.Angle = 0
		light.Range = roomProperties.roomSize / 2
		light.Color = MAIN_COLOR
		light.Face = side[2] == 0 and ( i % 2 == 0 and faces[5] or faces[6]) or ( i % 2 == 0 and faces[3] or faces[4])
	end

	local _, roomSize = model:GetBoundingBox()
	local pivot = model:GetPivot()
	local roof = createPart(model, pivot.Position + Vector3.new(0, roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	local bottom = createPart(model, pivot.Position + Vector3.new(0, -roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	roof.Color, bottom.Color = MAIN_COLOR, MAIN_COLOR
	roof.Material, bottom.Material = Enum.Material.Neon, Enum.Material.SmoothPlastic
	roof.Name, bottom.Name = 'roof', 'bottom'

	return model, roomSize, pivot, bottom
end

return Stage