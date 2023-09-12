local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Warnings = require(ServerScriptService.Warnings)
-- police warning module

-- здесь будет попадание на карту основную но с настройками света и нахождением на карте монстра из стэйдж 2
-- надо фиксировать камеру




local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Map = map
    self.Resourses = resourses
    self.IsReady = false

    self:Init()

    return self
end

function Stage:Init()
    print('Stage 3 init')
    self:Setup()
    -- self:Check()
    repeat wait() until self.IsReady
    -- self.CheckMonster:Disconnect()
    self:ShowPoliceWarning()
end

function Stage:CreateMonster()
    local monster = Instance.new('Part')
    monster.Parent = self.Map
    -- monster.Position = 
end

function Stage:Setup()
    Lighting.ClockTime = 14

    wait(5)

    self.IsReady = true
end


function Stage:Check()
    -- this is working on client side
    local npc = workspace.AlreadyPro
    local char = self.Game.Player.Character

    self.CheckMonster = RunService.RenderStepped:Connect(function()
        local npcToChar = (npc.Head.Position - char.Head.Position).Unit
        local npcLook = char.Head.CFrame.LookVector
        
        local dotProduct = npcToChar:Dot(npcLook)
        
        if dotProduct > .5 then
            self.IsReady = true
        end
    end)
end

function Stage:ShowPoliceWarning()
    self.Game.Player.Character.HumanoidRootPart.Anchored = true
    local warning = Warnings.Create(self.Game.Player)
    warning:Warning_1_1()
    
end



return Stage