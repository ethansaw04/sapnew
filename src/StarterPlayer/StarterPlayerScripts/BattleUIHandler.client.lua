--rblx: doctorreproduce // ETHAN SAW

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player.PlayerGui
local UI = PlayerGui:WaitForChild("BattleUI")
local ShopRoster = UI:WaitForChild("ShopRoster")
local CurrentRoster = UI:WaitForChild("CurrentRoster")
local CurrentlySelected = nil
local BattleRemotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Battle")
local Gold = UI:WaitForChild("Gold")
local Lives = UI:WaitForChild("Lives")
local Turn = UI:WaitForChild("Turn")
local ReadyButton = UI:WaitForChild("ReadyFrame"):WaitForChild("TextButton")
local RandomizeButton = UI:WaitForChild("RandomizeShop"):WaitForChild("TextButton")
local ExitButton = UI:WaitForChild("ExitFrame"):WaitForChild("TextButton")
local Ready = false
local EnemyRoster = UI:WaitForChild("EnemyRoster")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

for i, v in ipairs(ShopRoster:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			if not Ready then
				--selection of items in shop
				v.BorderColor3 = Color3.fromRGB(255, 255, 0)
				CurrentlySelected = v
				
				for _, val in ipairs(ShopRoster:GetChildren()) do
					if val:IsA("ImageButton") and v ~= val then
						val.BorderColor3 = Color3.fromRGB(0, 0, 0)
					end
				end
			end
		end)
	end
end

for i, v in ipairs(CurrentRoster:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			if CurrentlySelected and not Ready then
				local RosterPosition = string.sub(v.Name, string.len(v.Name), string.len(v.Name))
				
				if not Player.GameAttributes["Animal" .. RosterPosition].Value then
					for _, val in ipairs(ShopRoster:GetChildren()) do
						if val:IsA("ImageButton") then
							val.BorderColor3 = Color3.fromRGB(0, 0, 0)
						end
					end
					
					--buy items in shop
					
					local Purchase = BattleRemotes.Purchase:InvokeServer(CurrentlySelected.NameValue.Value, tonumber(string.sub(v.Name, string.len(v.Name), string.len(v.Name))), CurrentlySelected)
					
					if Purchase then
						CurrentlySelected.Visible = false
						CurrentlySelected.NameValue.Value = ""
						CurrentlySelected = nil
					end
				elseif Player.GameAttributes["Animal" .. RosterPosition].Value and Player.GameAttributes["Animal" .. RosterPosition].Value.Name == CurrentlySelected.NameValue.Value then
					--upgrade current animals by buying
					
					local XP = Player.GameAttributes["Animal" .. RosterPosition].Value:FindFirstChild("XP")
					local MaxXP = Player.GameAttributes["Animal" .. RosterPosition].Value:FindFirstChild("MaxXP")
					local Level = Player.GameAttributes["Animal" .. RosterPosition].Value:FindFirstChild("Level")
					local MaxLevel = Player.GameAttributes["Animal" .. RosterPosition].Value:FindFirstChild("MaxLevel")
					if XP and MaxXP and Level and MaxLevel then
						if Level.Value < MaxLevel.Value then
							for _, val in ipairs(ShopRoster:GetChildren()) do
								if val:IsA("ImageButton") then
									val.BorderColor3 = Color3.fromRGB(0, 0, 0)
								end
							end

							local Purchase = BattleRemotes.Purchase:InvokeServer(CurrentlySelected.NameValue.Value, tonumber(string.sub(v.Name, string.len(v.Name), string.len(v.Name))), CurrentlySelected)
							
							if Purchase then
								CurrentlySelected.Visible = false
								CurrentlySelected.NameValue.Value = ""
								CurrentlySelected = nil
							end
						end
					end
				end
			end
		end)
	end
end

for i, v in ipairs(Player.GameAttributes:GetChildren()) do
	if string.sub(v.Name, 1, 6) == "Animal" then
		local Location = tonumber(string.sub(v.Name, 7, 7))
		v.Changed:Connect(function(NewValue)
			--update animal UI whenever player animals are changed
			
			local RosterIcon = CurrentRoster:FindFirstChild("Animal" .. tostring(Location))
			
			if RosterIcon then
				if NewValue then
					RosterIcon.Frame.Visible = true
					RosterIcon.Frame.Damage.TextLabel.Text = tostring(NewValue.Damage.Value)
					RosterIcon.Frame.Health.TextLabel.Text = tostring(NewValue.Health.Value)
					RosterIcon.Image = NewValue.ImageID.Value
					
					NewValue.Damage.Changed:Connect(function(DmgVal)
						RosterIcon.Frame.Damage.TextLabel.Text = tostring(DmgVal)
					end)

					NewValue.Health.Changed:Connect(function(HltVal)
						RosterIcon.Frame.Health.TextLabel.Text = tostring(HltVal)
					end)
				else
					RosterIcon.Frame.Visible = false
					RosterIcon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
				end
			end
		end)
	end
end

Player.GameAttributes:WaitForChild("Gold").Changed:Connect(function(NewValue)
	Gold.Frame.TextLabel.Text = tostring(NewValue)
end)

Player.GameAttributes:WaitForChild("Lives").Changed:Connect(function(NewValue)
	Lives.Frame.TextLabel.Text = tostring(NewValue)
end)

Player.GameAttributes:WaitForChild("Turn").Changed:Connect(function(NewValue)
	Turn.Frame.TextLabel.Text = tostring(NewValue)
end)

ReadyButton.MouseButton1Click:Connect(function()
	if not Ready then
		if not Player:GetAttribute("NPCBattle") then
			Ready = true
			BattleRemotes.Ready:FireServer()
			ReadyButton.Parent.Frame.TextLabel.Text = "Waiting.."
		else
			Ready = false
			BattleRemotes.Ready:FireServer(Player:GetAttribute("NPCBattle"))
			ReadyButton.Parent.Frame.TextLabel.Text = "Waiting.."
		end
	end
end)

RandomizeButton.MouseButton1Click:Connect(function()
	if not Ready then
		if Player.GameAttributes.Gold.Value >= 1 then
			BattleRemotes.RandomizeShop:FireServer()
		end
	end
end)

ExitButton.MouseButton1Click:Connect(function()
	if not Player:GetAttribute("NPCBattle") then
		PlayerGui:WaitForChild("IdleUI").Enabled = true
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		
		Ready = false
		ReadyButton.Parent.Frame.TextLabel.Text = "Ready Up"
		
		PlayerGui:WaitForChild("BattleUI").Enabled = false
	else
		BattleRemotes.NPCBattle:FireServer(false, true)
		PlayerGui:WaitForChild("IdleUI").Enabled = true
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		
		Ready = false
		ReadyButton.Parent.Frame.TextLabel.Text = "Ready Up"

		PlayerGui:WaitForChild("BattleUI").Enabled = false
	end
end)

BattleRemotes.Battle.OnClientEvent:Connect(function(Roster)
	for i, v in ipairs(EnemyRoster:GetChildren()) do
		if Roster[i] then
			v.Frame.Visible = true
			v.Frame.Damage.TextLabel.Text = Roster[i].Damage.Value
			v.Frame.Health.TextLabel.Text = Roster[i].Health.Value
			v.Image = Roster[i].ImageID.Value
		else
			v.Frame.Visible = false
			v.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		end
	end
end)

BattleRemotes.StartBattle.OnClientEvent:Connect(function(Starting)
	if Starting then
		ShopRoster.Visible = false
		ReadyButton.Parent.Visible = false
		TweenService:Create(CurrentRoster, TweenInfo.new(3), {Position = UDim2.new(0.3, 0, 0.6, 0) }):Play()
		
		task.wait(3)
		
		EnemyRoster.Visible = true
	else
		EnemyRoster.Visible = false
		TweenService:Create(CurrentRoster, TweenInfo.new(3), {Position = UDim2.new(0.5, 0, 0.4, 0) }):Play()
		
		task.wait(3)
		
		ShopRoster.Visible = true
		ReadyButton.Parent.Visible = true
		Ready = false
		ReadyButton.Parent.Frame.TextLabel.Text = "Ready Up"
	end
end)

BattleRemotes.RandomizeShop.OnClientEvent:Connect(function(NewShopRoster)
	local ShopIcons = { }
	
	for i, v in ipairs(ShopRoster:GetChildren()) do
		if v:IsA("ImageButton") then
			table.insert(ShopIcons, v)
		end
	end
	
	for i, v in ipairs(ShopIcons) do
		if ReplicatedStorage.AnimalSettings:FindFirstChild(NewShopRoster[i]) then
			local Module = require(game.ReplicatedStorage.AnimalSettings[NewShopRoster[i]])
			v.NameValue.Value = NewShopRoster[i]
			v.Frame.Damage.TextLabel.Text = tostring(Module.Damage)
			v.Frame.Health.TextLabel.Text = tostring(Module.Health)
			v.Frame.Visible = true
			v.Image = Module.ImageID
			v.Visible = true
		end
	end
end)

BattleRemotes.NPCBattle.OnClientEvent:Connect(function(Roster)
	if not Roster then
		game.Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		game.Workspace.CurrentCamera.CFrame = CFrame.new(Vector3.new(0,50,0), Vector3.new(0,100,0))
		
		Player.PlayerGui:WaitForChild("BattleUI").Enabled = true
		Player.PlayerGui:WaitForChild("IdleUI").Enabled = false
	end
end)
