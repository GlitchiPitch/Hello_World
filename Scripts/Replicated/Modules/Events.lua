local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild('Remotes')
-- local Bindables = ReplicatedStorage:WaitForChild('Bindables')

local Events = {}

-- Events.Bindables = {
    
-- }

Events.Remotes = {
    StartGame = Remotes.StartGame,
    SetupCamera = Remotes.SetupCamera
}

-- Events.StartGame = 

return Events