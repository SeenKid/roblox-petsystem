local TS = game:GetService("TweenService")
local MS = game:GetService("MarketplaceService")
local RS = game.ReplicatedStorage
local Library = RS.Pets
local Eggs = require(Library:WaitForChild("Eggs"))
local RemoteEvents = RS.RemoteEvents
local EggModels = workspace.Eggs

local PlayerDebounce = {}

function ChoosePet(Egg)
	local Data = Eggs[Egg]
	local Pets = Data["Pets"]
	local TotalWeight = 0
	for i,v in pairs(Pets) do
		TotalWeight = TotalWeight + v.Rarity
	end
	local Chance = math.random(1,TotalWeight)
	local Counter = 0
	for i,v in pairs(Pets) do
		Counter = Counter+v.Rarity
		if Counter >= Chance then
			return v.Name
		end
	end
end

function totalPets(Player)
	local Pets = 0
	for i,v in pairs(Player.Pets:GetChildren()) do
		Pets = Pets + 1
	end
	return Pets
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

function singleEgg(Player, Egg)
	local Data = Eggs[Egg]
	local Cost = Data["Cost"]
	local Currency = Data["Currency"]
	local Pets = Data["Pets"]
	local PetChosen = ChoosePet(Egg)
	local Settings = RS.Pets.Models:FindFirstChild(PetChosen).Settings
	if Currency ~= "R$" then
		Player.leaderstats:FindFirstChild(Currency).Value = Player.leaderstats:FindFirstChild(Currency).Value - Cost
	end
	for i,v in pairs(PlayerDebounce) do
		if v[1] == Player.Name then
			v[2] = true
		end
	end
	spawn(function()
		wait(3.2)
		for i,v in pairs(PlayerDebounce) do
			if v[1] == Player.Name then
				v[2] = false
			end
		end
	end)
	for i,v in pairs(Pets) do
		if v.Name == PetChosen then
			local Clone = RS.Pets.PetFolderTemplate:Clone()
			Clone.PetID.Value = RandomID(Player)
			Clone.Multiplier1.Value = Settings.Multiplier1.Value
			Clone.Multiplier2.Value = Settings.Multiplier2.Value
			Clone.Type.Value = v.Type
			Clone.Parent = Player.Pets
			Clone.Name = PetChosen
		end
	end
	return PetChosen
end

function tripleEgg(Player, Egg)
	local Data = Eggs[Egg]
	local Cost = Data["Cost"]
	local Currency = Data["Currency"]
	local Pets = Data["Pets"]
	local PetsChosen = {}
	Player.leaderstats:FindFirstChild(Currency).Value = Player.leaderstats:FindFirstChild(Currency).Value - Cost * 3
	for i,v in pairs(PlayerDebounce) do
		if v[1] == Player.Name then
			v[2] = true
		end
	end
	spawn(function()
		wait(3.2)
		for i,v in pairs(PlayerDebounce) do
			if v[1] == Player.Name then
				v[2] = false
			end
		end
	end)
	for i = 1,3 do
		local PetChosen = ChoosePet(Egg)
		local Settings = RS.Pets.Models:FindFirstChild(PetChosen).Settings
		for i,v in pairs(Pets) do
			if v.Name == PetChosen then
				local Clone = RS.Pets.PetFolderTemplate:Clone()
				Clone.PetID.Value = RandomID(Player)
				Clone.Multiplier1.Value = Settings.Multiplier1.Value
				Clone.Multiplier2.Value = Settings.Multiplier2.Value
				Clone.Type.Value = v.Type
				Clone.Parent = Player.Pets
				Clone.Name = PetChosen
				PetsChosen[#PetsChosen + 1] = PetChosen
			end
		end
	end
	return PetsChosen
end

function UnboxEgg(Player, Egg, Type)
	if Eggs[Egg] ~= nil then
		local Data = Eggs[Egg]
		local Cost = Data["Cost"]
		local Currency = Data["Currency"]
		local Pets = Data["Pets"]
		local Model = EggModels:FindFirstChild(Egg)
		local Debounce = false
		for i,v in pairs(PlayerDebounce) do
			if v[1] == Player.Name then
				Debounce = v[2]
			end
		end
		if (Player.Character.HumanoidRootPart.Position - Model.UIanchor.Position).Magnitude <= 10 then
			if not Debounce then
				if Currency ~= "R$" then
					if Type == "Single" then
						if Player.leaderstats:FindFirstChild(Currency).Value >= Cost then
							if totalPets(Player) < Player.Data.MaxStorage.Value then
								local PetChosen = singleEgg(Player, Egg)
								return PetChosen
							else
								return "Error", "Not Enough Inventory Room"
							end
						else
							return "Error", "Insufficient Currency"
						end
					elseif Type == "Triple" then
						if Player.leaderstats:FindFirstChild(Currency).Value >= Cost * 3 then
							if totalPets(Player) < Player.Data.MaxStorage.Value - 2 then
								if Player.Data.TripleEggOwned.Value == true then
									local PetsChosen = tripleEgg(Player, Egg)
									return PetsChosen
								else
									return "Error", "Player Doesn't Own Gamepass"
								end
							else
								return "Error", "Not Enough Inventory Room"
							end
						else
							return "Error", "Insufficient Currency"
						end
					elseif Type == "Auto" then	
						if Player.Data.AutoEggOwned.Value == true then
							if Player.Data.TripleEggOwned.Value == true then
								if Player.leaderstats:FindFirstChild(Currency).Value >= Cost * 3 then
									if totalPets(Player) < Player.Data.MaxStorage.Value - 2 then
										if Player.Data.TripleEggOwned.Value == true then
											local PetsChosen = tripleEgg(Player, Egg)
											return PetsChosen
										else
											return "Error", "Player Doesn't Own Gamepass"
										end
									else
										return "Error", "Not Enough Inventory Room"
									end
								else
									return "Error", "Insufficient Currency"
								end
							else
								if Player.leaderstats:FindFirstChild(Currency).Value >= Cost then
									if totalPets(Player) < Player.Data.MaxStorage.Value then
										local PetChosen = singleEgg(Player, Egg)
										return PetChosen
									else
										return "Error", "Not Enough Inventory Room"
									end
								else
									return "Error", "Insufficient Currency"
								end
							end
						else
							return "Error", "Player Doesn't Own Gamepass"
						end
					end
				else
					if totalPets(Player) < Player.Data.MaxStorage.Value then
						return "Error", "Robux Purchase"
					else
						return "Error", "Not Enough Inventory Room"
					end
				end
			end
		else
			return "Error", "Too far away"
		end
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	PlayerDebounce[#PlayerDebounce + 1] = {plr.Name, false}
end)

game.Players.PlayerRemoving:Connect(function(plr)
	for i,v in pairs(PlayerDebounce) do
		if v[1] == plr.Name then
			v = nil
		end
	end
end)

for i,v in pairs(Eggs) do
	local ProductID = v["ProductID"]
	if ProductID ~= nil then
		MS.ProcessReceipt = function(ReceiptInfo)
			local Player = game:GetService("Players"):GetPlayerByUserId(ReceiptInfo.PlayerId)
			if ReceiptInfo.ProductId == ProductID then
				spawn(function()
					local Result = singleEgg(Player, i)
					RS.RemoteEvents.EggOpened:InvokeClient(Player, Eggs[i], Result)
				end)
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end
end

RS.RemoteEvents.EggOpened.OnServerInvoke = UnboxEgg
