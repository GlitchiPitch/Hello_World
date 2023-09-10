local Location = {}

Location.__index = Location

function Location.Create(game_)
    local self = setmetatable({}, Location)

    self.Game = game_

    return self
end

function Location:Init()
    
end

return Location