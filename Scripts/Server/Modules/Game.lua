local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Modules = ServerScriptService.Modules
local Locations = ServerScriptService.Locations

local GameManager = require(Modules.GameManager)
local PlayerManager = require(Modules.PlayerManager)

local Game = {}

Game.__index = Game

function Game.newGame(player)
    local self = setmetatable({}, Game)

    self.Player = player
    self.LocationIndex = 1
    

    self:Init()

    return self
    
end

function Game:Init()
    self:Preload()
    self.Events.Remotes.StartGame.OnServerEvent:Wait()
    -- repeat wait() until game:IsLoaded()
    print('Start Game')
    self:StartGame()
end

function Game:Preload()
    PlayerManager.SetupPlayer(self.Player)
    GameManager.CreateEvents()
    GameManager.CreateStartMenu()
    self.Events = require(ReplicatedStorage.Modules.Events)
end

function Game:StartGame()
    self.Player:LoadCharacter()
    for i = 2, #Locations:GetChildren() do
        local location = require(Locations:FindFirstChild('Location' .. self.LocationIndex)) 
        PlayerManager.SetupCharacter(self.Player, location.PlayerProperty)
    end
    -- self.StartMenu = GameManager.StartMenu()
    -- self.StartMenu.Background.StartButton.Mouse.MouseButton1Click:Wait()

end

return Game