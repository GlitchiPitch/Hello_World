local ServerStorage = game:GetService("ServerStorage")
local Stage = {}

-- этот этап переходный между локациями, после его прохождения игрок попадает на след локацию

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = false

    self.Level = 1

    self.PlayerSpawnPoint = nil
    self:Init()

    return self
end

function Stage:Init()
    
    self:CreatePort()
    self:CreateVars()
    print('Stage 3 init')
end

function Stage:CreateVars()
    self.ShortSignalFolder, self.LongSignalFolder = Instance.new('Folder'), Instance.new('Folder')
    self.ShortSignalFolder.Parent, self.LongSignalFolder.Parent = ServerStorage, ServerStorage
    self.ShortSignalFolder.Name, self.LongSignalFolder.Name = 'ShortSignal', 'LongSignal'

end

function Stage:CreateSingals()

    local l = {{10, -50, 0}, {-10, -50, 0}}

    for _, pos in pairs(l) do 
        local part = Instance.new('Part')
        part.Parent = workspace
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

        local touchedPart = Instance.new('Part')
        touchedPart.Parent = workspace
        touchedPart.Anchored = true
        touchedPart.Position = part.Position - Vector3.new(0, 5, 0)
        touchedPart.Color = Color3.new(0,0,1)
        touchedPart.Size = Vector3.new(10,1,10)

        local surfaceLight = Instance.new('SurfaceLight')
        surfaceLight.Parent = touchedPart
        surfaceLight.Face = Enum.NormalId.Top
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



    
end


return Stage