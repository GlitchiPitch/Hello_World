local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Events = require(Modules.Events)

ReplicatedFirst:RemoveDefaultLoadingScreen()

local MainGui = ReplicatedFirst:WaitForChild('MainGui')

local ClientManager = {}

Events.Remotes.SetupCamera.OnClientEvent:Connect(function(propertyList)
    local camera = workspace.CurrentCamera
    camera.FieldOfView = propertyList.FieldOfView
end)

Events.Remotes.UpdateClient.OnClientEvent:Connect(function()
    print('update')
end)

function ClientManager.StartGame(player)
    MainGui.Parent = player.PlayerGui
    MainGui.Background.StartButton.MouseButton1Click:Connect(function()
        Events.Remotes.StartGame:FireServer()
        MainGui.Background:Destroy()
    end)
end


return ClientManager