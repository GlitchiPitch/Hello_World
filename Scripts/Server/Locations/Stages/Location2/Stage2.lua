local Stage = {}

-- этап где будет много дурок в стенах и туда надо подниматься по лестницам, каждая дырка меняет цвет на карте, надо вернуть серый цвет, а так будет лютый писходел и лайтингд будет выжигать глаза

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = false

    self.Level = 1

    self.PlayerSpawnPoint = nil
    self:Init()

    return self
end

function Stage:Init()
    -- this is prismatic riddle
    print('Stage 2 init')
end

return Stage