





local Warnings = {}

Warnings.__index = Warnings

function Warnings.Create(player)
    local self = setmetatable({}, Warnings)


    self.Player = player
    self.PlayerGui = self.Player.PlayerGui
    self.Pics = {}
    self.Sounds = {}

    return self
end

function Warnings:CreateGui()
    print(self.PlayerGui)

    local mainGui = self.PlayerGui:FindFirstChild('MainGui')
    print(mainGui)
    local mainFrame = Instance.new('Frame')
    mainFrame.Parent = mainGui
    -- mainFrame.Size = UDim2.fromScale(1, 1)
    mainFrame.Size = UDim2.fromScale(.5, .5)
    mainFrame.BackgroundColor3 = Color3.new(0,0,1)

    local imageLabel = Instance.new('ImageLabel')
    imageLabel.Parent = mainFrame
    imageLabel.Size = UDim2.fromScale(1, 1)

    local sound = Instance.new('Sound')
    sound.Parent = mainFrame
    -- будет несколько картинок 

    -- for i, o in pairs(self.Pics) do
    --     sound.SoundId = self.Sounds[i]
    --     imageLabel.Image = o
    --     sound.Ended:Wait()
    -- end

    wait(5)
    mainFrame:Destroy()

end

function Warnings:Warning_1_1()
    
    self.Pics = {
        -- pic1
        -- pic2
    }
    self.Sounds = {
        -- soundId1
        -- soundId2
    }
    
    self:CreateGui()
end

function Warnings:Warning_1_2w()
    
end

return Warnings