local LocationClass = require(script.Parent.LocationClass)

local CLOCK_TIME = 14
local AMBIENT = Color3.new(.5,.5,.5)

local Location = {}

Location.__index = Location

function Location.Create(game_)
    local self = setmetatable({
        LocationClass.New(game_, 'Location2',
        function() 
            local Lighting = game:GetService('Lighting')
            Lighting.ClockTime = CLOCK_TIME
            Lighting.OutdoorAmbient = AMBIENT
            Lighting.Ambient = AMBIENT
        end
    )

    }, Location)
    
    self:Init()

    return self
end

return Location