local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

	self.Game = game_
	self.Map = map
	self.Resourses = resourses
	self.IsReady = false
	self.Level = 1
    self.Sounds = {}

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
end

function Stage:SpawnRoom()
    self.Room = self:CreateRoom()
    self:CreateContent()
end

function Stage:CreateRoom()
    local value = 5
    local addedVector = Vector3.new(10,10,10)

    local model = Instance.new('Model')
    model.Parent = workspace

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
        part.Color = color or Color3.new(.5,.5,.5)
    end

    local function createLadder(startPos, size)
        createPart(size, startPos, Color3.new(1,0,0))
        for i = 1, value do
            createPart(size, startPos + Vector3.new(0, 2 * i, 0), Color3.new(1,0,0))
            createPart(size, startPos + Vector3.new(0, -2 * i, 0), Color3.new(1,0,0))
        end
    end
    local function createNode(node)
        local size = addedVector - Vector3.new(1,1,1)
        local pos = Vector3.new(table.unpack(node)) * addedVector
        createPart(size, pos)
    end
    for _, node in pairs(nodes) do
        if (node[1] == 1 or node[1] == value) or (node[3] == 1 or node[3] == value) or (node[2] == 1 or node[2] == value) then 
            if (node[1] == 3 and node[2] == 3) or (node[3] == 3 and node[2] == 3) then 
                local size = Vector3.new(node[3] == 3 and 1 or addedVector.X / 2, 1, node[1] == 3 and 1 or addedVector.Z / 2)
                local pos = (Vector3.new(table.unpack(node)) * addedVector) + 
                Vector3.new(
                    node[3] == 3 and (node[1] == 1 and addedVector.X / 2 or -addedVector.X / 2) or 0, 
                    0, 
                    node[1] == 3 and (node[3] == 1 and addedVector.Z / 2 or -addedVector.Z / 2) or 0
                )
                createLadder(pos, size)
            end
            createNode(node)
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