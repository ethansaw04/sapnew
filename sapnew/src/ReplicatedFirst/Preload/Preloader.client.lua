--rblx: doctorreproduce // ETHAN SAW

local ContentProvider = game:GetService("ContentProvider")
local Player = game:GetService("Players").LocalPlayer
local Camera = game.Workspace.CurrentCamera

local UI = script.Parent
UI.Parent = Player.PlayerGui

local Assets = { }

for i, v in ipairs(game:GetService("StarterGui"):GetDescendants()) do
	if v:IsA("ImageLabel") or v:IsA("ImageButton") then
		table.insert(Assets, v.Image)
	else
		table.insert(Assets, v)
	end
end

for i, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
	table.insert(Assets, v)
end

for i = 1, #Assets do
	local Asset = Assets[i]
	ContentProvider:PreloadAsync({Asset})
end

repeat wait() until ContentProvider.RequestQueueSize <= 0

UI.Enabled = false

Player.PlayerGui:WaitForChild("IdleUI").Enabled = true

Player.PlayerGui.IdleUI:WaitForChild("BattleFrame"):WaitForChild("TextButton").MouseButton1Click:Connect(function()
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = CFrame.new(Vector3.new(0,50,0), Vector3.new(0,100,0))
	
	Player.PlayerGui:WaitForChild("BattleUI").Enabled = true
	Player.PlayerGui:WaitForChild("IdleUI").Enabled = false
end)

game:GetService("ReplicatedStorage").Remotes.Battle.NPCBattle.OnClientEvent:Connect(function(Roster)
	if not Roster then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.new(Vector3.new(0,50,0), Vector3.new(0,100,0))
		
		Player.PlayerGui:WaitForChild("BattleUI").Enabled = true
		Player.PlayerGui:WaitForChild("IdleUI").Enabled = false
	end
end)