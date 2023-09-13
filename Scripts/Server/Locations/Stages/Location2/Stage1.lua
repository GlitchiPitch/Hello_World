
local WALL_COLOR = Color3.new(1,1,1)

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
        wallsPositionValue = 50,
        wallHeight = 40
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

    local function createWall(position, size)
            local wall = Instance.new('Part')
            wall.Parent = model
            wall.Anchored = true
            wall.Position = position
            wall.Size = size

            return wall
        end

    local function createCorridor(sidePosition, wallSize)
        local a = 50
        local i = 1
        -- for i = 1, 2 do
        local x = sidePosition.X > 0 and (i % 2 == 0 and sidePosition.X + a or sidePosition.X - a ) or 0
        local z = sidePosition.Z > 0 and (i % 2 == 0 and sidePosition.Z + a or sidePosition.Z - a ) or 0
        local y = sidePosition.Y
        local size = Vector3.new(10,10,10)

        local pos = sidePosition + Vector3.new(x, y, z)

        local wall = createWall(pos, size) -- side
        wall.Color = Color3.new(1,0,0)
        wall.Name = 'cor'
        wall.Parent = workspace
            -- createWall() -- roof or bottom
        -- end

        -- createWall() -- teleport wall
    end
    -- model:PivotTo(Location.CFrame)  здесь взять центр локации в трех векторах и спавнить по середине эту комнату.
    -- возможно как-то можно еще укоротить генер стен обьеденив с 73 по 75 с 78 по 79
    for i = 1, 6 do
        if wallsPositions[i] then 
            local sidePosition = Vector3.new(table.unpack(wallsPositions[i]))

            local x, y, z = sidePosition.X == 0 and math.abs(sidePosition.Z) * 2 or 1, wallHeight, sidePosition.Z == 0 and math.abs(sidePosition.X) * 2 or 1
            local sideSize = Vector3.new(x, y, z)

            local wallSize = Vector3.new(sideSize.X > 1 and sideSize.X / 3 or 1, sideSize.Y, sideSize.Z > 1 and sideSize.Z / 3 or 1)

            createCorridor(sidePosition, wallSize)

            for i = 1, 4 do
                local x = sideSize.X > 1 and (i % 2 == 0 and wallSize.X or -wallSize.X) or 0
                local z = sideSize.Z > 1 and (i % 2 == 0 and wallSize.Z or -wallSize.Z) or 0
                local pos = sidePosition + Vector3.new(x, 0, z)
                createWall(pos, wallSize) 
            end

        else
            local _, modelSize = model:GetBoundingBox()
            local pos = model:GetPivot().Position + ( i % 2 == 0 and Vector3.new(0, modelSize.Y / 2, 0) or Vector3.new(0, -modelSize.Y / 2, 0) )
            local size = Vector3.new(modelSize.X, 1, modelSize.Z)
            createWall(pos, size)
        end
    end

    -- делаем коридоры, градиент на стены от белого к черному и телепорты в конце


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