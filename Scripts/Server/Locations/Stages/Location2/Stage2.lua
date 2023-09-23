local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Stage = {}

-- этот этап переходный между локациями, после его прохождения игрок попадает на след локацию
-- надо как-то отправить сигнал наверх что игра закончилась, а просто отправить self не получается, он отправлять детальку к которой касание происходит, меня почему-то это бесит

Stage.__index = Stage

function Stage.Create(game_, map, resourses, event)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = false
    self.Event = event

    print(self.Event)
    self.Signals = {}
    self.SignalList = {
        Long = {},
        Short = {}
    }

    self.Level = 1

    self.PlayerSpawnPoint = nil
    self:Init()

    return self
end

function Stage:Init()
    
    self:CreatePort()
    self:CreateSignalFolders()
    print('Stage 2 init')

    repeat wait() until self.IsReady
    print(' Stage 2 is ready')
    self:FinishAction()
end

function Stage:FinishAction()
    for singalName, item in pairs(self.SignalList) do
        item.Parent = singalName == self.SignalList.Long.Name and self.LongSignalFolder or self.ShortSignalFolder
        -- table remove item
    end
    -- self.Location.IsReady = true
    -- self.Event:Fire()
    -- delete signals
end

function Stage:CreateSignalFolders()
    self.ShortSignalFolder, self.LongSignalFolder = Instance.new('Folder'), Instance.new('Folder')
    self.ShortSignalFolder.Parent, self.LongSignalFolder.Parent = ServerStorage, ServerStorage
    self.ShortSignalFolder.Name, self.LongSignalFolder.Name = 'ShortSignal', 'LongSignal'
end

function Stage:SetupSignals(particle, bit)
    local lengthOfFlash = 2
    local tInfo = TweenInfo.new( bit == 0 and lengthOfFlash / 2 or lengthOfFlash, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    TweenService:Create(particle, tInfo, {ImageTransparency = 1}):Play()
end

function Stage:SetupTouchedPart(touchedPart, bit)
    local touchedList = bit == 0 and self.SignalList.Short or self.SignalList.Long
    touchedPart.touchedPart.Touched:Connect(function(hitPart)
        if game:GetService('CollectionService'):HasTag(hitPart, 'Interact') then
            table.insert(touchedList, hitPart)
        end
    end)

    touchedPart.touchedPart.TouchEnded:Connect(function(hitPart)
        if table.find(touchedList, hitPart, 1) and game:GetService('CollectionService'):HasTag(hitPart, 'Interact') then
            table.remove(touchedList, table.find(touchedList, hitPart, 1))
        end
    end)
end

function Stage:CreateSingals()

    local l = {{10, -50, 0}, {-10, -50, 0}}

    for i, pos in pairs(l) do 

        local model = Instance.new('Model')
        model.Parent = workspace

        local part = Instance.new('Part')
        part.Parent = model
        part.Size = Vector3.new(1,1,1)
        part.Transparency = 1
        part.CanCollide, part.CanQuery, part.CanTouch = false, false, false
        part.Anchored = true
        part.Position = Vector3.new(table.unpack(pos))

        local gui = Instance.new('BillboardGui')
        gui.Size = UDim2.fromScale(4,4)
        gui.Parent = part

        local particle = Instance.new('ImageLabel')
        particle.BackgroundTransparency = 1
        particle.Image = 'rbxassetid://11815755770'
        particle.Size = UDim2.fromScale(1,1)
        particle.Parent = gui
        self:SetupSignals(particle, (i - 1))

        local touchedPart = self.Resourses.Items:FindFirstChild('TouchedPart'):Clone()
        touchedPart.Parent = model
        touchedPart:PivotTo(CFrame.new(part.CFrame.Position - Vector3.new(0, 5, 0)) * touchedPart:GetPivot().Rotation)
        self:SetupTouchedPart(touchedPart, (i - 1))

        table.insert(self.Signals, model)
    end         
end

function Stage:CreatePort()
    -- local mapPivot = self.Map:GetPivot() 
    local portModel = Instance.new('Part') -- after it will be model
    portModel.Parent = workspace
    portModel.Position = Vector3.new(0,5,0)
    portModel.Color = Color3.new(0,1,0)
    portModel.Size = Vector3.new(10,10,10)

    portModel.Touched:Connect(function(hitPart)
        if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
        self:CreateSingals()
        portModel:Destroy()
    end)

    local finishTrigger = Instance.new('Part')
    finishTrigger.Parent = workspace
    finishTrigger.Position = Vector3.new(0,5,0)
    finishTrigger.Color = Color3.new(1,0,1)
    finishTrigger.Size = Vector3.new(10,10,10)

    finishTrigger.Touched:Connect(function(hitPart)
        if not game.Players:GetPlayerFromCharacter(hitPart.Parent) then return end
        self.IsReady = true
        finishTrigger:Destroy()
    end)
end


return Stage