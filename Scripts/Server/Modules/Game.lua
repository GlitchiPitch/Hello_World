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
    self.Events = {}
    self.PlayerManager = nil

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
    GameManager.CreateStartMenu(self.Player)

    self.PlayerManager = require(ServerScriptService.Modules.PlayerManager)
    self.CommonFunctions = require(ServerScriptService.Modules.CommonFunctions)
    self.Events = require(ReplicatedStorage.Modules.Events)
end

function Game:StartGame()
    -- for i = 1, #Locations:GetChildren() do
    --     print('start Location')
    --     local location = require(Locations:FindFirstChild('Location' .. self.LocationIndex)) 
    --     location.Create(self)
    --     self.LocationIndex += 1
    -- end

    for _, location in pairs(Locations:GetChildren()) do
        require(location).Create(self)
    end
end

return Game