local CollectionService = game:GetService("CollectionService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService('StarterGui')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local Events = require(Modules.Events)

ReplicatedFirst:RemoveDefaultLoadingScreen()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

-- local MainGui = ReplicatedFirst:WaitForChild('MainGui')
-- today make a grab system


local CONNECT
local SETUP_CAMERA_CONNECT

local Camera = workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable

local ClientManager = {}

SETUP_CAMERA_CONNECT = Events.Remotes.SetupCamera.OnClientEvent:Connect(function(components: table, propertyList)
    local canRunning = true
    
    if propertyList.Character.CanRunning ~= nil then canRunning = propertyList.Character.CanRunning end
    local AngleX,TargetAngleX = 0,0
    local AngleY,TargetAngleY = 0,0
    local Sensitivity = 0.6
    local Smoothness = 0.05
    local HeadOffset = CFrame.new(0,1,0)
    
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
            if inputObject.KeyCode == Enum.KeyCode.LeftShift and canRunning then lshift = true end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(inputObject)
    
        if inputObject.UserInputType == Enum.UserInputType.Keyboard then
            if inputObject.KeyCode == Enum.KeyCode.W then w = false	end
            if inputObject.KeyCode == Enum.KeyCode.A then a = false	end
            if inputObject.KeyCode == Enum.KeyCode.S then s = false	end
            if inputObject.KeyCode == Enum.KeyCode.D then d = false	end
            if inputObject.KeyCode == Enum.KeyCode.LeftShift and canRunning then lshift = false end
        end
    end)

    if CONNECT and CONNECT.Connected then CONNECT:Disconnect() end

    CONNECT = RunService.RenderStepped:Connect(function()

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

        if lshift and w and canRunning then
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

Events.Remotes.UpdateClient.OnClientEvent:Connect(function(action, ...)
    if action == 'coreGui' then
        local coreGuiElement, state = ...
        StarterGui:SetCoreGuiEnabled(coreGuiElement, state)
    elseif action == 'sendChatMessage' then
        local message = ...
        StarterGui:SetCore( "ChatMakeSystemMessage",  { Text = message, Color = Color3.new(1,1,1), Font = Enum.Font.Arial, FontSize = Enum.FontSize.Size60 } )
    elseif action == 'setCameraPos' then
        if SETUP_CAMERA_CONNECT and SETUP_CAMERA_CONNECT.Connected then SETUP_CAMERA_CONNECT:Disconnect() end
        
        local pos = ...
        Camera.Position = pos
    elseif action == 'tweenCam' then
        if SETUP_CAMERA_CONNECT and SETUP_CAMERA_CONNECT.Connected then SETUP_CAMERA_CONNECT:Disconnect() end
        local t, target = ...
        local tween = game:GetService('TweenService'):Create(Camera, TweenInfo.new(t), target)
        tween:Play()
        tween.Completed:Wait()
    end
end)

function ClientManager.StartGame(player)
    ClientManager.SetupStartMenu(player)
    ClientManager.SetupMouseBehaviour(player)
end

function ClientManager.SetupMouseBehaviour(player)
    local mouse = player:GetMouse()
    local interactLabel = player.PlayerGui:FindFirstChild('MainGui'):FindFirstChild('interactLabel')
    mouse.Move:Connect(function()
        local target = mouse.Target
        if target and CollectionService:HasTag(target, 'Interact') and (mouse.Origin.Position - target.Position).Magnitude < 10 then
            local x, y = mouse.X / mouse.ViewSizeX, mouse.Y / mouse.ViewSizeY
            interactLabel.Visible = true
            interactLabel.Position = UDim2.fromScale(x, y + .1)
        else
            interactLabel.Visible = false
        end
    end)
    
    mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if target and game:GetService('CollectionService'):HasTag(target, 'Interact') and (mouse.Origin.Position - target.Position).Magnitude < 10 then
            Events.Remotes.Interact:FireServer(target:GetAttribute('Role') ~= nil and target:GetAttribute('Role') or nil, target)
        -- elseif target and game:GetService('CollectionService'):HasTag(target, 'Interact') and 
        --                     (mouse.Origin.Position - target.Position).Magnitude < 10 and 
        --                     game:GetService('CollectionService'):HasTag(target, 'Pickable')
        -- then
        --     print('take')
        end
    end)

end

function ClientManager.SetupStartMenu(player)
    local MainGui = player.PlayerGui:FindFirstChild('MainGui')
    -- MainGui.Parent = player.PlayerGui
    MainGui.Background.StartButton.MouseButton1Click:Connect(function()
        Events.Remotes.StartGame:FireServer()
        MainGui.Background:Destroy()
    end)

    local interactLabel = Instance.new('TextLabel')
    interactLabel.Name = 'interactLabel'
    interactLabel.AnchorPoint = Vector2.new(.5, 0)
    interactLabel.Parent = MainGui
    interactLabel.Size = UDim2.fromScale(.1,.05)
    interactLabel.BackgroundTransparency = 1
    interactLabel.TextColor3 = Color3.new(1,1,1)
    interactLabel.TextStrokeTransparency = 0
    interactLabel.Visible = false
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