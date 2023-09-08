local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Events = require(Modules.Events)

ReplicatedFirst:RemoveDefaultLoadingScreen()

local MainGui = ReplicatedFirst:WaitForChild('MainGui')


local TRIGGERED_MAGNITUDE = 100

local ClientManager = {}

Events.Remotes.SetupCamera.OnClientEvent:Connect(function(propertyList)
    local camera = workspace.CurrentCamera
    camera.FieldOfView = propertyList.FieldOfView
end)

Events.Remotes.UpdateClient.OnClientEvent:Connect(function(...)
    print(...)
end)

function ClientManager.StartGame(player)
    ClientManager.SetupStartMenu(player)
    ClientManager.SetupMouseBehaviour(player)
end

function ClientManager.SetupMouseBehaviour(player)
    local mouse = player:GetMouse()
    -- mouse.Move:Connect(function()
    
    
    mouse.Button1Down:Connect(function()
        local target = mouse.Target
        local magnitude = (target.Position - player.Character.HumanoidRootPart.Position).Magnitude
        if target and magnitude < TRIGGERED_MAGNITUDE and game:GetService('CollectionService'):HasTag(target, 'Interact') then
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


--[[ THIS SMOOTH CAMERA IN ONE POINT BEHAVIOURS LIKE A S=EARTH SHAKE IT'S NEEDED

local FieldOfView = propertyList.Camera.FieldOfView
    local defFOV = FieldOfView
    local easingtime = .1
    local head = components.Head
    local humanoidRootPart = components.HumanoidRootPart


    local function lerp(a, b, t)
        return a * (1-t) + (b*t)
    end
    

    UserInputService.InputChanged:Connect(function(inputObject)

        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            print('mouse movement')
            local delta = Vector2.new(inputObject.Delta.X / Sensitivity, inputObject.Delta.Y / Sensitivity) * Smoothness
            local X = TargetAngleX - delta.Y
            TargetAngleX = (X >= 80 and 80) or (X <= -80 and -80) or X 
            TargetAngleY = (TargetAngleY - delta.X) % 360
        end	
    
    end)

    RunService.RenderStepped:Connect(function()
        CamPos *= 0.28 
		AngleX += (TargetAngleX - AngleX) * 0.35 
		local dist = TargetAngleY - AngleY 
		dist = math.abs(dist) > 180 and dist - (dist / math.abs(dist)) * 360 or dist 
		AngleY = (AngleY + dist * 0.35) % 360
		

		Camera.CFrame = CFrame.new(head.Position) 
			* CFrame.Angles(0, math.rad(AngleY), 0) 
			* CFrame.Angles(math.rad(AngleX), 0, 0)
			* HeadOffset

		humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0,math.rad(AngleY),0)

        Camera.FieldOfView = FieldOfView

        -- FieldOfView = lerp(FieldOfView, defFOV, easingtime)s
    end)

]]