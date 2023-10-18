-- THIS IS FINAL STAGE --

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
    local self = setmetatable({}, Stage)
    self.Game = game_
    
    self:Init()
    return self
end

function Stage:Setup()
    
end

function Stage:CreateMaze()
    
end

function Stage:SubscribeEvents()

    -- self.Game.Events.Remotes.
    
end

function Stage:FinishAction(result)
    if result == 'Fail' then
        print('not ok')
    elseif result == 'Success' then
        print('ok')
    end
end





function Stage:Init()
    
end

return Stage