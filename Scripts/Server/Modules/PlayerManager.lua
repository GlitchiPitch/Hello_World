local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ReplicatedModules = ReplicatedStorage.Modules
local Events = require(ReplicatedModules.Events)

Players.CharacterAutoLoads = false
StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

local PlayerManager = {}

function PlayerManager.SetupCharacter(player, propertyList)

    if propertyList.Character then
        -- print('setup char')
        local character = player.Character
        local humanoid = character:FindFirstChild('Humanoid')
        humanoid.WalkSpeed = propertyList.Character.WalkSpeed
    end

    if propertyList.Camera then
        PlayerManager.SetupCamera(player, propertyList)
    end
end


function PlayerManager.SetupCamera(player, propertyList)
    -- print('setup cam')
    Events.Remotes.SetupCamera:FireClient(player, propertyList.Camera)
end


return PlayerManager