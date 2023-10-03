local Location = {}

Location.__index = Location

function Location.Create(_game, map, resourses)
    local self = setmetatable({}, Location)

    self.Game = _game
    self.Map = map
    self.Resourses = resourses
    self.Events = self.Game.Events
    return self
end

function Location:SubscribeEvents()
    -- self.Events.
    
end

return Location