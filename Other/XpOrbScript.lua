local DB = false
local XPgain = 25
local Delay = 5

script.Parent.Touched:Connect(function(hit)
	local Hum = hit.Parent:FindFirstChild("Humanoid")
	if Hum then
		if not DB then
			local Player = game.Players:GetPlayerFromCharacter(hit.Parent)
			for i,v in pairs(Player.Pets:GetChildren()) do
				if v.Equipped.Value == true then
					v.TotalXP.Value = v.TotalXP.Value + XPgain
				end
			end
			for i,v in pairs(workspace.PlayerPets:FindFirstChild(Player.Name):GetChildren()) do
				spawn(function()
					local Clone = game.ReplicatedStorage.Pets.AddXPdisplay:Clone()
					Clone.Parent = v.PrimaryPart
					for i = 1,25 do
						Clone.StudsOffset = Clone.StudsOffset + Vector3.new(0, .04, 0)
						Clone.TextLabel.TextTransparency = Clone.TextLabel.TextTransparency + .04
						wait(.02)
					end
					Clone:Destroy()
				end)
			end
			DB = true
			script.Parent.Transparency = 1
			wait(Delay)
			DB = false
			script.Parent.Transparency = 0
		end
	end
end)
