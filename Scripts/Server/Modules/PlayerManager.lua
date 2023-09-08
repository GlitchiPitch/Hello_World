local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ReplicatedModules = ReplicatedStorage.Modules
local Events = require(ReplicatedModules.Events)

Players.CharacterAutoLoads = false
StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

local PlayerManager = {}

function PlayerManager.SetupCharacter(player, propertyList)
    local character = player.Character
    local humanoid = character:FindFirstChild('Humanoid')
    humanoid.WalkSpeed = propertyList.WalkSpeed

    PlayerManager.SetupCamera(player, propertyList)
end


function PlayerManager.SetupCamera(player, propertyList)
    Events.Remotes.SetupCamera:FireClient(player, propertyList)
end


return PlayerManager