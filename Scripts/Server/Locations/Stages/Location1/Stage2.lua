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
end

return Stage