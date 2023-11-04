local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, location)
    local self = setmetatable({}, Stage)
    self.Game = game_
    self.Room = nil
    self.TV = nil
    self.Location = location
    
    self:Init()
    return self
end

function Stage:Init()
    local camPoses = {
        start = {1,2,3},
        finish = {1,2,3}
    }
    
    self.Game.Events.Remotes.UpdateClient:FireClient(self.Game.Player, 'tweenCam', camPoses)
    self:StartDocumentary()
    
end

function Stage:StartDocumentary()
    local frames = {
        f1 = {sound = 0, pictureId = 0},
        f2 = {sound = 0, pictureId = 0},
        f3 = {sound = 0, pictureId = 0},
    }

    
    local function showContent(frame)
        local url = 'rbxassets//'
        local screen = self.TV.Screen
        screen.Image = url .. frame.pictureId
        local sound = self.TV.Sound
        sound.SoundId = url .. frame.sound
        sound:Play()
        sound.Ended:Wait()
    end

    for _, frame in pairs(frames) do
        showContent(frame)
    end

    self.Location.IsFinal = true
end

return Stage