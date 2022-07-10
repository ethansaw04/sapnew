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
						NumberValue.Value *= 5
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

return ModifyModule