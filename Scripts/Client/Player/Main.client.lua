local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientManager = require(ReplicatedStorage.Modules.ClientManager)

local player = game:GetService('Players').LocalPlayer

ClientManager.StartGame(player)


