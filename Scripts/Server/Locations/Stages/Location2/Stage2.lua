local Stage = {}

-- этап где будет много дурок в стенах и туда надо подниматься по лестницам, каждая дырка меняет цвет на карте, надо вернуть серый цвет, а так будет лютый писходел и лайтингд будет выжигать глаза

-- я думаю что надо перепридумать этот этап, не очень начальная идея

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = true

    self.Level = 1

    self.PlayerSpawnPoint = nil
    self:Init()

    return self
end

function Stage:Init()
    -- this is prismatic riddle
    print('Stage 2 init')

    repeat wait() until self.IsReady

    print('finish stage 2')

end

function Stage:CreatePrismatic()
    local function createAttachments()
        for i = 1, 10 do
            local attachment = Instance.new('Attachment')
        end
    end
end

return Stage