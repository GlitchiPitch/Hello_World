-- police warning module

-- здесь будет попадание на карту основную но с настройками света и нахождением на карте монстра из стэйдж 2
-- надо фиксировать камеру


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
    self:Check()
    repeat wait() until self.IsReady
    self:ShowPoliceWarning()
end

function Stage:Check()
    
end

function Stage:ShowPoliceWarning()
    -- police warning module . warning 1.1
end



return Stage