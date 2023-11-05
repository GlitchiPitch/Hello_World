local LocationClass = require(script.Parent.LocationClass)

local Location = {}

Location.__index = Location

function Location.Create(game_)
    local self = setmetatable({
        LocationClass.New(game_, 'Location1'
        -- function() end
    )

    }, Location)
    
    

    return self
end

return Location