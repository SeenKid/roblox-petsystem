local Disabled = false
local Player = game.Players:FindFirstChild(script.Parent.Parent.Name)

if Player then
	while wait() do
		if Player.Character.Health ~= 0 then
			if not Disabled then
				local Pos = script.Parent.Pos.Value
				local BG = script.Parent.PrimaryPart.BodyGyro
				local BP = script.Parent.PrimaryPart.BodyPosition
				local d = Player.Character.HumanoidRootPart.Position.Y - script.Parent.PrimaryPart.Position.Y
				BP.Position = (Player.Character.HumanoidRootPart.Position + Pos) - Vector3.new(0,Player.Character.HumanoidRootPart.Size.Y/2,0) + Vector3.new(0,script.Parent.PrimaryPart.Size.Y/2,0) + Vector3.new(0,game.ServerScriptService.globalPetFloat.Value,0)
				if Player.Data.isWalking.Value == false then
					BG.CFrame = CFrame.new(script.Parent.PrimaryPart.Position, Player.Character.HumanoidRootPart.Position - Vector3.new(0, d, 0))
				else
					BG.CFrame = Player.Character.HumanoidRootPart.CFrame
				end
			else
				script.Parent:Destroy()
				break
			end
		else
			Disabled = false
		end
	end
end
