local Lighting = game:GetService("Lighting")

local START_COLOR = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1)}
START_COLOR = START_COLOR[math.random(#START_COLOR)]
-- when room's color will be more equals gray then camera and speed of player will become more claim and slowly and sounds become quietly

-- можно заюзать ближе к выолнению задания выбор рандомного цвета для каждой ячейки и через твин анимировать изменение каждой ячейки с увеличением звука и цвета и света


local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, map, resourses, portal)
    local self = setmetatable({}, Stage)

	self.Game = game_
	self.Map = map
	self.Resourses = resourses
	self.IsReady = true
	self.Level = 1
    self.Sounds = {}
    self.StagePortal = portal
	self.PlayerSpawnPoint = nil
	self:Init()

	return self
end

function Stage:Init()
    print("Stage 1.1 init")
    -- self:Setup()
	self:SpawnRoom()
	if self.Game.Player.Character.HumanoidRootPart and self.PlayerSpawnPoint then
		self.Game.Player.Character.HumanoidRootPart.CFrame = self.PlayerSpawnPoint.CFrame
	end

    repeat wait() until self.IsReady
    self:FinishAction()
    print('stage is done')
end

function Stage:FinishAction()
    self.Game.Player.Character:MoveTo(self.StagePortal.Position)
    self.Room:Destroy()
    self.StagePortal:Destroy()
end

function Stage:SpawnRoom()
    self.RoomColor = START_COLOR
    self.Room = self:CreateRoom()
    self:CreateContent()
end

function Stage:ChangeStage(color)
    -- print('change')
    for _, obj in pairs(self.Room:GetChildren()) do
        if obj:IsA('Part') then
            local prevColor = obj.Color
            obj.Color = self:CalculateColor(prevColor, color)
        end
    end

    -- self:ChangeLighting(color)
    self:ChangePlayerCamera()
    print(self.RoomColor)
    if self.RoomColor == Color3.new(.5,.5,.5) then
        self.IsReady = true
    end
end

function Stage:ChangePlayerCamera()
    self.Game.PlayerManager.SetupCharacter(self.Game.Player, {Character = {WalkSpeed = math.random(20, 100)}, Camera = {FieldOfView = math.random(80, 200)}})
    
end

-- for calculating colors use hsv or :lerp

function Stage:CalculateColor(prevColor, color)

    local value = .1

    if color == Color3.new(0, 0, 0) then value = -value end

    -- local nextColor = prevColor
    -- nextColor = Color3.new(math.floor(nextColor.R), math.floor(nextColor.G), math.floor(nextColor.B))
    local nextColor = Color3.new(
        (color.R == 1 and prevColor.R + (prevColor.R < 1 and value or -value)) or 
        (value < 0 and (prevColor.R > 0 and prevColor.R + value) or prevColor.R),

        (color.G == 1 and prevColor.G + (prevColor.G < 1 and value or -value)) or 
        (value < 0 and (prevColor.G > 0 and prevColor.G + value) or prevColor.G),

        (color.B == 1 and prevColor.B + (prevColor.B < 1 and value or -value)) or 
        (value < 0 and (prevColor.B > 0 and prevColor.B + value) or prevColor.B)
    )
    self.RoomColor = nextColor
    return nextColor
end

function Stage:ChangeLighting(color)
    Lighting.Ambient = self:CalculateColor(Lighting.Ambient, color)
    Lighting.OutdoorAmbient = self:CalculateColor(Lighting.OutdoorAmbient, color)
    -- Lighting.Brightness = 10
end

function Stage:CreateRoom()
    local value = 7
    local addedVector = Vector3.new(30,30,30)

    local model = Instance.new('Model')
    model.Parent = workspace

    local voids = Instance.new('Folder')
    voids.Parent = model

    local function createNodes()
        local nodes = {}
        for x = 1, value do
            for z = 1, value do
                for y = 1, value do
                    table.insert(nodes, {x, y, z})
                end
            end
        end
        return nodes
    end

    local nodes = createNodes()
    local function createPart(size, pos, color)
        local part = Instance.new('Part')
        part.Parent = model
        part.Anchored = true
        part.Size = size
        part.Position = pos
        part.Color = color or START_COLOR

        return part
    end

    -- need use math.floor for conditions
    local function createLadder(node)
        if (node[1] == 4 and node[2] == 4) or (node[3] == 4 and node[2] == 4) then 
            local size = Vector3.new(node[3] == 4 and 1 or addedVector.X, 1, node[1] == 4 and 1 or addedVector.Z)
            local pos = (Vector3.new(table.unpack(node)) * addedVector) + 
            Vector3.new(
                node[3] == 4 and (node[1] == 1 and addedVector.X / 2 or -addedVector.X / 2) or 0, 
                0, 
                node[1] == 4 and (node[3] == 1 and addedVector.Z / 2 or -addedVector.Z / 2) or 0
            )
            createPart(size, pos)
            for i = 1, value ^ 2 do
                createPart(size, pos + Vector3.new(0, 2 * i, 0))
                createPart(size, pos + Vector3.new(0, -2 * i, 0))
            end
        end
    end

    local voidColor = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(0,0,0), Color3.new(1,1,1)}
    local colorIndex = 1

    local function createVoid(node)
        -- for second step
        -- (node[1] == 2 or node[1] == value - 1) and (node[3] ~= 1 or node[3] ~= value) and node[3] % 2 == 1 or (node[3] == 2 or node[3] == value - 1) and (node[1] ~= 1 or node[1] ~= value) and node[1] % 2 == 1 

        local function setupVoid(void)
            if colorIndex > #voidColor then
                colorIndex = 1
            end
            void.Color = voidColor[colorIndex]
            colorIndex += 1
            void.Parent = voids
            void.Touched:Connect(function(hitPart)
                if self.Game.Player.Character == hitPart.Parent then
                    void.CanTouch = false
                    self.Game.Player.Character:MoveTo(self.PlayerSpawnPoint.Position)
                    self:ChangeStage(void.Color)
                    self.Level += 1
                    task.wait(1)
                    void.CanTouch = true
                end
            end)
        end

        if (node[1] == 1 or node[1] == value) and (node[3] > 1 and node[3] < value) and (node[3] % 2 == 1) or 
        (node[3] == 1 or node[3] == value) and (node[1] > 1 and node[1] < value) and (node[1] % 2 == 1) then
            if (node[2] > 1 and node[2] < value) and (node[2] % 2 == 1) then
                    local size = addedVector - 
                    Vector3.new(
                        (node[1] == 1 or node[1] == value) and addedVector.X - 1 or 0,
                        0, 
                        (node[3] == 1 or node[3] == value) and addedVector.Z - 1 or 0
                    )
                    local pos = Vector3.new(table.unpack(node)) * addedVector
                    setupVoid(createPart(size, pos))
                    return true 
            end
        end
        return false
    end

    local function createNode(node)
        local size = addedVector
        local pos = Vector3.new(table.unpack(node)) * addedVector
        createPart(size, pos)
    end
    for _, node in pairs(nodes) do
        if (node[1] == 1 or node[1] == value) or (node[3] == 1 or node[3] == value) or (node[2] == 1 or node[2] == value) then 
            createLadder(node)
            if createVoid(node) then
                continue
            else
                createNode(node)
            end
        end
    end

    return model
end

function Stage:CreateContent()

    local function setupSpawnPoint()
		print("Spawn is created")
		local spawn_ = Instance.new("Part")
		spawn_.Parent = self.Room
		spawn_.Anchored = true
		spawn_.CanCollide, spawn_.CanQuery, spawn_.CanTouch = false, false, false
		spawn_.Material = Enum.Material.Neon
		spawn_.CFrame = self.Room:GetPivot()
		spawn_.CFrame *= CFrame.Angles(math.rad(math.random(0, 2)), 0, math.rad(math.random(0, 2)))
		self.PlayerSpawnPoint = spawn_
	end

	setupSpawnPoint()
end

return Stage