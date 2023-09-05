local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocationResourses = game:GetService('ServerStorage').Resourses.Location1
-- local Maps = ReplicatedStorage:WaitForChild('Maps')
local Location = {}

Location.__index = Location

Location.PlayerProperty = {WalkSpeed = 100, FieldOfView = 20}
Location.Name = 'Location1'

function Location.Create(player, playerManager)
    local self = setmetatable({}, Location)

    self.Player = player
    self.PlayerManager = playerManager
    
    self.Map = Instance.new('Part') -- Maps:FindFirstChild(Location1)
    self.Stages = script.Parent.Stages:FindFirstChild(Location.Name):GetChildren()

    self:Init()

    return self
end

function Location:Init()
    
    self:SetupMap()
    self:SetupStages()

    self.Player:LoadCharacter()
    self.PlayerManager.SetupCharacter(self.Player, Location.PlayerProperty)
end

function Location:SetupMap()
    self.Map.Parent = workspace

end

function Location:SetupStages()
    coroutine.wrap(function()
        for i, stage in pairs(self.Stages) do
            local currentStage = require(stage)
            currentStage.Create(self.Player, self.Map, LocationResourses)
        end
    end)()
end

return Location