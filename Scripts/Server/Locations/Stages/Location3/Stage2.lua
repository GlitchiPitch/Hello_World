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
    
end

-- every cube will send pitch for the piano sound i need to calculate pitch for every note 

function Stage:SubscribeEvents()
	self.Game.Events.Remotes.Interact.OnServerEvent:Connect(function(player, role, ...)

	end)
	
end

function Stage:SetupStage()
    Lighting.Ambient, Lighting.OutdoorAmbient = Color3.new(.5,.5,.5), Color3.new(.5,.5,.5)
    Lighting.Brightness, Lighting.ExposureCompensation = 0, 0
    Lighting.ColorShift_Bottom, Lighting.ColorShift_Top = Color3.new(0,0,0), Color3.new(0,0,0)

	-- self.Game.Player.Character:ScaleTo(.2)

end

function Stage:SpawnRoom()
    
    self.Room, roomSize, pivot = self:CreateRoom()
    self:CreateContent(self.Room, roomSize, pivot)
end

function Stage:CreateContent(room, roomSize, pivot)
    self.PlayerSpawnPoint = Instance.new('Vector3Value')
    self.PlayerSpawnPoint.Value = room:GetPivot().Position

	local model = Instance.new('Model')
	model.Parent = room

	local startVector = pivot.Position
	local poses = {{1, 0}, {-1, 1}, {-1, -1}, {2, 2}, {2, -2}, {-2, 2}, {-2, -2}}
	for i, pos in pairs(poses) do
		local key = createPart(model, Vector3.new(startVector.X + (10 * pos[1]), startVector.Y - 15 ,startVector.Z  + (10 * pos[2])), Vector3.new(5,5,5))
		key.Color = Color3.new(0,0,0)
	end
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
	print(faces)
	for i, side in pairs(sides) do
		local pos = Vector3.new(side[1] * roomProperties.roomSize / 2, roomProperties.wallHeight / 2, side[2] * roomProperties.roomSize / 2)
		local size = Vector3.new(side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize), roomProperties.wallHeight, side[1] == 0 and 1 or math.abs(side[1] * roomProperties.roomSize))
		local wall = createPart(model, pos, size)
		-- wall.Material = Enum.Material.Neon
		wall.Color = MAIN_COLOR

		-- local light = Instance.new('SurfaceLight')
		-- light.Parent = wall
		-- light.Angle = 0
		-- light.Range = roomProperties.roomSize / 2
		-- light.Color = MAIN_COLOR
		-- light.Face = side[2] == 0 and ( i % 2 == 0 and faces[5] or faces[6]) or ( i % 2 == 0 and faces[3] or faces[4])
	end

	local _, roomSize = model:GetBoundingBox()
	local pivot = model:GetPivot()
	local roof = createPart(model, pivot.Position + Vector3.new(0, roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	local bottom = createPart(model, pivot.Position + Vector3.new(0, -roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	roof.Color, bottom.Color = MAIN_COLOR, MAIN_COLOR
	-- roof.Material, bottom.Material = Enum.Material.Neon, Enum.Material.SmoothPlastic
	-- roof.Transparency = 1

	return model, roomSize, pivot
end

return Stage