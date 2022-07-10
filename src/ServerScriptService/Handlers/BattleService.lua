--rblx: doctorreproduce // ETHAN SAW

local BattleService = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animals = ReplicatedStorage:WaitForChild("AnimalSettings")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BattleRemotes = Remotes:WaitForChild("Battle")

local ReadyPlayers = { }

local BattleModule = require(script.Parent.BattleModules.Battle)
local ModifyModule = require(script.Parent.BattleModules.ModifyAnimal)

function BattleService.HandlePurchaseEvent(Player, Animal: string, Location, ImageBox)
	if Player and not Player.GameAttributes:FindFirstChild("Animal" .. tostring(Location)).Value then
		local AnimalInstance = ModifyModule.CreateAnimal(Player, Animal)
		if AnimalInstance then
			AnimalInstance.Parent = Player.Animals
			local LocationValue = Player.GameAttributes:FindFirstChild("Animal" .. tostring(Location))
			if LocationValue and not LocationValue.Value  then
				LocationValue.Value = AnimalInstance
			end
			return true
		end
	elseif Player and Player.GameAttributes:FindFirstChild("Animal" .. tostring(Location)).Value and Player.GameAttributes["Animal" .. tostring(Location)].Value.Name == Animal then
		Player.GameAttributes.Gold.Value -= 3
		ModifyModule.UpgradeAnimal(Player, Player.GameAttributes["Animal" .. tostring(Location)].Value)
		return true
	end
end

function BattleService.HandleSellEvent(Player, Animal)
	if Animal and not Animal:IsDescendantOf(Player) then return end
	if Animal and Animal:FindFirstChild("Cost") and Animal:FindFirstChild("Level") then
		local SellValue = (Animal.Cost.Value / 2) * Animal.Level.Value

		if Animal:FindFirstChild("SellEffect") then
			if Animal.SellEffect.Value == "GainGold" then
				SellValue += Animal.Level.Value
			elseif Animal.SellEffect.Value == "RandomUpgrade" then
				local RandomNumber = #Player.Animals:GetChildren() > 0 and math.random(1, #Player.Animals:GetChildren())

				for i, v in ipairs(Player.Animals:GetChildren()) do
					if i == RandomNumber then
						v.Health.Value += Animal.Level
						v.Damage.Value += Animal.Level
					end
				end
			end
		end

		Player.GameAttributes.Gold.Value += SellValue
		Animal:Destroy()
	end
end

function BattleService.HandleReadyEvent(Player, NPC)
	if not NPC then
		if #ReadyPlayers > 0 then
			local Matchup = { Player1 = Player, Player2 = ReadyPlayers[1] }
			BattleModule.Battle(Matchup)
			table.remove(ReadyPlayers, 1)
		elseif ReadyPlayers[1] ~= Player then
			table.insert(ReadyPlayers, Player)	
		end
	else
		local Matchup = { Player1 = Player, Player2 = NPC }
		BattleModule.Battle(Matchup)
	end
end

function BattleService.HandleRandomizeShopEvent(Player)
	if Player and Player.GameAttributes.Gold.Value >= 1 then
		Player.GameAttributes.Gold.Value -= 1
		BattleRemotes.RandomizeShop:FireClient(Player, BattleModule.ChooseRandomAnimals())
	end
end


BattleRemotes.Purchase.OnServerInvoke = BattleService.HandlePurchaseEvent
BattleRemotes.Sell.OnServerEvent:Connect(BattleService.HandleSellEvent)
BattleRemotes.Ready.OnServerEvent:Connect(BattleService.HandleReadyEvent)
BattleRemotes.RandomizeShop.OnServerEvent:Connect(BattleService.HandleRandomizeShopEvent)

return BattleService