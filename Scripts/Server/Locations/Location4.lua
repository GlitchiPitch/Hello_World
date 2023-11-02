local ServerScriptService = game:GetService("ServerScriptService")

local Location = {}

Location.__index = Location

function Location.Create(_game)
	local self = setmetatable({}, Location)

	self.Game = _game
 
	return self
end

function Location:Init()
	if self.Game.PlayerManager.Result then
		print("Good over")
        require(ServerScriptService.Locations.Stages.Location4.Good).Create(self)
	else
		print("Bad over")
        require(ServerScriptService.Locations.Stages.Location4.Bad).Create(self)
	end
end

return Location