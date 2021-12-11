local Players = game:GetService("Players")
local Datastore = game:GetService("DataStoreService"):GetDataStore("PlayerData_1")
local RS = game:GetService("ReplicatedStorage")

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

Players.PlayerRemoving:Connect(function(plr)
	local Pets = plr.Pets
	local Data = plr.Data
	
	local PetData = {}
	local PlayerData = {}
	
	for _,PetObject in pairs(Pets:GetChildren()) do
		PetData[#PetData + 1] = {
			Name = PetObject.Name,
			TotalXP = PetObject.TotalXP.Value,
			Equipped = PetObject.Equipped.Value,
			PetID = PetObject.PetID.Value,
			Multiplier1 = PetObject.Multiplier1.Value,
			Multiplier2 = PetObject.Multiplier2.Value,
			Type = PetObject.Type.Value
		}
	end
	for _,DataValue in pairs(Data:GetChildren()) do
		PlayerData[#PlayerData + 1] = {
			Name = DataValue.Name,
			ClassName = DataValue.ClassName,
			Value = DataValue.Value
		}
	end
	
	Datastore:SetAsync(plr.UserId, {["PetData"] = PetData, ["PlayerData"] = PlayerData})
end)

Players.PlayerAdded:Connect(function(plr)
	local Pets = Instance.new("Folder")
	local Data = Instance.new("Folder")
	
	local SavedData = Datastore:GetAsync(plr.UserId)
	
	Pets.Name = "Pets"
	Data.Name = "Data"
	
	if SavedData ~= nil then
		local PetData = SavedData.PetData
		local PlayerData = SavedData.PlayerData
		for i,v in pairs(PetData) do
			local PetObject = RS.Pets.PetFolderTemplate:Clone()
			local Settings = RS.Pets.Models:FindFirstChild(v.Name).Settings
			local TypeNumber = RS.Pets.CraftingTiers:FindFirstChild(v.Type).Value
			local Level = getLevel(v.TotalXP)
			PetObject.Name = v.Name
			PetObject.Equipped.Value = v.Equipped
			PetObject.TotalXP.Value = v.TotalXP
			PetObject.Multiplier1.Value = Settings.Multiplier1.Value * (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber) + (Settings.LevelIncrement.Value * Level)
			PetObject.Multiplier2.Value = Settings.Multiplier2.Value * (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber) + (Settings.LevelIncrement.Value * Level)
			PetObject.PetID.Value = v.PetID
			PetObject.Type.Value = v.Type
			PetObject.Parent = Pets
		end
		for i,v in pairs(script.Data:GetChildren()) do
			local DataValue = v:Clone()
			local DataTable = nil
			DataValue.Parent = Data
			for i,v in pairs(PlayerData) do
				if v.Name == DataValue.Name then
					DataTable = v
				end
			end
			if DataTable ~= nil then
				if DataValue.Name == "MaxStorage" or v.Name == "MaxEquipped" then
					DataValue.Value = RS.Pets.Settings:FindFirstChild("Default".. DataValue.Name).Value
				else
					DataValue.Value = DataTable.Value
				end
			else
				if DataValue.Name == "MaxStorage" or v.Name == "MaxEquipped" then
					DataValue.Value = RS.Pets.Settings:FindFirstChild("Default".. DataValue.Name).Value
				end
			end
		end
	else
		for i,v in pairs(script.Data:GetChildren()) do
			local DataValue = v:Clone()
			DataValue.Parent = Data
			if DataValue.Name == "MaxStorage" or v.Name == "MaxEquipped" then
				DataValue.Value = RS.Pets.Settings:FindFirstChild("Default".. DataValue.Name).Value
			end
		end
	end
	
	Pets.Parent = plr
	Data.Parent = plr
end)
