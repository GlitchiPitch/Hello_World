
local ACTIONS = {
    ['1'] = function()
        -- turn on tv with noise
        -- after waiting go the doc film
    end,
    ['2'] = function()
        -- turn on flashlight 
        -- check mouse pos
    end,
    ['3'] = function()
        -- open door
        -- rotate cam to the door hole
    end,
    ['4'] = function()
        -- jumpScare
    end
}

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, location)
    local self = setmetatable({}, Stage)
    self.Game = game_
    self.Location = location

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
        self:Action(i)
    end

    self.Location.IsFinal = true
end

function Stage:Action(index)
    ACTIONS[index]()
end

return Stage