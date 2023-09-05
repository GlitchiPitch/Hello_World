local TRIGGER_NAME = 'Saved'

local Stage = {}
Stage.__index = Stage

function Stage.Create(player, map, resourses, gameEvents)
    local self = setmetatable({}, Stage)

    self.GameEvents = gameEvents
    self.Player = player
    self.Map = map
    self.Resourses = resourses

    self:Init()

    return self
end

function Stage:Init()
    print('Stage 1 init')
    self:Pets()
    
    -- self.Triggers = self.Map:FindFirstChild('Triggers')
end

function Stage:Pets()
    -- get pets
    -- spawn in random places
    local function setup(pet)
        -- surface gui 
        -- position
        -- tag

        local triggered = Instance.new('BoolValue')
        triggered.Parent = pet
        triggered.Name = TRIGGER_NAME

        triggered.Changed:Connect(function(value)
            if value then self.GameEvents.Remotes.UpdateClient:FireClient(self.Player) end
        end)

        task.wait(10)

        triggered.Value = true
    end

    -- for i, pet in pairs(petsList) do
    for i = 1, 10 do
        local pet = Instance.new('Part')
        pet.Parent = workspace
        pet.Position = Vector3.new(0.6, 50.5, 12)
        setup(pet)

        wait(5)
    end     
end



return Stage