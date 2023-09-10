local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")



local Modules = ReplicatedStorage:WaitForChild('Modules')
local Events = require(Modules.Events)

ReplicatedFirst:RemoveDefaultLoadingScreen()

local MainGui = ReplicatedFirst:WaitForChild('MainGui')

local ClientManager = {}

Events.Remotes.SetupCamera.OnClientEvent:Connect(function(components: table, propertyList)

    local AngleX,TargetAngleX = 0,0
    local AngleY,TargetAngleY = 0,0
    local Sensitivity = 0.6
    local Smoothness = 0.05
    local HeadOffset = CFrame.new(0,1,0)

    local Camera = workspace.CurrentCamera
    Camera.CameraType = Enum.CameraType.Scriptable
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    
    local CamPos = Camera.CFrame.Position
    local FieldOfView = propertyList.Camera.FieldOfView
    local defFOV = FieldOfView
    local running = true
    local easingtime = .1
    local head = components.Head
    local humanoidRootPart = components.HumanoidRootPart
    local human = components.Humanoid

    local walkspeeds = {
        enabled = true;
        walkingspeed = propertyList.Character.WalkSpeed; 
        backwardsspeed = propertyList.Character.WalkSpeed + 2; 
        sidewaysspeed =	propertyList.Character.WalkSpeed + 7;
        diagonalspeed =	propertyList.Character.WalkSpeed * 2; 
        runningspeed = propertyList.Character.WalkSpeed * 3; 
        runningFOV=	propertyList.Camera.FieldOfView + (propertyList.Camera.FieldOfView * .5); 
    }
    -- local walkspeeds = {
    --     enabled =		  true;
    --     walkingspeed =		8; propertyList.Character.WalkSpeed
    --     backwardsspeed =	10; propertyList.Character.WalkSpeed + 2
    --     sidewaysspeed =		15; propertyList.Character.WalkSpeed + 7
    --     diagonalspeed =		16; propertyList.Character.WalkSpeed * 2
    --     runningspeed =		25; propertyList.Character.WalkSpeed * 3
    --     runningFOV=			100; propertyList.Camera.FieldOfView + (propertyList.Camera.FieldOfView * .5)
    -- }

    local w, a, s, d, lshift = false, false, false, false, false

    local function lerp(a, b, t)
        return a * (1-t) + (b*t)
    end
    

    UserInputService.InputChanged:Connect(function(inputObject)

        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(inputObject.Delta.X / Sensitivity, inputObject.Delta.Y / Sensitivity) * Smoothness
            local X = TargetAngleX - delta.Y
            TargetAngleX = (X >= 80 and 80) or (X <= -80 and -80) or X 
            TargetAngleY = (TargetAngleY - delta.X) % 360
        end	
    end)

    UserInputService.InputBegan:Connect(function(inputObject)

        if inputObject.UserInputType == Enum.UserInputType.Keyboard then
            if inputObject.KeyCode == Enum.KeyCode.W then w = true end
            if inputObject.KeyCode == Enum.KeyCode.A then a = true end
            if inputObject.KeyCode == Enum.KeyCode.S then s = true end
            if inputObject.KeyCode == Enum.KeyCode.D then d = true end
            if inputObject.KeyCode == Enum.KeyCode.LeftShift then lshift = true end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(inputObject)
    
        if inputObject.UserInputType == Enum.UserInputType.Keyboard then
            if inputObject.KeyCode == Enum.KeyCode.W then w = false	end
            if inputObject.KeyCode == Enum.KeyCode.A then a = false	end
            if inputObject.KeyCode == Enum.KeyCode.S then s = false	end
            if inputObject.KeyCode == Enum.KeyCode.D then d = false	end
            if inputObject.KeyCode == Enum.KeyCode.LeftShift then lshift = false end
        end
    end)

    RunService.RenderStepped:Connect(function()

        if running then
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
        end

        if (Camera.Focus.Position - Camera.CFrame.Position).Magnitude < 1 then
            running = false
        else
            running = true
        end

        Camera.FieldOfView = FieldOfView

        FieldOfView = lerp(FieldOfView, defFOV, easingtime)

        if walkspeeds.enabled then
            if w and s then return end
    
            if w and not lshift then
                FieldOfView = lerp(FieldOfView, defFOV, easingtime)
                human.WalkSpeed = lerp(human.WalkSpeed ,walkspeeds.walkingspeed, easingtime)
            elseif (w and a) or (w and d) then
                human.WalkSpeed = lerp(human.WalkSpeed,walkspeeds.diagonalspeed, easingtime)
            elseif s then
                human.WalkSpeed = lerp(human.WalkSpeed,walkspeeds.backwardsspeed, easingtime)
            elseif (s and a) or (s and d) then
                human.WalkSpeed = lerp(human.WalkSpeed,walkspeeds.backwardsspeed - (walkspeeds.diagonalspeed - walkspeeds.backwardsspeed), easingtime)
            elseif d or a then
                human.WalkSpeed = lerp(human.WalkSpeed,walkspeeds.sidewaysspeed, easingtime)
            end	
        end

        if lshift and w then
			FieldOfView = lerp(FieldOfView, walkspeeds.runningFOV, easingtime)
			human.WalkSpeed = lerp(human.WalkSpeed, human.WalkSpeed + (walkspeeds.runningspeed - human.WalkSpeed), easingtime)
		end

        local amOfBubbleX = .5
        local amOfBubbleY = .5

        if human.MoveDirection.Magnitude > 0 then
            local currTime = tick()
            local bobX = math.cos(currTime * 10) * amOfBubbleX
            local bobY = math.sin(math.abs(currTime * 10)) * amOfBubbleY
    
            local bobble = Vector3.new(bobX,bobY,0)
    
            human.CameraOffset = human.CameraOffset:Lerp(bobble, .25)
        else
            human.CameraOffset *= .75
        end
    end)    
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
        if target and game:GetService('CollectionService'):HasTag(target, 'Interact') then
            Events.Remotes.Interact:FireServer(target:GetAttribute('Role'), target)
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