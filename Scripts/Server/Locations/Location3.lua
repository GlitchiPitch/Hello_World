
local ServerScriptService = game:GetService('ServerScriptService')
local LocationResourses = game:GetService('ServerStorage').Resourses.Location3

-- next stages without portal and something like these
-- probably signals from previous location must be connected with this location idk how but it's only idea
-- a map in this location will be used for stages

local Location = {}

Location.Name = 'Location3'

Location.__index = Location

Location.PlayerProperty = {
    Character = {
        WalkSpeed = 8,
        CanRunning = false
    }, 

    Camera = {
        FieldOfView = 120
    }
}

function Location.Create(_game)
    local self = setmetatable({}, Location)

    self.Game = _game
    self.Map = Instance.new('Part')
    -- self.Resourses = LocationResourses
    self.Events = self.Game.Events

    self.Stages = ServerScriptService.Stages:FindFirstChild(Location.Name)
    self.StageIndex = 1
    self.IsReady = false

    self:Init()

    return self
end

function Location:Init()
    print('Location 3 start')
    
    self.Game.Player:LoadCharacter()
    self.Game.PlayerManager.SetupCharacter(self.Game.Player, Location.PlayerProperty)
    self:SetupStages()

    repeat wait() until self.IsReady
    print('Location 3 is over')

end


function Location:SetupStages()
    for i, stage in pairs(self.Stages:GetChildren()) do
        require(stage).Create(self)
    end
end

return Location