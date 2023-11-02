local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
    local self = setmetatable({}, Stage)
    self.Game = game_

    self:Init()
    return self
end

function Stage:Init()
    local camPoses = {
        start = {1,2,3},
        finish = {1,2,3}
    }
    self.Game.Events.Remotes.UpdateClient:FireClient(self.Game.Player, 'tweenCam', camPoses)
    
end

return Stage