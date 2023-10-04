-- at this stage we will need make a cosmos 

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_, map, resourses)
    local self = setmetatable({}, Stage)

    self.Game = game_
	self.Map = map
	self.Resourses = resourses
	self.IsReady = true

    return self
end

function Stage:Init()
    
end

return Stage