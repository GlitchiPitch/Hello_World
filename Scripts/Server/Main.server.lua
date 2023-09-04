local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")


local Modules = ServerScriptService.Modules

local PlayerManager = require(Modules.PlayerManager)
local Game = require(Modules.Game)

Players.PlayerAdded:Connect(function(player)
    -- PlayerManager.SetupPlayer(player)
    Game.newGame(player)
end)
