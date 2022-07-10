local ModifyModule = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animals = ReplicatedStorage:WaitForChild("AnimalSettings")
local BattleRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Battle")


function ModifyModule.UpgradeAnimal(Player, Animal)
	local XP = Animal:FindFirstChild("XP")
	local MaxXP = Animal:FindFirstChild("MaxXP")
	local Level = Animal:FindFirstChild("Level")
	local MaxLevel = Animal:FindFirstChild("MaxLevel")
	local Health = Animal:FindFirstChild("Health")
	local Damage = Animal:FindFirstChild("Damage")
	local LevelUpEffect = Animal:FindFirstChild("LevelUpEffect")

	if Level and MaxLevel and not (Level.Value >= MaxLevel.Value) then
		if XP and MaxXP and Damage and Health and XP.Value < MaxXP.Value then
			XP.Value += 1
			Health.Value += 1
			Damage.Value += 1
			--upgrade animal with XP and slight stats buff

			if XP.Value >= MaxXP.Value then
				XP.Value = 0
				MaxXP.Value += 1
				Level.Value += 1
				--upgrade animals level, resetting XP to zero and giving it stronger special effects

				if LevelUpEffect then
					if LevelUpEffect == "UpgradeFriends" then
						for i, v in ipairs(Player.Animals:GetChildren()) do
							if v ~= Animal then
								v.Health.Value += 1
								v.Damage.Value += 1
								--certain animals have upgrade effects which can for example upgrade other friendly pets alive
							end
						end
					end
				end
			end
		end
	end
end


function ModifyModule.CreateAnimal(Player, Animal: string)
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
					--recreate stats for new animal
					local Value = if type(v) == "string" then Instance.new("StringValue") else Instance.new("NumberValue")
					Value.Name = i
					Value.Value = v
					Value.Parent = AnimalInstance
					if i == "Health" then
						Value.Changed:Connect(function(NewValue)
							if NewValue <= 0 then
								for _,val in ipairs(Player.GameAttributes:GetChildren()) do
									if val.Value == AnimalInstance then
										val.Value = nil
									end
								end
								--remove animal if its dead
								AnimalInstance:Destroy()
							end
						end)
					end
				end

			else
				return nil
			end

			return AnimalInstance
		else
			--creating npc
			for i,v in AnimalModule do
				local Value = if type(v) == "string" then Instance.new("StringValue") else Instance.new("NumberValue")
				Value.Name = i
				Value.Value = v
				Value.Parent = AnimalInstance
				if i == "Health" then
					Value.Value *= 5
					--buff up the exotic animals to capture them
					Value.Changed:Connect(function(NewValue)
						if NewValue <= 0 then
							AnimalInstance:Destroy()
						end
					end)
				end
			end
		end

		return AnimalInstance
	end
	return nil
end

return ModifyModule
