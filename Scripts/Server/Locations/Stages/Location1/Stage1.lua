local TRIGGER_NAME = 'Saved'

local PETS_QUANTITY = 10

local Stage = {}
Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    -- self.Player = player
    self.Map = map
    self.Resourses = resourses

    self:Init()

    return self
end

function Stage:Init()
    print('Stage 1 init')
    self:Pets()
    
    -- self.Triggers = self.Map:FindFirstChild('Triggers')
end

function Stage:Pets()

    local savedPets = 0
    -- get pets
    -- spawn in random places
    local function setup(pet)
        -- surface gui 
        -- position
        -- tag
        game:GetService('CollectionService'):AddTag(pet, 'Interact')

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

        self.Game.Events.Remotes.Interact.OnServerEvent:Connect(function()
            triggered.Value = true
        end)
    end

    for i = 1, PETS_QUANTITY do
        local pet = Instance.new('Part')
        pet.Parent = workspace
        pet.Position = Vector3.new(0.6, 50.5, 12)
        setup(pet)
        wait(5)
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
        void.Touched:connect(function(hitPart)
            if not hitPart.Parent:FindFirstChild('Humanoid') then return end
            self.Game.PlayerManager.SetupCharacter(self.Game.Player, {Character = {WalkSpeed = 0}})
        end)
    end

    local function createVoid(targetCFrame)
        local p = Instance.new('Part')
        p.Parent = workspace
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