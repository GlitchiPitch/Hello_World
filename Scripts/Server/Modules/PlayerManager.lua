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
    local humanoid = character:FindFirstChild("Humanoid")
	if propertyList.Character then
		humanoid.WalkSpeed = propertyList.WalkSpeed
	end
    
    if propertyList.Camera then
        local head = character:FindFirstChild('Head')
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        PlayerManager.SetupCamera(player, {Humanoid = humanoid, HumanoidRootPart = humanoidRootPart, Head = head}, propertyList)
    end
end

function PlayerManager.SetupCamera(player, components, propertyList)
	Events.Remotes.SetupCamera:FireClient(player, components, propertyList)
end

return PlayerManager
