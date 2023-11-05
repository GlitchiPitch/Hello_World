local ServerScriptService = game:GetService("ServerScriptService")

local Location = {}

Location.__index = Location

function Location.Create(_game)
	local self = setmetatable({}, Location)

	self.Game = _game
	self.IsFinal = false

	self:Init()
	return self
end

function Location:Init()
	if self.Game.PlayerManager.Result then
		print("Good over")
        require(ServerScriptService.Locations.Stages.Location4.Good).Create(self.Game, self)
	else
		print("Bad over")
        require(ServerScriptService.Locations.Stages.Location4.Bad).Create(self.Game, self)
	end
	repeat wait() until self.IsFinal

	-- turn off game
	self:Thanks()

end

function Location:Thanks()
	local gui = Instance.new('ScreenGui')
	gui.Parent = self.Game.Player.PlayerGui
	gui.IgnoreGuiInset = true
	local text = Instance.new('TextLabel')
	text.Parent = gui
	text.Size = UDim2.fromScale(1,1)
	text.BackgroundColor3 = Color3.new(0,0,0)
	text.TextScaled = true
	text.TextStrokeTransparency = 0
	text.TextColor3 = Color3.new(1,1,1)
	text.Text = 'Thanks for playing'
end

return Location
