local ReplicatedStorage = game:GetService("ReplicatedStorage")


local GameManager = {}

function GameManager.CreateStartMenu()
	-- local playerGui = player.PlayerGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = game:GetService("ReplicatedFirst")
	screenGui.Name = "MainGui"
	screenGui.IgnoreGuiInset = true

	local background = Instance.new("Frame")
	background.Parent = screenGui
	background.Size = UDim2.fromScale(1, 1)
	background.Name = "Background"

	local backgroundImage = Instance.new("ImageLabel")
	backgroundImage.Parent = background
	backgroundImage.Name = "backgroundImage"
	backgroundImage.Size = UDim2.fromScale(1, 1)

	local startButton = Instance.new("TextButton")
	startButton.Parent = background
	startButton.Name = "StartButton"
	startButton.Size = UDim2.fromScale(0.5, 0.2)
	startButton.Text = "Start"
	startButton.Position = UDim2.fromScale(0.5, 0.5)
	startButton.AnchorPoint = Vector2.new(0.5, 0.5)
end

function GameManager.CreateEvents()
    local Remotes = Instance.new('Folder')
    Remotes.Name = 'Remotes'
    Remotes.Parent = ReplicatedStorage

	local function createEvent(name)
		local s = Instance.new('RemoteEvent')
		s.Name = name
		s.Parent = Remotes
	end

	createEvent('StartGame')
	createEvent('SetupCamera')
end

return GameManager
