local Lighting = game:GetService("Lighting")
local Stage = {}

-- dont forget uncomment 38 line about spawn character
-- 119 line
-- надо поиграться с камерой чтобы обзор был похож на 1д игру

-- установить моснтра, если к нему прикоснуться то запуститься предупреждение и пропускается этап 1.3, план б это просто сделать как скример без предположения о последсвтиях

local CLOCK_TIME = 16
local AMBIENT = Color3.fromRGB(10,10,10)
local WALL_COLOR = Color3.new(1,1,1)
local TRIGGER_COLOR = Color3.new(1,1,1)

local MONSTER_COLOR = Color3.new(0.8, 0.5, 0.9)

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
    print('Stage 2 init')
    -- play sounds of turn the light off
    
    self:Setup()
    
    for i = 1, 3 do
        self:SpawnRoom()
        if self.Game.Player.Character.HumanoidRootPart and self.PlayerSpawnPoint then
            self.Game.Player.Character.HumanoidRootPart.CFrame = self.PlayerSpawnPoint.CFrame
        end
        repeat wait() until self.Level > i
    end

    repeat wait() until self.IsReady
    print('Stage 2 is ready')
    -- self.Game.Player:LoadCharacter()
    self.PlayerLight:Destroy()
    -- телепортируем игрока в нужное место на карте
end


function Stage:Setup()
    Lighting.ClockTime = CLOCK_TIME
    Lighting.OutdoorAmbient = AMBIENT
    Lighting.Ambient = AMBIENT

    self:AddLightToCharacter()
end

function Stage:AddLightToCharacter()
    local c = self.Game.Player.Character --or self.Game.Player.CharacterAdded:Wait()
    local head = c:FindFirstChild('Head') --or c:WaitForChild('Head')

    local att= Instance.new('Attachment')
    att.Parent = head
    att.CFrame *= CFrame.new(0,1,0)

    local light = Instance.new('PointLight')
    light.Brightness = .2 -- more ligtly maybe
    light.Shadows = true
    light.Range = 7 -- 10
    light.Parent = att

    self.PlayerLight = att
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
    self:CreateContent(room, properties)
end

function Stage:CreateRoom(properties)
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
        wall.Color = WALL_COLOR
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

function Stage:CreateMonster(properties)
    print('CREATE MONSTER')
    local monster = Instance.new('Part')
    monster.Color = MONSTER_COLOR
    monster.Size = Vector3.new(5, properties.wallHeight, 5)
    monster.Material = Enum.Material.Neon

    return monster
end

function Stage:CreateContent(room, properties)

    local wallSize = 10

    local nodes = {}
    local _, roomSize = room:GetBoundingBox()
    local xQuantity = math.floor(roomSize.X / wallSize * .5)
    local yQuantity = math.floor(roomSize.Z / wallSize * .5)
   
    local x = 1
    local z = 1

    for j = 1, xQuantity do
        for _, i in pairs(
            {{0, z},
            {0, -z},
            {x, 0},
            {-x, 0}}
        ) do
            table.insert(nodes, room:GetPivot().Position + Vector3.new(i[1] * wallSize, 0, i[2] * wallSize))
        end
        z += 1
        x += 1
    end

    for z = 1, xQuantity do
        for x = 1, yQuantity do
            for _, i in pairs({
                {x, z},
                {-x, z},
                {x, -z},
                {-x, -z},
            }) do
                table.insert(nodes, room:GetPivot().Position + Vector3.new(i[1] * wallSize, 0, i[2] * wallSize))
            end
        end
    end

    -- print(nodes)
    local function setupTarget(target)

        target.Material = Enum.Material.Neon
        target.Color = TRIGGER_COLOR
        target.Size = Vector3.new(5, properties.wallHeight, 5)
        target.Touched:Connect(function(hitPart)
            if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
            self.Level += 1
            target:Destroy()
            room:Destroy()
        end)
    end

    local function setupSpawnPoint(spawn_)
        print('Spawn is created')
        spawn_.CanCollide, spawn_.CanQuery, spawn_.CanTouch = false, false, false
        spawn_.Transparency = 1
        spawn_.CFrame *= CFrame.Angles(math.rad(math.random(0, 2)), 0, math.rad(math.random(0, 2)))
        self.PlayerSpawnPoint = spawn_
    end

    local function setupBarrier(barrier)
        barrier.Color = WALL_COLOR
        local size = {{wallSize - 2, properties.wallHeight, 1}, {1, properties.wallHeight, wallSize - 2}}
        barrier.Size = Vector3.new(table.unpack(size[math.random(#size)]))
        barrier.CanCollide = false
        barrier.Transparency = 1
    end
    local function createPart(name)
        local part = Instance.new('Part')
        part.Parent = room
        part.Name = name
        part.Anchored = true

        if name == 'target' then
            setupTarget(part)
        elseif name == 'spawn' then
            setupSpawnPoint(part)
        elseif name == 'barrier' then
            setupBarrier(part)
        end

        return part
    end
    local a = math.random(1,10) --math.random(#nodes)
    local spawnIndex = a  
    a = math.random(#nodes / 2, #nodes)
    local targetIndex = a -- spawnIndex ~= a and a or  a - 1

    local monsterIndex = targetIndex - 1

    for i, pos in pairs(nodes) do
        local part
        if i == spawnIndex then
            part = createPart('spawn')
        elseif i == targetIndex then
            if self.Level == 3 then
                local portal = self:CreatePortal(properties, room)
                portal.Parent = room
                part = portal
            else
                part = createPart('target')
            end
        elseif i == monsterIndex and self.Level == 3 then
            local monster = self:CreateMonster(properties)
            monster.Parent = room
            part = monster
        else
            part = createPart('barrier')
        end
        part.Position = pos
    end
end

function Stage:CreatePortal(properties, room)
    print('Portal is created')
    local portal = Instance.new('Part')
    portal.Color = Color3.new(0,1,0)
    portal.Material = Enum.Material.Neon
    portal.Size = Vector3.new(5, properties.wallHeight, 5)
    portal.Touched:Connect(function(hitPart)
        if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
            self.Level += 1
            portal:Destroy()
            room:Destroy()
            self.IsReady = true
    end)

    return portal
end

return Stage


--[[

for j = 1, xQuantity do
        for h = 1, yQuantity do
            for _, i in pairs({
                {x, z},
                {-x, z},
                {x, -z},
                {-x, -z},
                {0, z},
                {0, -z},
                {x, 0},
                {-x, 0},
            }) do
                table.insert(nodes, room:GetPivot().Position + Vector3.new(i[1] * wallSize, 0, i[2] * wallSize))      
            end
            x += 1
        end
        z += 1
    end


]]