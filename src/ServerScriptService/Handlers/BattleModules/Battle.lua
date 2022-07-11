local BattleModule = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animals = ReplicatedStorage:WaitForChild("AnimalSettings")
local BattleRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Battle")
local ModifyModule = require(script.Parent.ModifyAnimal)

function BattleModule.ChooseRandomAnimals()
	--returns animals to be put into a player's shop in the next round
	local NewShopRoster = { }
	for i = 1, 3 do
		--3 shop places so repeat for a fixed number of times .. in this case 3
		
		local AnimalsList = #Animals:GetChildren() > 0 and Animals:GetChildren() or nil
		if AnimalsList then
			local RandomAnimal = AnimalsList[math.random(1, #Animals)]
			table.insert(NewShopRoster, RandomAnimal.Name)
		end
	end
	return NewShopRoster
end

function BattleModule.Battle(Matchup)
	--battles two players animal lineups together
	if type(Matchup["Player2"]) == "string" then
		--npc battle
		spawn(function()
			BattleRemotes.StartBattle:FireClient(Matchup["Player1"], true)

			task.wait(4)

			local Player1Animals = { }
			local AnimalNPC = ModifyModule.CreateAnimal(false, Matchup["Player2"])
			local Player2Animals = {AnimalNPC}
			Player2Animals[1].Parent = ReplicatedStorage.NPCAnimals
			
			--create NPC with stats

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
			
			--finds animals alive for player used for battle and check if NPC animal is still alive

			FindAnimals()

			while #Player1Animals > 0 and #Player2Animals > 0 do
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)
				local PlayerAnimal1NewHealth = Player1Animals[1].Health.Value - Player2Animals[1].Damage.Value
				local PlayerAnimal2NewHealth = Player2Animals[1].Health.Value - Player1Animals[1].Damage.Value
				Player1Animals[1].Health.Value = PlayerAnimal1NewHealth
				Player2Animals[1].Health.Value = PlayerAnimal2NewHealth
				
				--battle and update client with new info

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
				
				--find winner of battle and give rewards

				Matchup["Player1"].GameAttributes.Turn.Value += 1
				Matchup["Player1"].GameAttributes.Gold.Value = 10 + (2 * Matchup["Player1"].GameAttributes.Turn.Value)
				Matchup["Player1"]:SetAttribute("NPCBattle", nil)
				BattleRemotes.RandomizeShop:FireClient(Matchup["Player1"], BattleModule.ChooseRandomAnimals())
			end
		end)
	else
		--normal player battle (1v1)
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
			
			--finds animals alive for players used for battle

			FindAnimals()

			while #Player1Animals > 0 and #Player2Animals > 0 do
				BattleRemotes.Battle:FireClient(Matchup["Player1"], Player2Animals)
				BattleRemotes.Battle:FireClient(Matchup["Player2"], Player1Animals)
				local PlayerAnimal1NewHealth = Player1Animals[1].Health.Value - Player2Animals[1].Damage.Value
				local PlayerAnimal2NewHealth = Player2Animals[1].Health.Value - Player1Animals[1].Damage.Value
				Player1Animals[1].Health.Value = PlayerAnimal1NewHealth
				Player2Animals[1].Health.Value = PlayerAnimal2NewHealth
				
				--battle and update client with new info


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
				
				--find winner of battle and give rewards and reset for next battle

				Matchup["Player1"].GameAttributes.Turn.Value += 1
				Matchup["Player1"].GameAttributes.Gold.Value = 10 + (2 * Matchup["Player1"].GameAttributes.Turn.Value)
				Matchup["Player2"].GameAttributes.Turn.Value += 1
				Matchup["Player2"].GameAttributes.Gold.Value = 10 + (2 * Matchup["Player1"].GameAttributes.Turn.Value)
				BattleRemotes.RandomizeShop:FireClient(Matchup["Player1"], BattleModule.ChooseRandomAnimals())
				BattleRemotes.RandomizeShop:FireClient(Matchup["Player2"], BattleModule.ChooseRandomAnimals())
			end
		end)
	end
end

return BattleModule
