local StageClass = require(script.Parent.StageClass)

local TRIGGER_NAME = 'Saved'

local Stage = {}

Stage.__index = Stage

function Stage.Create(location,  resourses)
    local self = setmetatable({
        StageClass.New(location, resourses)
    }, Stage)
    
    return self
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



return Stage