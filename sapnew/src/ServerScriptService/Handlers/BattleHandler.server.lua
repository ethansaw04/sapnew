--rblx: doctorreproduce // ETHAN SAW

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animals = ReplicatedStorage:WaitForChild("AnimalSettings")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BattleRemotes = Remotes:WaitForChild("Battle")

local ReadyPlayers = { }

function ChooseRandomAnimals()
	--returns animals to be put into a player's shop in the next round
	local NewShopRoster = { }
	for i = 1, 3 do
		local RandomNumber = math.random(1, #Animals:GetChildren())
		for index, animal in ipairs(Animals:GetChildren()) do
			if index == RandomNumber then
				table.insert(NewShopRoster, animal.Name)
			end
		end
	end
	return NewShopRoster
end
	
function CreateAnimal(Player, Animal: string)
	--creates an animal
	
	local Module
	if not Player then
		Module = ReplicatedStorage:WaitForChild("ExoticAnimalSettings"):FindFirstChild(Animal)
	else
		Module = Animals:FindFirstChild(Animal)
	end
	if Module then
		local AnimalInstance = Instance.new("Folder")
		AnimalInstance.Name = Animal
		local AnimalModule = require(Module)
		if Player then
			--create for player
			if Player.GameAttributes.Gold.Value >= AnimalModule.Cost then
				Player.GameAttributes.Gold.Value -= AnimalModule.Cost
				for i,v in AnimalModule do
					if type(v) == "string" then
						local StringValue = Instance.new("StringValue")
						StringValue.Name = i
						StringValue.Value = v
						StringValue.Parent = AnimalInstance
					elseif type(v) == "number" then
						local NumberValue = Instance.new("NumberValue")
						NumberValue.Name = i
						NumberValue.Value = v
						NumberValue.Parent = AnimalInstance
						if i == "Health" then
							NumberValue.Changed:Connect(function(NewValue)
								if NewValue <= 0 then
									for _,val in ipairs(Player.GameAttributes:GetChildren()) do
										if val.Value == AnimalInstance then
											val.Value = nil
										end
									end
									AnimalInstance:Destroy()
								end
							end)
						end
					end
				end
				
			else
				return nil
			end
			
			return AnimalInstance
		else
			--creating npc
			for i,v in AnimalModule do
				if type(v) == "string" then
					local StringValue = Instance.new("StringValue")
					StringValue.Name = i
					StringValue.Value = v
					StringValue.Parent = AnimalInstance
				elseif type(v) == "number" then
					local NumberValue = Instance.new("NumberValue")
					NumberValue.Name = i
					NumberValue.Value = v
					NumberValue.Parent = AnimalInstance
					if i == "Health" then
						--NumberValue.Value *= 5
						--buff up the exotic animals to capture them
						NumberValue.Changed:Connect(function(NewValue)
							if NewValue <= 0 then
								AnimalInstance:Destroy()
							end
						end)
					end
				end
			end
		end
			
		return AnimalInstance
	end
	return nil
end

function UpgradeAnimal(Player, Animal)
	local XP = Animal:FindFirstChild("XP")
	local MaxXP = Animal:FindFirstChild("MaxXP")
	local Level = Animal:FindFirstChild("Level")
	local MaxLevel = Animal:FindFirstChild("MaxLevel")
	local Health = Animal:FindFirstChild("Health")
	local Damage = Animal:FindFirstChild("Damage")
	local LevelUpEffect = Animal:FindFirstChild("LevelUpEffect")
		
	if not (Level.Value >= MaxLevel.Value) then
		if XP.Value < MaxXP.Value then
			XP.Value += 1
			Health.Value += 1
			Damage.Value += 1
			
			if XP.Value >= MaxXP.Value then
				XP.Value = 0
				MaxXP.Value += 1
				Level.Value += 1
				
				if LevelUpEffect then
					if LevelUpEffect == "UpgradeFriends" then
						for i, v in ipairs(Player.Animals:GetChildren()) do
							if v ~= Animal then
								v.Health.Value += 1
								v.Damage.Value += 1
							end
						end
					end
				end
			end
		end
	end
end

function Battle(Matchup)
	--battles two players animal lineups together
	if type(Matchup["Player2"]) == "string" then
		--npc battle
		spawn(function()
			BattleRemotes.StartBattle:FireClient(Matchup["Player1"], true)

			task.wait(4)

			local Player1Animals = { }
			local AnimalNPC = CreateAnimal(false, Matchup["Player2"])
			local Player2Animals = {AnimalNPC}
			Player2Animals[1].Parent = ReplicatedStorage.NPCAnimals
			
			local function FindAnimals()
				Player1Animals = { }
				Player2Animals = { }

				for i,v in ipairs(Matchup["Player1"].GameAttributes:GetChildren()) do
					if string.sub(v.Name, 1, 6) == "Animal" and v.Value then
						table.insert(Player1Animals, v.Value)
					end
				end
				
				if AnimalNPC and AnimalNPC.Parent == ReplicatedStorage.NPCAnimals then
					Player2Animals = {AnimalNPC}
				end
			end
			
			FindAnimals()
			
			while #Player1Animals > 0 and #Player2Animals > 0 do
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)
				local PlayerAnimal1NewHealth = Player1Animals[1].Health.Value - Player2Animals[1].Damage.Value
				local PlayerAnimal2NewHealth = Player2Animals[1].Health.Value - Player1Animals[1].Damage.Value
				Player1Animals[1].Health.Value = PlayerAnimal1NewHealth
				Player2Animals[1].Health.Value = PlayerAnimal2NewHealth

				FindAnimals()
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)

				task.wait(1)
			end
			if not (#Player1Animals > 0 and #Player2Animals > 0) then
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)
				BattleRemotes.StartBattle:FireClient(Matchup["Player1"], false)

				if not (#Player1Animals > 0) then
					Matchup["Player1"].GameAttributes.Lives.Value -= 1
					Player2Animals[1]:Destroy()
				elseif not (#Player2Animals > 0) then
					Matchup["Player1"].GameAttributes.Gems.Value += 1
				end

				Matchup["Player1"].GameAttributes.Turn.Value += 1
				Matchup["Player1"].GameAttributes.Gold.Value = 10 + (2 * Matchup["Player1"].GameAttributes.Turn.Value)
				Matchup["Player1"]:SetAttribute("NPCBattle", nil)
				BattleRemotes.RandomizeShop:FireClient(Matchup["Player1"], ChooseRandomAnimals())
			end
		end)
	else
		spawn(function()
			BattleRemotes.StartBattle:FireClient(Matchup["Player1"], true)
			BattleRemotes.StartBattle:FireClient(Matchup["Player2"], true)

			task.wait(4)

			local Player1Animals = { }
			local Player2Animals = { }

			local function FindAnimals()
				Player1Animals = { }
				Player2Animals = { }
				for i,v in ipairs(Matchup["Player1"].GameAttributes:GetChildren()) do
					if string.sub(v.Name, 1, 6) == "Animal" and v.Value then
						table.insert(Player1Animals, v.Value)
					end
				end

				for i,v in ipairs(Matchup["Player2"].GameAttributes:GetChildren()) do
					if string.sub(v.Name, 1, 6) == "Animal" and v.Value then
						table.insert(Player2Animals, v.Value)
					end
				end
			end

			FindAnimals()

			while #Player1Animals > 0 and #Player2Animals > 0 do
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)
				BattleRemotes.Battle:FireClient(Matchup["Player2"], Player1Animals)
				local PlayerAnimal1NewHealth = Player1Animals[1].Health.Value - Player2Animals[1].Damage.Value
				local PlayerAnimal2NewHealth = Player2Animals[1].Health.Value - Player1Animals[1].Damage.Value
				Player1Animals[1].Health.Value = PlayerAnimal1NewHealth
				Player2Animals[1].Health.Value = PlayerAnimal2NewHealth

				FindAnimals()
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)
				BattleRemotes.Battle:FireClient(Matchup["Player2"], Player1Animals)

				task.wait(1)
			end
			if not (#Player1Animals > 0 and #Player2Animals > 0) then
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)
				BattleRemotes.Battle:FireClient(Matchup["Player2"], Player1Animals)
				BattleRemotes.StartBattle:FireClient(Matchup["Player1"], false)
				BattleRemotes.StartBattle:FireClient(Matchup["Player2"], false)

				if not (#Player1Animals > 0) then
					Matchup["Player1"].GameAttributes.Lives.Value -= 1
				elseif not (#Player2Animals > 0) then
					Matchup["Player2"].GameAttributes.Lives.Value -= 1
				end

				Matchup["Player1"].GameAttributes.Turn.Value += 1
				Matchup["Player1"].GameAttributes.Gold.Value = 10 + (2 * Matchup["Player1"].GameAttributes.Turn.Value)
				Matchup["Player2"].GameAttributes.Turn.Value += 1
				Matchup["Player2"].GameAttributes.Gold.Value = 10 + (2 * Matchup["Player1"].GameAttributes.Turn.Value)
				BattleRemotes.RandomizeShop:FireClient(Matchup["Player1"], ChooseRandomAnimals())
				BattleRemotes.RandomizeShop:FireClient(Matchup["Player2"], ChooseRandomAnimals())
			end
		end)
	end
end

BattleRemotes.Purchase.OnServerInvoke = function(Player, Animal: string, Location, ImageBox)
	if not Player.GameAttributes:FindFirstChild("Animal" .. tostring(Location)).Value then
		local AnimalInstance = CreateAnimal(Player, Animal)
		if AnimalInstance then
			AnimalInstance.Parent = Player.Animals
			local LocationValue = Player.GameAttributes:FindFirstChild("Animal" .. tostring(Location))
			if LocationValue and not LocationValue.Value  then
				LocationValue.Value = AnimalInstance
			end
			return true
		end
	elseif Player.GameAttributes:FindFirstChild("Animal" .. tostring(Location)).Value and Player.GameAttributes["Animal" .. tostring(Location)].Value.Name == Animal then
		Player.GameAttributes.Gold.Value -= 3
		UpgradeAnimal(Player, Player.GameAttributes["Animal" .. tostring(Location)].Value)
		return true
	end
end

BattleRemotes.Sell.OnServerEvent:Connect(function(Player, Animal)
	if not Animal:IsDescendantOf(Player) then return end
	if Animal:FindFirstChild("Cost") and Animal:FindFirstChild("Level") then
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
end)

BattleRemotes.Ready.OnServerEvent:Connect(function(Player, NPC)
	if not NPC then
		if #ReadyPlayers > 0 then
			local Matchup = { Player1 = Player, Player2 = ReadyPlayers[1] }
			Battle(Matchup)
			table.remove(ReadyPlayers, 1)
		elseif ReadyPlayers[1] ~= Player then
			table.insert(ReadyPlayers, Player)	
		end
	else
		local Matchup = { Player1 = Player, Player2 = NPC }
		Battle(Matchup)
	end
end)

BattleRemotes.RandomizeShop.OnServerEvent:Connect(function(Player)
	if Player.GameAttributes.Gold.Value >= 1 then
		Player.GameAttributes.Gold.Value -= 1
		BattleRemotes.RandomizeShop:FireClient(Player, ChooseRandomAnimals())
	end
end)