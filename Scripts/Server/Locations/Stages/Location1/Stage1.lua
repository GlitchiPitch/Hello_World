local CollectionService = game:GetService("CollectionService")
local TRIGGER_NAME = 'Saved'

local PETS_QUANTITY = 10

local petsFolder = Instance.new('Folder')
petsFolder.Parent = workspace

local voidFolder = Instance.new('Folder')
voidFolder.Parent = workspace

local Stage = {}
Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = false

    self.PetsFolder = petsFolder
    self.VoidsFolder = voidFolder

    self:Init()

    return self
end

function Stage:Init()
    print('Stage 1 init')
    self:SubsRemote()
    self:Pets()
    repeat wait() until self.IsReady
    self.InteractRemote:Disconnect()
end

function Stage:SubsRemote()
    self.InteractRemote = self.Game.Events.Remotes.Interact.OnServerEvent:Connect(function(player, interactRole, ...)
        if interactRole == 'pet' then
            local pet = ...
            pet:FindFirstChild(TRIGGER_NAME).Value = true
        elseif interactRole == 'void' then
            self.IsReady = true
            self.Game.Player.Character.HumanoidRootPart.Anchored = false
            self.PetsFolder:Destroy()
            self.VoidsFolder:Destroy()
        end
    end)
end

function Stage:Pets()

    local savedPets = 0
    -- get pets
    -- spawn in random places
    local function setup(pet)
        -- surface gui 
        -- position
        -- tag

        pet:SetAttribute('Role', 'pet')
        CollectionService:AddTag(pet, 'Interact')

        local triggered = Instance.new('BoolValue')
        triggered.Parent = pet
        triggered.Name = TRIGGER_NAME

        triggered.Changed:Connect(function(value)
            if value then 
                savedPets += 1
                self.Game.Events.Remotes.UpdateClient:FireClient(self.Game.Player, savedPets)
                game:GetService('CollectionService'):RemoveTag(pet, 'Interact')
                self:CreateVoid(self.Game.Player.Character.HumanoidRootPart.CFrame, savedPets)
            end
        end)

    end

    local rand = math.random

    for i = 1, PETS_QUANTITY do
        local pet = Instance.new('Part')
        pet.Parent = self.PetsFolder
        pet.Position = Vector3.new(rand(0.6, .6 * 5), 50.5, rand(0, 12))
        setup(pet)
    end     
end

function Stage:CreateVoid(playerCFrame, savedPets)
    local xPl, yPl, zPl = playerCFrame.Position.X, playerCFrame.Position.Y, playerCFrame.Position.Z
    local rand = math.random
    local cframes = {
        CFrame.new(rand(xPl, xPl + 100), rand(yPl, yPl + 100), rand(zPl, zPl + 100)),
        CFrame.new(rand(xPl - 100, xPl), rand(yPl, yPl + 20), rand(zPl - 100, zPl))
    }
    
    local function setupVoid(void)
        void:SetAttribute('Role', 'void')
        CollectionService:AddTag(void, 'Interact')
        void.Touched:connect(function(hitPart)
            if not hitPart.Parent:FindFirstChild('Humanoid') then return end
            print('touch')
            hitPart.Parent:FindFirstChild('HumanoidRootPart').Anchored = true
        end)
    end

    local function createVoid(targetCFrame)
        local p = Instance.new('Part')
        p.Parent = self.VoidsFolder
        p.Size = Vector3.new(10,10,10)
        p.Anchored = true
        p.BrickColor = BrickColor.Black()
        p.CFrame = targetCFrame
        setupVoid(p)
    end
    
    for i = 1, savedPets do
        local targetCFrame = cframes[rand(#cframes)]
        createVoid(targetCFrame)
    end
end


return Stage