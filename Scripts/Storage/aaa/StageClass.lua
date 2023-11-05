local StageClass = {}

StageClass.__index = StageClass

function StageClass.New(
        location, 
        resourses, 
        setupProperties,
        serviceList 
    )

    local self = setmetatable(location, StageClass)
    
    self.Resourses = resourses
    self.SetupProperties = setupProperties
    self.ServiceList = serviceList

    self.IsReady = false
    
    -- self:Init()

    return self
end

function StageClass:Init()
    print(self.Name .. ' is started')
    self:Setup()

    repeat wait() until self.IsReady
    print(self.Name .. ' is ready')
    self:Finish()
end

function StageClass:SetupMap()
    if self.SetupProperties.Map ~= nil then self.SetupProperties.Map() end
end

function StageClass:SetupProperties()
    if self.SetupProperties.Subs ~= nil then self.SetupProperties.Subs() end
end

function StageClass:Setup(...)
    self:SetupMap()
    self:SetupProperties()
    for _, func in pairs(...) do
        func()
    end
end

function StageClass:Finish()
    if self.SetupProperties.FinishAction ~= nil then self.SetupProperties.FinishAction() end
end

return StageClass