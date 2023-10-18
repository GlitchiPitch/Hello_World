-- THIS IS FINAL STAGE --

local function createPart(parent, size, position)
	local part = Instance.new("Part")
	part.Parent = parent
	part.Size = size
	part.Position = position

	return part
end

local Stage = {}

Stage.__index = Stage

function Stage.Create(game_)
	local self = setmetatable({}, Stage)
	self.Game = game_

	self:Init()
	return self
end

function Stage:Setup() end

function Stage:CreateMaze()
	local corridorModel = Instance.new("Model")

	local function createCell(data, basePart)
		local wallHeight = 10

		local w1 = createPart(
			corridorModel,
			Vector3.new(data[1] == 0 and basePart.Size.X or 1, wallHeight, data[2] == 0 and basePart.Size.Z or 1),
			Vector3.new(
				data[1] == 0 and basePart.Position.X or basePart.Position.X - basePart.Size.X / 2,
				(basePart.Position.Y + 0.5) + wallHeight / 2,
				data[2] == 0 and basePart.Position.Z or basePart.Position.Z - basePart.Size.Z / 2
			)
		)
		local w2 = createPart(
			corridorModel,
			Vector3.new(data[1] == 0 and basePart.Size.X or 1, wallHeight, data[2] == 0 and basePart.Size.Z or 1),
			Vector3.new(
				data[1] == 0 and basePart.Position.X or basePart.Position.X + basePart.Size.X / 2,
				(basePart.Position.Y + 0.5) + wallHeight / 2,
				data[2] == 0 and basePart.Position.Z or basePart.Position.Z + basePart.Size.Z / 2
			)
		)
		local roof = createPart(
            corridorModel,
            basePart.Size,
            Vector3.new(0, basePart.Position.Y + wallHeight, 0)
        )
	end
end

function Stage:SubscribeEvents()

	-- self.Game.Events.Remotes.
end

function Stage:FinishAction(result)
	if result == "Fail" then
		print("not ok")
	elseif result == "Success" then
		print("ok")
	end
end

function Stage:Init() end

return Stage
