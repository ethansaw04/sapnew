--rblx: doctorreproduce // ETHAN SAW

local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("UserData")

local function SaveData(Player)

	local Save = {
		Player.GameAttributes.Gems.Value,
	}

	local Success, Error = pcall(function()
		dataStore:SetAsync(Player.UserId, Save) 
	end)

	if not Success then
		warn(Error)		
	end
end

game.Players.PlayerAdded:Connect(function(Player)
	
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
	
	local Gems = Instance.new("IntValue")
	Gems.Name = "Gems"
	Gems.Parent = Player.GameAttributes

	local Data
	local Success, Error = pcall(function()

		Data = dataStore:GetAsync(Player.UserId)

	end)

	if Success and Data then

		Gems.Value = Data[1]

	else
		warn("Player has no data!")
	end

end)

game.Players.PlayerRemoving:Connect(function(Player)
	local Success, Error  = pcall(function()
		SaveData(Player)
	end)

	if not Success then
		warn("Data not saved!")
	end
end)

game:BindToClose(function()
	for _, Player in pairs(game.Players:GetPlayers()) do 
		local Success, Error  = pcall(function()
			SaveData(Player) 
		end)

		if not Success then
			warn("Data has not been saved!")
		end
	end
end)