--rblx: doctorreproduce // ETHAN SAW

local ServerScriptService = game:GetService("ServerScriptService")
local Handlers = ServerScriptService.Handlers
local Players = game:GetService("Players")

local DataStoreService = require(Handlers.DataStoreService)
local BattleService = require(Handlers.BattleService)
local NPCService = require(Handlers.NPCService)

function PlayerAdded(Player)
	DataStoreService.PlayerAdded(Player)
end

function PlayerLeaving(Player)
	DataStoreService.PlayerRemoving(Player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerLeaving)

NPCService.init()

game:BindToClose(function()
	for _, Player in pairs(game.Players:GetPlayers()) do 
		local Success, Error  = pcall(function()
			DataStoreService.SaveData(Player) 
		end)

		if not Success then
			warn("Data has not been saved!")
		end
	end
end)