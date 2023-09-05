local Stage = {}

Stage.__index = Stage

function Stage.Create(player, map, resourses)
    local self = setmetatable({}, Stage)

    self.PLayer = player
    self.Map = map
    self.Resourses = resourses

    self:Init()

    return self
end

function Stage:Init()
    print('Stage 1 init')
    self:CreatePets()
    
    -- self.Triggers = self.Map:FindFirstChild('Triggers')
end

function Stage:CreatePets()
    print(self.Resourses)
end

return Stage