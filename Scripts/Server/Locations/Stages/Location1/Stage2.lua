local Stage = {}

Stage.__index = Stage

function Stage.Create(map)
    local self = setmetatable({}, Stage)

    self.Map = map

    self:Init()

    return self
end

function Stage:Init()
    print('Stage 2 init')
    -- self.Triggers = self.Map:FindFirstChild('Triggers')
end

return Stage