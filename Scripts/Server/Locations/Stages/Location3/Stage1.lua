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

function Stage:MoveBaseplate()
    local baseplate = Instance.new('Part') -- self.Map.Baseplate
    local roof = Instance.new('Part') -- self.Map.Roof
    local startPosition = Vector3.new(0,0,0)
    baseplate.Position = startPosition

    local alignPosition = Instance.new('AlignPosition')
    local att0, att1 = Instance.new('Attachment'), Instance.new('Attachment')
    att0.Parent, att1.Parent = baseplate, roof
    

end

return Stage