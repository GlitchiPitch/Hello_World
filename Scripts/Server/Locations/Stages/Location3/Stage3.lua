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
	self.MainRoom = nil
	self.WaitingRoom = nil
	self.BallCounter = nil
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
	print(' stage is finished')
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

	
	self.Event = self.Game.Events.Remotes.Interact.OnServerEvent:Connect(function(player, role, object)
		if role == 'Block' then
			object:Destroy()
		elseif role == 'FinalButton' then
			self.IsReady = true
			self.BallCounter.Value = -1
		elseif role == 'Ball' then
			object:Destroy()
			-- chpok sound
			self.BallCounter.Value += 1
		end
	end)
	
end

function Stage:SetupBlock(block)
	game:GetService('CollectionService'):AddTag(block, 'Interact')
	block:SetAttribute('Role', 'Block')
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
	
	local model, pivot, roomSize = self:CreateMainRoom(Vector3.new(cf.Position.X, cf.Position.Y - size.Y / 2, cf.Position.Z))
	self.MainRoom = model

	bottom.Position = Vector3.new(cf.Position.X, pivot.Y - roomSize.Y / 2 - 10, cf.Position.Z)
	bottom.Size = Vector3.new(bottom.Size.X * 2, bottom.Size.Y, bottom.Size.Z * 2)
	bottom.Material = Enum.Material.Neon
	bottom.Touched:Connect(function(hitPart)
		if self.Game.Player.Character == hitPart.Parent then self.Game.Player.Character:MoveTo(spawnPos) end
	end)
end

function Stage:CreateMainRoom(bottomOfTowerPosition)

	local roomProperties = {
		roomSize = 50,
		wallHeight = 20,
		material = Enum.Material.Rubber
	}

	local sides = { {1, 0}, {-1, 0}, {0, 1}, {0, -1} }
	local model = Instance.new('Model')
	model.Parent = workspace

	for i, side in pairs(sides) do
		local pos = Vector3.new(side[1] * roomProperties.roomSize / 2, bottomOfTowerPosition.Y - roomProperties.wallHeight / 2, side[2] * roomProperties.roomSize / 2)
		local size = Vector3.new(side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize), roomProperties.wallHeight, side[1] == 0 and 1 or math.abs(side[1] * roomProperties.roomSize))
		local wall = createPart(model, pos, size)
		wall.Material = roomProperties.material
		wall.Color = Color3.new(0.4, 0.3, 0.2)
	end

	local _, roomSize = model:GetBoundingBox()
	local pivot = model:GetPivot()

	local roof = createPart(model, pivot.Position + Vector3.new(0, roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	local bottom = createPart(model, pivot.Position + Vector3.new(0, -roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	roof.Color, bottom.Color = Color3.new(.5,.5,.5), Color3.new(.5,.5,.5)
	roof.Material, bottom.Material = roomProperties.material, roomProperties.material
	roof.Name, bottom.Name = 'roof', 'bottom'
	roof.CanCollide = false

	bottom.Touched:Connect(function(hitPart)
		if self.Game.Player.Character == hitPart.Parent then
			bottom.CanTouch = false
			self:CreateMainContent(model, pivot, roomSize)
			self.Room:Destroy()
			-- self:Message()
		end
	end)

	return model, pivot, roomSize
	
end

function Stage:Message()

	self.Game.Player.Character:FindFirstChild('HumanoidRootPart').Anchored = true

	local msg = "Stop, don't touch this, I did it for the last moment for me, but it is not yet. I can't let you go because you will tell about this place. But we can agree and I'll leave you"

	self.Game.Events.Remotes.UpdateClient:FireClient(self.Game.Player, 'coreGui', Enum.CoreGuiType.Chat, true)
	for _, word in pairs(string.split(msg, ' ')) do
		for i = 1, math.random(1,3) do
		self.Game.Events.Remotes.UpdateClient:FireClient(self.Game.Player, 'sendChatMessage', word)
		end
		task.wait(math.random(0.5,1.5))
	end

	for _, obj in pairs(self.MainRoom:GetChildren()) do
		if obj.Name == 'Part' then
			local tween = game:GetService('TweenService'):Create(obj, TweenInfo.new(2), {Position = obj.Position - Vector3.new(0, obj.Size.Y)})
			tween:Play()
		end
	end

	self.Game.Player.Character:FindFirstChild('HumanoidRootPart').Anchored = false

end

function Stage:CreateWaitingRoom(mainRoom, roomSize, pivot)

	self.WaitingRoom = mainRoom:Clone()
	self.WaitingRoom.Parent = workspace

	self.WaitingRoom:ScaleTo(3)

	for _, obj in pairs(self.WaitingRoom:GetChildren()) do
		obj.Color = Color3.new(0.701960, 0.380392, 0.631372)
	end

	local clonePivot, cloneSize = self.WaitingRoom:GetBoundingBox()

	self.WaitingRoom:PivotTo(CFrame.new(0, roomSize.Y - 1, 0) * clonePivot)
	
	self.BallCounter = Instance.new('IntValue')
	local counterGuiPart = createPart(self.WaitingRoom, Vector3.new(clonePivot.X, clonePivot.Y + cloneSize.Y / 2 - 10, clonePivot.Z), Vector3.new(roomSize.X, 15, roomSize.Z))
	counterGuiPart.Material = Enum.Material.SmoothPlastic
	counterGuiPart.BrickColor = BrickColor.new('Magenta')
	local faces = {Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left, Enum.NormalId.Right}
	local labels = {}
	for i = 1, #faces do
		local counterGui = Instance.new('SurfaceGui')
		local counterLabel = Instance.new('TextLabel')
		counterLabel.Parent = counterGui
		counterLabel.Text = 0
		counterLabel.Name = 'counterLabel'
		counterLabel.Size = UDim2.fromScale(1, 1)
		counterLabel.TextScaled = true
		counterLabel.BackgroundTransparency = 1
		counterLabel.TextStrokeTransparency = 0
		counterLabel.TextColor3 = Color3.new(1,1,1)

		table.insert(labels, counterLabel)

		counterGui.Parent = counterGuiPart
		counterGui.Face = faces[i]
	end

	self.BallCounter.Changed:Connect(function(value)
		for _, label in pairs(labels) do
			label.Text = value
		end
	end)

	local ballCount = 1000
	local ballFolder = Instance.new('Folder')
	ballFolder.Parent = self.WaitingRoom
	coroutine.wrap(function()
		for i = 1, ballCount do

			if self.BallCounter.Value == -1 then break end

			task.wait(math.random(1,10))
			local ball = createPart(ballFolder, Vector3.new(
				math.random(clonePivot.X - cloneSize.X / 2 + 10, clonePivot.X + cloneSize.X / 2 - 10), clonePivot.Y + cloneSize.Y / 2 - 10,
				math.random(clonePivot.Z - cloneSize.Z / 2 + 10, clonePivot.Z + cloneSize.Z / 2 - 10)), Vector3.new(2,2,2))
			ball:SetAttribute('Role', 'Ball')
			ball.Shape = Enum.PartType.Ball
			ball.BrickColor = BrickColor.random()
			ball.Anchored = false
			game:GetService('CollectionService'):AddTag(ball, 'Interact')
		end
		-- self.IsReady = true
		-- i think here we need to load final module which are showing final scene with the 'good' end
	end)()

end

function Stage:CreateMainContent(mainRoom, pivot, roomSize)
	
	self:CreateWaitingRoom(mainRoom, roomSize, pivot)

	local buttonSize = Vector3.new(10,1,10)
	local button = createPart(mainRoom, Vector3.new(pivot.X, pivot.Y - roomSize.Y / 2 + buttonSize.Y / 2, pivot.Z), buttonSize)
	button.Name = 'Button'
	button.Material = Enum.Material.Neon
	button.Color = Color3.new(0.7, 0.3, 0.3)
	game:GetService('CollectionService'):AddTag(button, 'Interact')
	button:SetAttribute('Role', 'FinalButton')

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
				self:CreateTower(obj, self.Room:GetPivot().Position)
			end
		end
	end
end

function Stage:FinishAction() 
	self.Event:Disconnect()
	-- print(self.WaitingRoom, self.Room:GetChildren())
	-- print(self.WaitingRoom:FindFirstChild('bottom'), self.Room:FindFirstChild('bottom'))
	self.WaitingRoom:FindFirstChild('bottom').CanCollide, self.MainRoom:FindFirstChild('bottom').CanCollide = false, false
	game:GetService('CollectionService'):AddTag(self.MainRoom, 'PrevRoom')
	-- self.Room:Destroy()
	-- self.WaitingRoom:Destroy()
	-- glitch gui
	
end

return Stage
