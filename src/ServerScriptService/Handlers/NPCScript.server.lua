--rblx: doctorreproduce // ETHAN SAW
--randomly spawns NPCs throughout the map for players to battle and possibly capture

local ServerStorage = game:GetService("ServerStorage")
local Spawner = game:GetService("Workspace"):WaitForChild("SpawnPart")
local Template = ServerStorage:WaitForChild("NPCTemplate")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExoticAnimals = ReplicatedStorage:WaitForChild("ExoticAnimalSettings")
local Players = game:GetService("Players")
local BattleRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Battle")

BattleRemotes.NPCBattle.OnServerEvent:Connect(function(Player, Ready, Exit)
	if Exit then
		Player:SetAttribute("NPCBattle", nil)
	end
end)

while wait(10) do
	local NewNPC = Template:Clone()
	local NumberOfAnimals = #ExoticAnimals:GetChildren()
	local RandomNPC = math.random(1, NumberOfAnimals)
	for i, v in ipairs(ExoticAnimals:GetChildren()) do
		if i == RandomNPC then
			NewNPC.Decal.Texture = require(v).ImageID
			NewNPC.Parent = game.Workspace
			NewNPC.Position = Spawner.Position + Vector3.new(math.random(-Spawner.Size.X/2, Spawner.Size.X/2), 2, math.random(-Spawner.Size.Z/2, Spawner.Size.Z/2))
			
			NewNPC.Touched:Connect(function(Part)
				if Part:IsA("BasePart") and Part.Parent then
					local Player = Players:GetPlayerFromCharacter(Part.Parent)
					if Player and not Player:GetAttribute("NPCBattle") then
						Player:SetAttribute("NPCBattle", v.Name)
						BattleRemotes.NPCBattle:FireClient(Player)
						NewNPC:Destroy()
					end
				end
			end)
		end
	end
end