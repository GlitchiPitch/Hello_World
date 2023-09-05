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
    ClientManager.SetupStartMenu(player)
    ClientManager.SetupMouseBehaviour(player)
end

function ClientManager.SetupMouseBehaviour(player)
    local mouse = player:GetMouse()
    -- mouse.Move:Connect(function()
        -- if game:GetService('CollectionService'):HasTag(mouse.Target, 'Interact') then

        -- end    
    -- end)
    
    mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if target and game:GetService('CollectionService'):HasTag(target, 'Interact') then
            Events.Remotes.Interact:FireServer()
        end
    end)

end

function ClientManager.SetupStartMenu(player)
    MainGui.Parent = player.PlayerGui
    MainGui.Background.StartButton.MouseButton1Click:Connect(function()
        Events.Remotes.StartGame:FireServer()
        MainGui.Background:Destroy()
    end)
end


return ClientManager