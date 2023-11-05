local ServerStorage = game:GetService("ServerStorage")
local LocationResourses = ServerStorage.Locations
local Stages = ServerStorage.Stages

local LocationClass = {}

LocationClass.__index = LocationClass

function LocationClass.New(game_, name, properties)
	local self = setmetatable({}, LocationClass)

	self.Game = game_
	self.Name = name

	self.Resourses = LocationResourses:FindFirstChild(self.Name)
	self.Map = LocationResourses.Map -- model
	self.Stages = Stages:FindFirstChild(self.Name)

	self.SetupProperties = properties

	-- self.ServiceList = serviceList

	self.IsReady = false

	-- self:Init()

	return self
end

function LocationClass:Init()
	print(self.Name .. " is started")
	self:Setup()

	repeat wait() until self.IsReady
	print(self.Name .. " is ready")
	self:Finish()
end

function LocationClass:SetupStages()
	for index, stage in pairs(self.Stages:GetChildren()) do
		-- perhaps in this moment we will send function or some
		require(stage).Create(self, self.Resourses:FindFirstChild("Stage" .. index))
	end
end

function LocationClass:SetupMap()
	self.Map:PivotTo(CFrame.new(0, 0, 0))
    self.Map.Parent = workspace
    if self.SetupProperties.Map ~= nil then self.SetupProperties.Map() end
end
function LocationClass:OtherSetups() end

function LocationClass:Setup(...)
	self:SetupMap()
	self:SetupStages()
end

function LocationClass:Finish() 
    if self.SetupProperties.FinishAction ~= nil then self.SetupProperties.FinishAction() end
end

return LocationClass
