local RS = game.ReplicatedStorage
local Player = game.Players:FindFirstChild(script.Parent.Parent.Name)

function GetFolderFromPetID(PetID)
	for i,v in pairs(Player.Pets:GetChildren()) do
		if v.PetID.Value == PetID then
			return v
		end
	end
	return nil
end

function getLevel(totalXP)
	local Increment = 0
	local RequiredXP = 100
	for i = 0, RS.Pets.Settings.MaxPetLevel.Value do
		RequiredXP = 100 + (25*i)
		if totalXP >= (100*i) + Increment then
			if i ~= RS.Pets.Settings.MaxPetLevel.Value then
				if totalXP < ((100*i) + Increment) + RequiredXP then
					return i
				end
			else
				return i
			end
		end
		Increment = Increment+(i*25)
	end
end

if Player then
	local Folder = GetFolderFromPetID(script.Parent.PetID.Value)
	local ModelFolder = RS.Pets.Models:FindFirstChild(Folder.Name)
	local Type = Folder.Type.Value
	local TypeNumber = RS.Pets.CraftingTiers:FindFirstChild(Type).Value
	local Level = getLevel(Folder.TotalXP.Value)
	Folder.Multiplier1.Value = (ModelFolder.Settings.Multiplier1.Value * (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber)) + (ModelFolder.Settings.LevelIncrement.Value * Level)
	Folder.Multiplier2.Value = (ModelFolder.Settings.Multiplier2.Value * (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber)) + (ModelFolder.Settings.LevelIncrement.Value * Level)
	Folder.TotalXP:GetPropertyChangedSignal("Value"):Connect(function()
		local Level = getLevel(Folder.TotalXP.Value)
		Folder.Multiplier1.Value = (ModelFolder.Settings.Multiplier1.Value * (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber)) + (ModelFolder.Settings.LevelIncrement.Value * Level)
		Folder.Multiplier2.Value = (ModelFolder.Settings.Multiplier2.Value * (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber)) + (ModelFolder.Settings.LevelIncrement.Value * Level)
	end)
end
