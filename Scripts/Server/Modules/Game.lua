local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Locations = ServerScriptService.Locations

local GameManager = require(ServerScriptService.Modules.GameManager)

local Game = {}

Game.__index = Game

function Game.newGame(player)
    -- print(player)
    local self = setmetatable({}, Game)

    self.Player = player
    self.LocationIndex = 1

    self:Init()

    return self
    
end

function Game:Init()
    self:Preload()
    self.Events.Remotes.StartGame.OnServerEvent:Wait()
    -- print('Start Game')
    self:StartGame()
end

function Game:Preload()
    GameManager.CreateEvents()
    GameManager.CreateStartMenu()

    self.PlayerManager = require(ServerScriptService.Modules.PlayerManager)
    self.Events = require(ReplicatedStorage.Modules.Events)
end

function Game:StartGame()
    for i = 2, #Locations:GetChildren() do
        local location = require(Locations:FindFirstChild('Location' .. self.LocationIndex)) 
        location.Create(self)
    end
end

return Game