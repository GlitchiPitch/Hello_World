local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Events = require(Modules.Events)

ReplicatedFirst:RemoveDefaultLoadingScreen()


local MainGui = ReplicatedFirst:WaitForChild('MainGui')

local ClientManager = {}


function ClientManager.StartGame(player)
    MainGui.Parent = player.PlayerGui
    MainGui.Background.StartButton.MouseButton1Click:Connect(function()
        Events.Remotes.StartGame:FireServer()
        MainGui.Background:Destroy()
    end)
end

function ClientManager.SetupGui(player)
    local playerGui = player.PlayerGui.MainGui

end


function ClientManager.SetupCamera()
    local camera = workspace.CurrentCamera
    camera.FieldOfView = 100 --propertyList.FieldOfView
end


return ClientManager