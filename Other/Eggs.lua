local Eggs = {
	Basic = {
		Cost = 250,
		Currency = "Coins",
		ProductID = nil,
		Pets = {
			[1] = {Name = "Donut", Type = "Normal", Rarity = 80, Secret = false},
			[2] = {Name = "Bat", Type = "Normal", Rarity = 60, Secret = false},
			[3] = {Name = "TV", Type = "Normal", Rarity = 40, Secret = false},
			[4] = {Name = "Lava Beast", Type = "Normal", Rarity = 20, Secret = false},
		}
	},
	Rare = {
		Cost = 1000,
		Currency = "Gems",
		ProductID = nil,
		Pets = {
			[1] = {Name = "Dominus", Type = "Normal", Rarity = 100, Secret = false},
		}
	},
	Aquatic = {
		Cost = 1,
		Currency = "R$",
		ProductID = 984930159,
		Pets = {
			[1] = {Name = "Dragon", Type = "Normal", Rarity = 100, Secret = false},
		}
	},
}

return Eggs