local Lighting = game:GetService("Lighting")
local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = false

    self:Init()

    return self
end

function Stage:Init()
    print('Stage 2 init')
    -- play sounds of turn the light off
    Lighting.ClockTime = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(25,25,25)
    Lighting.Ambient = Color3.fromRGB(50,50,50)
    -- self.Triggers = self.Map:FindFirstChild('Triggers')
    self:SpawnRoom()
end

function Stage:SpawnRoom() -- called 3 times
    local propList = {
        Walls = {
            Positions = {
                {10, 10, 0},
                {-10, 10, 0},
                {0, 10, 10},
                {0, 10, -10},
            },
            Sizes = {

            }
        }
    }
    for i = 1, 4 do
        local wall = Instance.new('Part')
        wall.Parent = workspace
        wall.Anchored = true
        wall.Material = Enum.Material.Neon
        wall.Color = Color3.new(0.8, 0.5, 0.9)
        wall.Position = Vector3.new(table.unpack(propList.Walls.Positions[i]))
        wall.Size = Vector3.new(5, 10, 5)
    end    
end

return Stage