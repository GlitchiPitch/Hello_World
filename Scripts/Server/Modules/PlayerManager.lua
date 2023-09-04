local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

Players.CharacterAutoLoads = false

local PlayerManager = {}

function PlayerManager.SetupPlayer(player)
    StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
    -- StarterPlayer.CameraMaxZoomDistance = 200
    
end

function PlayerManager.SetupCharacter(player, propertyList)
    local character = player.Character
    local humanoid = character:FindFirstChild('Humanoid')
    humanoid.WalkSpeed = propertyList.WalkSpeed
end



return PlayerManager