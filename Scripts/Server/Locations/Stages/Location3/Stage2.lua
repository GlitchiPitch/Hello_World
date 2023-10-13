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

function Stage:SetupStage()
    Lighting.Ambient, Lighting.OutdoorAmbient = Color3.new(0,0,0), Color3.new(0,0,0)
    Lighting.Brightness, Lighting.ExposureCompensation = 0, 0
    Lighting.ColorShift_Bottom, Lighting.ColorShift_Top = Color3.new(0,0,0), Color3.new(0,0,0)
end

function Stage:SpawnRoom()
    
    self.Room = self:CreateRoom()
    self:CreateContent(self.Room)
end

function Stage:CreateContent(room)
    self.PlayerSpawnPoint = Instance.new('Vector3Value')
    self.PlayerSpawnPoint.Value = room:GetPivot().Position
end

function Stage:CreateRoom()

    local roomProperties = {
		roomSize = 100,
		wallHeight = 50
	}

    local sides = { {1, 0}, {-1, 0}, {0, 1}, {0, -1} }
	local model = Instance.new('Model')
	model.Parent = workspace
	for _, side in pairs(sides) do
		local pos = Vector3.new(side[1] * roomProperties.roomSize / 2, roomProperties.wallHeight / 2, side[2] * roomProperties.roomSize / 2)
		local size = Vector3.new(side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize), roomProperties.wallHeight, side[1] == 0 and 1 or math.abs(side[1] * roomProperties.roomSize))
		createPart(model, pos, size)
	end
end

return Stage