local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
    local self = setmetatable({}, Stage)

    self.Game = game_
    self.Room = nil
    self.IsReady = false
    
    self:Init()
    return self
end

-- bottom of the room will need to respawn and make holes into it


function Stage:Init()
    print('stage 3 is started')
    self.Room = game:GetService('CollectionService'):GetTagged('Heaven')[1]
    self:SetupRoom()
    repeat wait() until self.IsReady
	self:FinishAction()

end

function Stage:SetupRoom()
    for _, obj in pairs(self.Room:GetChildren()) do
        if obj:IsA('Part') then 
            obj.Material = Enum.Material.SmoothPlastic
            obj.Color = Color3.new(.5,.5,.5)
            obj.SurfaceLight:Destroy()
        end
    end
end

function Stage:FinishAction()
    
end

return Stage