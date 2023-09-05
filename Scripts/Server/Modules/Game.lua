local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService.Modules
local Locations = ServerScriptService.Locations




local GameManager = require(Modules.GameManager)




local Game = {}

Game.__index = Game

function Game.newGame(player)
    print(player)
    local self = setmetatable({}, Game)

    self.Player = player
    self.LocationIndex = 1
    

    self:Init()

    return self
    
end

function Game:Init()
    self:Preload()
    self.Events.Remotes.StartGame.OnServerEvent:Wait()
    print('Start Game')
    self:StartGame()
end

function Game:Preload()
    GameManager.CreateEvents()
    GameManager.CreateStartMenu()

    self.PlayerManager = require(Modules.PlayerManager)
    self.Events = require(ReplicatedStorage.Modules.Events)
end

function Game:StartGame()
    self.Player:LoadCharacter()
    for i = 2, #Locations:GetChildren() do
        local location = require(Locations:FindFirstChild('Location' .. self.LocationIndex)) 
        self.PlayerManager.SetupCharacter(self.Player, location.PlayerProperty)
    end
    -- self.StartMenu = GameManager.StartMenu()
    -- self.StartMenu.Background.StartButton.Mouse.MouseButton1Click:Wait()

end

return Game