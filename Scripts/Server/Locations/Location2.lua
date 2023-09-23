local Lighting = game:GetService("Lighting")

local LocationResourses = game:GetService('ServerStorage').Resourses.Location2

local CLOCK_TIME = 14
local AMBIENT = Color3.new(.5,.5,.5) -- change ambient gets more lightly and sunny

-- roof into the map is black

-- это локация 1.2 но для удобство использования цикла нумеруем лкоации по порядку


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
    self.Stages = script.Parent.Stages:FindFirstChild(Location.Name)
    self.StageIndex = 1
    self.IsReady = false

    self.Event = Instance.new('BindableEvent')

    self:Init()

    return self
end

function Location:Init()
    print('Location 2 start')

    self:Setup()

    self.Game.Player:LoadCharacter() -- this is temporary solution
    self.Game.PlayerManager.SetupCharacter(self.Game.Player, Location.PlayerProperty)

    -- self.Event.Event:Connect(function()
    --     print('event')
    --     self.IsReady = true
    -- end)

    repeat wait() until self.IsReady
    print('Location 2 is ready')
end

function Location:Setup()
    self.Map.Color = Color3.new(0,1,1)
    self.Map.Parent = workspace

    Lighting.ClockTime = CLOCK_TIME
    Lighting.OutdoorAmbient = AMBIENT
    Lighting.Ambient = AMBIENT

    self:CreatePortals()

end

-- function Location:SetupStages()
--     coroutine.wrap(function()
--         for i, stage in pairs(self.Stages:GetChildren()) do
--             local currentStage = require(stage)
--             currentStage.Create(self.Game, self.Map, LocationResourses)
--         end
--         self.IsReady = true
--     end)()
-- end

function Location:CreatePortals()
    for i = 1, 2 do
        local portal = Instance.new('Part')
        portal.Parent = self.Map
        portal.Size = Vector3.new(5,10,5)
        portal.Color = Color3.new(1,1,1)
        portal.Anchored = true
        portal.Material = Enum.Material.Neon
        portal.CanCollide = false

        local rand = math.random
        portal.Position = Vector3.new(rand(-100, 90), -50, rand(-60, 50))

        
        portal.Touched:Connect(function(hitPart)
            if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
            portal.CanTouch = false
            local currentStage = require(self.Stages:FindFirstChild('Stage' .. self.StageIndex))
            -- if self.StageIndex == 2 then currentStage.Create(self.Game, self.Map, LocationResourses, portal, self)
            -- else currentStage.Create(self.Game, self.Map, LocationResourses, portal) end
            currentStage.Create(self.Game, self.Map, LocationResourses, portal)
            self.StageIndex += 1
        end)
    end
    -- порталы буду тспавниться на определенных точках но пока рандом

    -- можно взять вью порты потом сделать на их основе картинки и повесить их на парты как декал. это план б
    -- план а это сделать небольшие декорации за картой, которые будут имитировать локацию 2.1
end



return Location