local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local ReplicatedModules = ReplicatedStorage.Modules
local Events = require(ReplicatedModules.Events)

Players.CharacterAutoLoads = false
StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson

local PlayerManager = {}

function PlayerManager.SetupCharacter(player, propertyList)
    local character
    local humanoid
    local head
    local humanoidRootPart
    if propertyList.Character then
        character = player.Character
        humanoid = character:FindFirstChild('Humanoid')
        head = character:FindFirstChild('Head')
        humanoidRootPart = character:FindFirstChild('HumanoidRootPart') 
        -- humanoid.WalkSpeed = propertyList.Character.WalkSpeed
    end
    if propertyList.Camera then
        PlayerManager.SetupCamera(player, {Head = head, HumanoidRootPart = humanoidRootPart, Humanoid = humanoid}, propertyList)
    end
end


function PlayerManager.SetupCamera(player, components, propertyList)
    Events.Remotes.SetupCamera:FireClient(player, components, propertyList)
end


return PlayerManager