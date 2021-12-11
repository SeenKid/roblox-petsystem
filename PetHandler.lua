local RS = game.ReplicatedStorage
local MS = game:GetService("MarketplaceService")

function GetFolderFromPetID(Player, PetID)
	for i,v in pairs(Player.Pets:GetChildren()) do
		if v.PetID.Value == PetID then
			return v
		end
	end
	return nil
end

function GetPointOnCircle(CircleRadius, Degrees)
    return Vector3.new(math.cos(math.rad(Degrees)) * CircleRadius, 1, math.sin(math.rad(Degrees))* CircleRadius)
end

function GetAllOfType(Player, PetName, Type)
	local Pets = {}
	for i,v in pairs(Player.Pets:GetChildren()) do
		if v.Name == PetName then
			if v:WaitForChild("Type").Value == Type then
				Pets[#Pets + 1] = v.PetID.Value
			end
		end
	end
	if #Pets >= RS.Pets.Settings.PetsRequiredToCraft.Value then
		return Pets
	else
		return nil
	end
end

function GetNextType(TypeName)
	local CurrentValue
	for i,v in pairs(RS.Pets.CraftingTiers:GetChildren()) do
		if v.Name == TypeName then
			CurrentValue = v.Value
		end
	end
	for i,v in pairs(RS.Pets.CraftingTiers:GetChildren()) do
		if v.Value == CurrentValue + 1 then
			return v.Name, CurrentValue + 1
		end
	end
end

function RandomID(Player)
	local Rand = math.random(2,1000000)
	for i,v in pairs(Player.Pets:GetChildren()) do
		if v.PetID.Value == Rand then
			return RandomID()
		end
	end
	return Rand
end

function loadEquipped(Player)
	local CurrentlyEquipped = {}
	for _,Pet in pairs(Player:WaitForChild("Pets"):GetChildren()) do
		if Pet.Equipped.Value == true then
			CurrentlyEquipped[#CurrentlyEquipped + 1] = Pet.PetID.Value
		else
			local ExistentModel = nil
			for _,Part in pairs(workspace.PlayerPets:FindFirstChild(Player.Name):GetChildren()) do
				if Part:FindFirstChild("PetID") then
					if Part.PetID.Value == Pet.PetID.Value then
						ExistentModel = Part
					end
				end
			end
			if ExistentModel ~= nil then
				ExistentModel:Destroy()
			end
		end
	end
	local Increment = 360/#CurrentlyEquipped
	for i,v in pairs(CurrentlyEquipped) do
		local ExistentModel = nil
		local Folder = GetFolderFromPetID(Player, v)
		for _,Part in pairs(workspace.PlayerPets:FindFirstChild(Player.Name):GetChildren()) do
			if Part:FindFirstChild("PetID") then
				if Part.PetID.Value == v then
					ExistentModel = Part
				end
			end
		end
		if ExistentModel ~= nil then
			ExistentModel.Pos.Value = GetPointOnCircle(RS.Pets.Settings.PetCircleRadius.Value, Increment * i)
		else
			local PetModel = RS.Pets.Models:FindFirstChild(Folder.Name):FindFirstChild(Folder.Type.Value):Clone()
			PetModel.Pos.Value = GetPointOnCircle(RS.Pets.Settings.PetCircleRadius.Value, Increment * i)
			PetModel.PetID.Value = v
			PetModel.Parent = workspace.PlayerPets:FindFirstChild(Player.Name)
			PetModel.PrimaryPart:SetNetworkOwner(Player)
		end
	end
end

function ActionRequest(Player, Action, Parameters)
	if Action == "Equip" then
		local Folder = GetFolderFromPetID(Player, Parameters.PetID)
		if Folder ~= nil then
			if Folder.Equipped.Value == false then
				local TotalEquipped = 0
				for i,v in pairs(Player.Pets:GetChildren()) do
					if v.Equipped.Value == true then	
						TotalEquipped = TotalEquipped + 1			
					end
				end
				if TotalEquipped < Player.Data.MaxEquip.Value then
					Folder.Equipped.Value = true
					loadEquipped(Player)
					return "Success"
				else
					return "Error", "Too Many Pets Equipped"
				end
			else
				return "Error", "Pet Already Equipped"
			end
		else
			return "Error", "Invalid Pet"
		end
	elseif Action == "Unequip" then
		local Folder = GetFolderFromPetID(Player, Parameters.PetID)
		if Folder ~= nil then
			if Folder.Equipped.Value == true then
				Folder.Equipped.Value = false
				loadEquipped(Player)
				return "Success"
			else
				return "Error", "Pet Already Unequipped"
			end
		else
			return "Error", "Invalid Pet"
		end
	elseif Action == "Delete" then
		local Folder = GetFolderFromPetID(Player, Parameters.PetID)
		if Folder ~= nil then
			Folder.Equipped.Value = false
			loadEquipped(Player)
			Folder:Destroy()
			return "Success"
		else
			return "Error", "Invalid Pet"
		end
	elseif Action == "Craft" then
		local MainFolder = GetFolderFromPetID(Player, Parameters.PetID)
		local MainType = MainFolder.Type.Value
		local MainName = MainFolder.Name
		if MainFolder ~= nil then
			local Pets = GetAllOfType(Player, MainFolder.Name, MainFolder.Type.Value)
			if Pets ~= nil then
				for i = 1,RS.Pets.Settings.PetsRequiredToCraft.Value do
					local Folder = GetFolderFromPetID(Player, Pets[i])
					Folder.Equipped.Value = false
					loadEquipped(Player)
					Folder:Destroy()
				end
				local Clone = RS.Pets.PetFolderTemplate:Clone()
				local Type, TypeNumber = GetNextType(MainType)
				local Settings = RS.Pets.Models:FindFirstChild(MainName).Settings
				Clone.PetID.Value = RandomID(Player)
				Clone.Multiplier1.Value = Settings.Multiplier1.Value * (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber)
				Clone.Multiplier2.Value = Settings.Multiplier2.Value* (RS.Pets.Settings.CraftMultiplier.Value ^ TypeNumber)
				Clone.Type.Value = Type
				Clone.Parent = Player.Pets
				Clone.Name = MainName
				return Clone.PetID.Value
			else
				return "Error", "Not Enough Pets"
			end
		else
			return "Error", "Invalid Pet"
		end
	elseif Action == "Mass Delete" then
		for i,v in pairs(Parameters.Pets) do
			local Folder = GetFolderFromPetID(Player, v)
			if Folder ~= nil then
				Folder.Equipped.Value = false
				loadEquipped(Player)
				Folder:Destroy()
			end
		end
	end
end

RS.RemoteEvents.PetActionRequest.OnServerInvoke = ActionRequest
RS.RemoteEvents.plrWalk.OnServerEvent:Connect(function(Player, State)
	Player.Data:FindFirstChild("isWalking").Value = State
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAppearanceLoaded:Connect(function()
		local Folder = Instance.new("Folder", workspace.PlayerPets)
		Folder.Name = Player.Name
		loadEquipped(Player)
	end)
end)

game.Players.PlayerRemoving:Connect(function(Player)
	local Folder = workspace.PlayerPets:FindFirstChild(Player.Name)
	if Folder then
		Folder:Destroy()
	end
end)

-- Gamepasses

for i,v in pairs(RS.GamepassIDs:GetChildren()) do
	MS.PromptGamePassPurchaseFinished:Connect(function(plr,ido,purchased)
		if purchased and v.Value == ido then
			if v.Name == "TripleOpen" then
				plr.Data.TripleEggOwned.Value = true
			elseif v.Name == "AutoOpen" then
				plr.Data.AutoEggOwned.Value = true
			elseif v.Name == "ExtraEquipped" then
				plr.Data.MaxEquip.Value = RS.Pets.Settings.DefaultMaxEquipped.Value + 5
			elseif v.Name == "ExtraStorage" then
				plr.Data.MaxStorage.Value = RS.Pets.Settings.DefaultMaxStorage.Value + 30
			end
		end
	end)
	game.Players.PlayerAdded:Connect(function(plr)
		local Data = plr:WaitForChild("Data", math.huge)
		if MS:UserOwnsGamePassAsync(plr.UserId, v.Value) then
			if v.Name == "TripleOpen" then
				plr.Data.TripleEggOwned.Value = true
			elseif v.Name == "AutoOpen" then
				plr.Data.AutoEggOwned.Value = true
			elseif v.Name == "ExtraEquipped" then
				plr.Data.MaxEquip.Value = RS.Pets.Settings.DefaultMaxEquipped.Value + 5
			elseif v.Name == "ExtraStorage" then
				plr.Data.MaxStorage.Value = RS.Pets.Settings.DefaultMaxStorage.Value + 30
			end
		end
	end)
end

-- Setup

for _,Folder in pairs(RS.Pets.Models:GetChildren()) do
	for _,Model in pairs(Folder:GetChildren()) do
		if Model.Name ~= "Settings" then
			local PetID = script.PetSetup.PetID:Clone()
			local Pos = script.PetSetup.Pos:Clone()
			local BG = script.PetSetup.BodyGyro:Clone()
			local BP = script.PetSetup.BodyPosition:Clone()
			local FollowScript = script.PetSetup.Follow:Clone()
			local LevelingScript = script.PetSetup.Leveling:Clone()
			PetID.Parent = Model
			Pos.Parent = Model
			BG.Parent = Model.PrimaryPart
			BP.Parent = Model.PrimaryPart
			FollowScript.Parent = Model
			LevelingScript.Parent = Model
		end
	end
end

-- Global Pet Float

local maxFloat = .75
local floatInc = 0.035
local sw = false
local fl = 0

spawn(function() 
	while true do
	    wait()
	    if not sw then
	        fl = fl + floatInc
	        if fl >= maxFloat then
	            sw = true
	        end
	    else
	        fl = fl - floatInc
	        if fl <=-maxFloat then
	            sw = false
	        end
	    end
		script.Parent.globalPetFloat.Value = fl
	end
end)
