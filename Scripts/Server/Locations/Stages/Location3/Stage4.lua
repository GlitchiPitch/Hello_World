local Lighting = game:GetService("Lighting")
-- THIS IS FINAL STAGE --
local CORRIDOR_COLOR = Color3.new(1,0,0)
local TARGET_VALUE = 10

local function createPart(parent, position, size)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Size = size
	part.Position = position
	part.Anchored = true

	return part
end

local function createRoom(parent, roomProperties, isCorridor, ...)
	local sides = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
	local model = parent

	for i, side in pairs(sides) do
		local pos = Vector3.new(
			side[1] * roomProperties.roomSize / (isCorridor and 100 or 2),
			roomProperties.wallHeight / 2,
			side[2] * roomProperties.roomSize / (isCorridor and 1 or 2)
		)
		local size = Vector3.new(
			side[2] == 0 and 1 or math.abs(side[2] * roomProperties.roomSize / (isCorridor and 50 or 1)),
			roomProperties.wallHeight,
			side[1] == 0 and 1
				or math.abs(side[1] * roomProperties.roomSize) + (isCorridor and roomProperties.roomSize or 0)
		)
		local wall = createPart(model, pos, size)
		wall.Material = roomProperties.material
		wall.Color = CORRIDOR_COLOR
		wall.Name = "wall"
		if isCorridor and side[2] ~= 0 then
			local portal = wall:Clone()
			portal.Parent = model
			table.insert(..., portal)
			portal.Size += Vector3.new(0, 0, 3)
			portal.CanCollide = false
			portal.Position = wall.Position + Vector3.new(0,0,side[2] < 0 and portal.Size.Z / 2 or -portal.Size.Z / 2)
		end
	end

	local pivot, roomSize = model:GetBoundingBox()

	local roof =
		createPart(model, pivot.Position + Vector3.new(0, roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	local bottom =
		createPart(model, pivot.Position + Vector3.new(0, -roomSize.Y / 2, 0), Vector3.new(roomSize.X, 1, roomSize.Z))
	roof.Color, bottom.Color = CORRIDOR_COLOR, CORRIDOR_COLOR
	roof.Material, bottom.Material = roomProperties.material, roomProperties.material
	roof.Name, bottom.Name = "roof", "bottom"
	roof.CanCollide = false

	return model, isCorridor and ...
end

local MONSTER = {}

MONSTER.__index = MONSTER

function MONSTER.Create(game_, stage_)
	local self = setmetatable({}, MONSTER)
	self.Body = Instance.new('Part')
	self.Stage = stage_
	self:Init()
	return self
end

function MONSTER:Init()
	self:CheckTouch()
end

function MONSTER:CheckTouch()
	self.Body.Touched:Connect(function(hitPart)
		if hitPart.Parent == self.Game.Player.Character then
			self.Stage.Saved = false
			self.Game.Player.Character:FindFirstChild('Humanoid').Health = 0
		end
	end)
end






local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
	local self = setmetatable({}, Stage)
	self.Game = game_
	self.Monster = MONSTER.Create(self.Game, self)
	self.SpawnPivot = nil
	self.BlackRoom = nil
	self.Corridor = nil

	self.StepsCount = 0
	self.Saved = true
	self.IsReady = false

	self:Init()
	return self
end

function Stage:Setup()
	self.Game.Player.Character:ScaleTo(0.2)
	local colorCorrection = Instance.new("ColorCorrectionEffect")
	colorCorrection.Parent = Lighting
	self.Game.PlayerManager.SetupCharacter(self.Game.Player, {
		Character = {
			WalkSpeed = 8,
		}, 
		Camera = {
			FieldOfView = 140
		}
	})
	self:CheckDeath()
end

function Stage:CheckDeath()
	self.Game.Player.Character:FindFirstChild('Humanoid').Died:Connect(function()
		if self.Saved then 
			print('The good over') 
			self.Game.PlayerManager.Result = true
		else 
			print('The bad over')
			self.Game.PlayerManager.Result = false
		end
		self.IsReady = true
		-- self.Game.PlayerManager.Result = false
	end)
end

function Stage:CreateCorridor()
	local corridorModel, blackRoom = Instance.new("Model"), Instance.new("Model")
	corridorModel.Parent, blackRoom.Parent = workspace, workspace

	self.BlackRoom = createRoom(blackRoom, {
		roomSize = 50,
		wallHeight = 20,
		material = Enum.Material.Rubber,
	}, false)

	blackRoom:PivotTo(self.SpawnPivot[1] * CFrame.new(0, -self.SpawnPivot[2].Y, 0)) --* CFrame.new(0, -50, 0)

	self.Corridor, self.CorridorTeleports = createRoom(corridorModel, {
		roomSize = 400,
		wallHeight = 10,
		material = Enum.Material.Rubber,
	}, true, {})

	corridorModel:PivotTo(self.SpawnPivot[1] * CFrame.new(0, -self.SpawnPivot[2].Y, 450)) -- * CFrame.new(0, -50, 100)
	self.CorridorTeleports[1].Material, self.CorridorTeleports[1].Color = Enum.Material.Neon, Color3.new(1, 1, 1)
	self.CorridorTeleports[2].Material, self.CorridorTeleports[2].Color = Enum.Material.Neon, Color3.new(1, 1, 1)
end

function Stage:CreateCorridorContent(corridor, teleportWall)

	local teleports = {self.CorridorTeleports[1], self.CorridorTeleports[2]}
	table.remove(teleports, table.find(teleports, teleportWall, 1))

	local barriers = Instance.new('Model')
	barriers.Parent = corridor

	local touchConnect
	touchConnect = teleports[1].Touched:Connect(function(hitPart)
		if self.Game.Player == game.Players:GetPlayerFromCharacter(hitPart.Parent) then
			touchConnect:Disconnect()
			game:GetService("TweenService")
				:Create(
					Lighting:FindFirstChild("ColorCorrection"),
					TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{ Brightness = 3 }
				)
				:Play()
			self.Game.Player.Character:MoveTo(self.BlackRoom:GetPivot().Position)
			barriers:Destroy()
			self:CreateBlackRoomContent()
		end
	end)

	local cf, s = corridor:GetBoundingBox()

	for i = 1, s.Z / 15 do
		local pos = Vector3.new(math.random((cf.X - s.X / 2), (cf.X + s.X / 2)), cf.Y, (cf.Z - s.Z / 2) + 15 * i)
		local size = Vector3.new(5,s.Y,10) --Vector3.new(math.random(1, s.X / 2), math.random(1, s.Y), math.random(1, s.Z / 2))
		local barrier = createPart(barriers, pos, size)
		barrier.Color = CORRIDOR_COLOR
		-- barrier.Orientation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))
	end
end

function Stage:CreateBlackRoomContent()
	self.StepsCount += 1
	local walls = {}
	for _, obj in pairs(self.BlackRoom:GetChildren()) do
		if obj.Name == "wall" then
			table.insert(walls, obj)
			obj.Color = Color3.new(0, 0, 0)
			obj.CanCollide = self.StepsCount == TARGET_VALUE and false or true
		end
	end
	local portalWall = walls[math.random(#walls)]:Clone()
	portalWall.Parent = self.BlackRoom
	portalWall.Material = Enum.Material.Neon
	portalWall.Color = Color3.new(1, 1, 1)
	local cf, s = self.BlackRoom:GetBoundingBox()
	portalWall.Position += Vector3.new(portalWall.Position.X < cf.X and 5 or (portalWall.Position.X > cf.X and -5 or 0), 0, portalWall.Position.Z < cf.Z and 5 or (portalWall.Position.Z > cf.Z and -5 or 0))
	portalWall.Size += Vector3.new(portalWall.Position.Z == cf.Z and 5 or 0, 0, portalWall.Position.X == cf.X and 5 or 0)
	portalWall.CanCollide = false
	local touchConnect
	touchConnect = portalWall.Touched:Connect(function(hitPart)
		if self.Game.Player == game.Players:GetPlayerFromCharacter(hitPart.Parent) then
			touchConnect:Disconnect()
			game:GetService("TweenService")
				:Create(
					Lighting:FindFirstChild("ColorCorrection"),
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{ Brightness = 3 }
				)
				:Play()
			local teleportWall = self.CorridorTeleports[math.random(#self.CorridorTeleports)]
			self:CreateCorridorContent(self.Corridor, teleportWall)
			self.Game.Player.Character:MoveTo(teleportWall.Position)
			portalWall:Destroy()
		end
	end)
end

function Stage:Action()
	self:CreateBlackRoomContent()
end

function Stage:SubscribeEvents()

	-- self.Game.Events.Remotes.
end

-- function Stage:FinishAction()
-- 	if self.Game.PlayerManager.Result ~= nil then
-- 		print(self.Game.PlayerManager.Result)
-- 	else
-- 		self.Game.PlayerManager.Result = true
-- 		print(self.Game.PlayerManager.Result)
-- 	end
-- end

function Stage:Init()
	print("start final stage")

	local pivot, size = game:GetService("CollectionService"):GetTagged("PrevRoom")[1]:GetBoundingBox()
	game:GetService("CollectionService"):GetTagged("PrevRoom")[1]:Destroy()
	self.SpawnPivot = { pivot, size }

	self:CreateCorridor()
	self:Setup()
	self:Action()

	repeat wait() until self.IsReady

	print("finish final stage")
end

return Stage
