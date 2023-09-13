
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

    local function createPartOfWall(position, size)
            local wall = Instance.new('Part')
            wall.Parent = model
            wall.Anchored = true
            wall.Position = position
            wall.Size = size
        end
    -- model:PivotTo(Location.CFrame)  здесь взять центр локации в трех векторах и спавнить по середине эту комнату.
    -- возможно как-то можно еще укоротить генер стен обьеденив с 73 по 75 с 78 по 79
    for i = 1, 6 do
        if wallsPositions[i] then 
            local wPos = Vector3.new(table.unpack(wallsPositions[i]))
            local x, y, z = wPos.X == 0 and math.abs(wPos.Z) * 2 or 1, wallHeight, wPos.Z == 0 and math.abs(wPos.X) * 2 or 1
            local wSize = Vector3.new(x, y, z)

            for i = 1, 4 do
                local size = Vector3.new(wSize.X > 1 and wSize.X / 3 or 1, wSize.Y, wSize.Z > 1 and wSize.Z / 3 or 1)
                local x = wSize.X > 1 and (i % 2 == 0 and size.X or -size.X) or 0
                local z = wSize.Z > 1 and (i % 2 == 0 and size.Z or -size.Z) or 0
                local pos = wPos + Vector3.new(x, 0, z)
                createPartOfWall(pos, size) 
            end

        else
            local _, modelSize = model:GetBoundingBox()
            local pos = model:GetPivot().Position + ( i % 2 == 0 and Vector3.new(0, modelSize.Y / 2, 0) or Vector3.new(0, -modelSize.Y / 2, 0) )
            local size = Vector3.new(modelSize.X, 1, modelSize.Z)
            createPartOfWall(pos, size)
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