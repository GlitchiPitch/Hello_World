local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild('Remotes')
-- local Bindables = ReplicatedStorage:WaitForChild('Bindables')

local EventsList = require(ReplicatedStorage.Description).EventsList

local e = {}

for _, event in pairs(EventsList.Remotes) do
    e[event] = Remotes:WaitForChild(event)
end


local Events = {}

-- Events.Bindables = {
    
-- }




Events.Remotes = e

-- {
--     -- StartGame = Remotes.StartGame,
--     -- SetupCamera = Remotes.SetupCamera
-- }


-- Events.StartGame = 

return Events