local PlayerStatsDS = game:GetService("DataStoreService"):GetDataStore("LeaderData_1")

game.Players.PlayerAdded:Connect(function(NP)
	
	local Key = "PDS-".. NP.UserId
	
	local GetSave = PlayerStatsDS:GetAsync(Key)
	
	local PSF = Instance.new("Folder", NP)
	PSF.Name = "leaderstats"
	
	local StatsFolder = script.Stats
	
	for _, S in pairs(StatsFolder:GetChildren()) do
		local NS = Instance.new(S.ClassName, PSF)
		NS.Name = S.Name
		NS.Value = S.Value
	end
	
	if GetSave then
		for n, Stat in pairs(PSF:GetChildren()) do
			Stat.Value = GetSave[n]
		end
	else
		local STS = {}
		for _, Stat in pairs(StatsFolder:GetChildren()) do
			table.insert(STS, Stat.Value)
		end
		PlayerStatsDS:SetAsync(Key, STS)
	end
end)

game.Players.PlayerRemoving:connect(function(OP)
	
	local Key = "PDS-".. OP.UserId
	
	local StatsFolder = OP.leaderstats
	
	local STS = {}
	for _, Stat in pairs(StatsFolder:GetChildren()) do
		table.insert(STS, Stat.Value)
	end
	PlayerStatsDS:SetAsync(Key, STS)
end)
