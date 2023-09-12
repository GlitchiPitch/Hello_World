local Lighting = game:GetService("Lighting")

local CLOCK_TIME = 14
local AMBIENT = Color3.new(.5,.5,.5)


local Location = {}

Location.Name = 'Location2'

Location.PlayerProperty = {
    Character = {
        WalkSpeed = 10,
        CanRunning = false
    },
    Camera = {
        FieldOfView = 80
    }
}


Location.__index = Location

function Location.Create(game_)
    local self = setmetatable({}, Location)

    self.Game = game_

    self.Map = Instance.new('Part') -- Maps:FindFirstChild(Location1)
    self.Stages = script.Parent.Stages:FindFirstChild(Location.Name) --:GetChildren()

    self.IsReady = false

    self:Init()

    return self
end

function Location:Init()
    print('Location 2 start')

    self:SetupMap()

    self.Game.PlayerManager.SetupCharacter(self.Game.Player, Location.PlayerProperty)

    repeat wait() until self.IsReady
    print('Location 2 is ready')
end

function Location:SetupMap()
    self.Map.Color = Color3.new(0,1,1)
    self.Map.Parent = workspace
end

function Location:Setup()
    Lighting.ClockTime = CLOCK_TIME
    Lighting.OutdoorAmbient = AMBIENT
    Lighting.Ambient = AMBIENT
end

return Location