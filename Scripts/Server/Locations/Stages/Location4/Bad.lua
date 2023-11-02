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
        {1,2,3},
        {1,2,3},
        {1,2,3},
        {1,2,3},
    }
    for i = 1, #camPoses do
        self.Game.Events.Remotes.UpdateClient:FireClient(self.Game.Player, 'tweenCam', camPoses[i])
        
    end
end

return Stage