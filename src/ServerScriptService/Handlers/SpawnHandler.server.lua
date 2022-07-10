--rblx: doctorreproduce // ETHAN SAW

--[[
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(Player)
	local GameAttributes = Instance.new("Folder")
	GameAttributes.Name = "GameAttributes"
	GameAttributes.Parent = Player
	
	local AnimalFolder = Instance.new("Folder")
	AnimalFolder.Name = "Animals"
	AnimalFolder.Parent = Player
	
	local Gold = Instance.new("IntValue")
	Gold.Name = "Gold"
	Gold.Value = 10
	Gold.Parent = GameAttributes
	
	local Lives = Instance.new("IntValue")
	Lives.Name = "Lives"
	Lives.Value = 10
	Lives.Parent = GameAttributes
	
	local Turn = Instance.new("IntValue")
	Turn.Name = "Turn"
	Turn.Parent = GameAttributes
	
	for i = 1, 5 do
		local AnimalPlace = Instance.new("ObjectValue")
		AnimalPlace.Name = "Animal" .. tostring(i)
		AnimalPlace.Parent = GameAttributes
	end
	
	for i = 1, 3 do
		local ShopPlaceAnimal = Instance.new("ObjectValue")
		ShopPlaceAnimal.Name = "ShopAnimal" .. tostring(i)
		ShopPlaceAnimal.Parent = GameAttributes
	end
	
	for i = 1, 3 do
		local ShopPlaceItem = Instance.new("ObjectValue")
		ShopPlaceItem.Name = "ShopItem" .. tostring(i)
		ShopPlaceItem.Parent = GameAttributes
	end
end)]]