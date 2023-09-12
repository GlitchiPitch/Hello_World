local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocationResourses = game:GetService('ServerStorage').Resourses.Location1
-- local Maps = ReplicatedStorage:WaitForChild('Maps')
local Location = {}

Location.__index = Location

Location.PlayerProperty = {
    Character = {
        WalkSpeed = 8
    }, 

    Camera = {
        FieldOfView = 80
    }
}

Location.Name = 'Location1'

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
    print('Start location 1')
    
    self:SetupMap()
    self:SetupStages()

    self.Game.Player:LoadCharacter()
    self.Game.PlayerManager.SetupCharacter(self.Game.Player, Location.PlayerProperty)

    repeat wait() until self.IsReady
    print('Finish location 1')
end

function Location:SetupMap()
    self.Map.Color = Color3.new(0,1,0)
    self.Map.Parent = workspace

end

function Location:SetupStages()
    coroutine.wrap(function()
        for i, stage in pairs(self.Stages:GetChildren()) do
            local currentStage = require(stage)
            currentStage.Create(self.Game, self.Map, LocationResourses)
        end
        self.IsReady = true
    end)()
end

return Location