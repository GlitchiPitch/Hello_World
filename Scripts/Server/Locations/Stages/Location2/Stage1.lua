local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = false

    self.Level = 1

    self.PlayerSpawnPoint = nil
    self:Init()

    return self
end

function Stage:Init()
    print('Stage 1 init')

    self:SpawnRoom()
    if self.Game.Player.Character.HumanoidRootPart and self.PlayerSpawnPoint then
        self.Game.Player.Character.HumanoidRootPart.CFrame = self.PlayerSpawnPoint.CFrame
    end
end


function Stage:SpawnRoom()
    print('Room is created')
    -- возможно переписать без удаления и создания новой комнаты, просто обращаться к меодельке конмнаты и именять позицию и размеры, можно еще это сделать с твином, 
    -- но контент надо удалять или тоже просто пермещать, посмотрим
    local properties = {
        wallsPositionValue = 50 + (50 * .3),
        wallHeight = 15 + (15 * .3)
    }

    local room = self:CreateRoom(properties)
    self:CreateContent(room)
end

function Stage:CreateRoom(properties)

    -- i need to redesigh spawn room function cuz walls must have holes into it
    local value = properties.wallsPositionValue
    local Y = 10
    local wallHeight = properties.wallHeight
    local wallsPositions = {
                {value, Y, 0},
                {0, Y, value},
                {-value, Y, 0},
                {0, Y, -value},
            }
    local model = Instance.new('Model')
    model.Parent = workspace
    -- model:PivotTo(Location.CFrame)  здесь взять центр локации в трех векторах и спавнить по середине эту комнату.
    for i = 1, 6 do
        local wall = Instance.new('Part')
        wall.Parent = model
        wall.Anchored = true
        wall.Color = Color3.new(1,1,1)
        if wallsPositions[i] then 
            wall.Position = Vector3.new(table.unpack(wallsPositions[i]))
            local x, y, z = wall.Position.X == 0 and math.abs(wall.Position.Z) * 2 or 1, wallHeight, wall.Position.Z == 0 and math.abs(wall.Position.X) * 2 or 1
            wall.Size = Vector3.new(x, y, z)
        else
            local _, modelSize = model:GetBoundingBox()
            wall.Position = model:GetPivot().Position + ( i % 2 == 0 and Vector3.new(0, modelSize.Y / 2, 0) or Vector3.new(0, -modelSize.Y / 2, 0) )
            wall.Size = Vector3.new(modelSize.X, 1, modelSize.Z)
        end
    end

    return model
end

function Stage:CreateContent(room)
    -- teleports into rooms walls are spawning here
    -- we need to get walls potision and spawn teleports there
    -- wrong teleports send the player to the spawn point

    local function setupSpawnPoint()
        print('Spawn is created')
        local spawn_ = Instance.new('Part')
        spawn_.Parent = room
        spawn_.Anchored = true
        spawn_.CanCollide, spawn_.CanQuery, spawn_.CanTouch = false, false, false
        spawn_.Material = Enum.Material.Neon
        spawn_.CFrame = room:GetPivot()
        spawn_.CFrame *= CFrame.Angles(math.rad(math.random(0, 2)), 0, math.rad(math.random(0, 2)))
        self.PlayerSpawnPoint = spawn_
    end

    local function createTeleports(size, position)
        local teleport = Instance.new('Part')
        teleport.Parent = room
        teleport.Anchored = true
        teleport.Size = size
        teleport.Position = position
        teleport.Color = Color3.new(0,0,0)
    end

    setupSpawnPoint()
end

return Stage