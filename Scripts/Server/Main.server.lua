local ServerScriptService = game:GetService("ServerScriptService")
local Game = require(ServerScriptService.Modules.Game)

game.Players.PlayerAdded:Connect(function(player)
    Game.newGame(player)
end)
