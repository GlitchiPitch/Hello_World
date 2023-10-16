local Lighting = game:GetService("Lighting")

local function createPart(parent, position, size)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Size = size
	part.Position = position
	part.Color = Color3.new(0.5, 0.5, 0.5)
	part.Anchored = true

	return part
end

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
	local self = setmetatable({}, Stage)

	self.Game = game_
	self.Room = nil
	self.IsReady = false

	self:Init()
	return self
end

-- bottom of the room will need to respawn and make holes into it
-- room from previous stage must be spawned outside of main map

function Stage:Init()
	print("stage 3 is started")
	self.Room = game:GetService("CollectionService"):GetTagged("Heaven")[1]
	self:SetupRoom()
	self:SubscribeEvents()
	self:Setup()
	repeat wait() until self.IsReady
	self:FinishAction()
end

function Stage:Setup()
	Lighting.ClockTime = 0
	Lighting.Ambient = Color3.new(.5,.5,.5)
	Lighting.OutdoorAmbient = Color3.new(.5,.5,.5)
	-- local light = Instance.new('PointLight')
	-- light.Parent = self.Game.Player.Character:FindFirstChild('Torso')
	-- light.Brightness = 10

	self.Game.PlayerManager.SetupCharacter(self.Game.Player, {
		Character = {
			WalkSpeed = 8,
			CanRunning = false
		}, 
		Camera = {
			FieldOfView = 100
		}
	})

end

function Stage:SubscribeEvents()

	
	self.Event = self.Game.Events.Remotes.Interact.OnServerEvent:Connect(function(player, _, block)
		block:Destroy()
	end)
	
end

function Stage:SetupBlock(block)
	game:GetService('CollectionService'):AddTag(block, 'Interact')
	-- block:SetAttribute('Role', index)
	block.Color = Color3.new(.5,.5,.5)
	block.Material = Enum.Material.SmoothPlastic
end

function Stage:CreateTower(bottom, spawnPos)
	local towerModel = Instance.new("Model")
	towerModel.Parent = self.Room

	local blockSize = Vector3.new(5, 5, 5)
	local startVector = Vector3.new(
		bottom.Position.X - bottom.Size.X / 2 + blockSize.X / 2,
		bottom.Position.Y - blockSize.Y / 2 + 0.5,
		bottom.Position.Z - bottom.Size.Z / 2 + blockSize.Z / 2
	)

	local deepValue = 5
	local constBlocksQuantity, constBlocksQuantityExists = 2, 0
	for y = 1, deepValue do
		for x = 1, math.floor(bottom.Size.X / 5) do
			for z = 1, math.floor(bottom.Size.Z / 5) do
				local part = createPart(
					towerModel,
					Vector3.new(
						startVector.X + (blockSize.X * (x - 1)),
						startVector.Y - (blockSize.Y * (y - 1)),
						startVector.Z + (blockSize.Z * (z - 1))
					),
					blockSize
				)
				if constBlocksQuantityExists <= constBlocksQuantity and math.random(1,2) == 2 then
					part.Color = Color3.new(0,0,0)
					part.Material = Enum.Material.SmoothPlastic
					constBlocksQuantityExists += 1
				else
					self:SetupBlock(part)
				end
			end
			constBlocksQuantityExists = 0
		end
	end




	local cf, size = towerModel:GetBoundingBox()

	self:CreateMainRoom()

	bottom.Position = Vector3.new(cf.Position.X, cf.Position.Y - size.Y / 2 - .5, cf.Position.Z)
	bottom.Size = Vector3.new(bottom.Size.X * 2, bottom.Size.Y, bottom.Size.Z * 2)
	bottom.Material = Enum.Material.Neon
	bottom.Touched:Connect(function(hitPart)
		if self.Game.Player.Character == hitPart.Parent then self.Game.Player.Character:MoveTo(spawnPos) end
	end)
end

function Stage:CreateMainRoom()
	
	
end

function Stage:SetupRoom()
	for _, obj in pairs(self.Room:GetChildren()) do
		if obj:IsA("Part") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Color = Color3.new(0.5, 0.5, 0.5)
			if obj.Name == "Part" or obj.Name == "roof" then
				if obj.Name == "Part" then
					obj.SurfaceLight:Destroy()
				end
				local tween = game:GetService("TweenService"):Create(
					obj,
					TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 2),
					{ Transparency = 1 }
				)
				tween:Play()
				obj.CanCollide = false
			else
				self:CreateTower(obj, self.Room:GetPivot())
			end
		end
	end
end

function Stage:FinishAction() end

return Stage
