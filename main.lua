local items = {
	Common = {
		{ name = "Potion of Healing", healing = 10 },
		{ name = "Rope" },
		{ name = "Rations" },
		{ name = "Lantern" },
	},

	Uncommon = {
		{ name = "Cloak of Protection" },
		{ name = "Winged Boots" },
		{ name = "Bracers of Archery" },
	},

	Rare = {
		{ name = "+1 Weapon",                      weapondamage = 5 },
		{ name = "Boots of Striding and Springing" },
		{ name = "Wand of Magic Missiles" },
	},

	Legendary = {
		{ name = "Cloak of Invisibility" },
		{ name = "Ring of Three Wishes" },
		{ name = "Deck of Many Things" },
		{ name = "Staff of the Magi" },
	}
}

local grounditems = {
	{ name = "Gold Coins",         probability = 0.3 },
	{ name = "Scroll of Identify", probability = 0.2 },
	{ name = "Gemstone",           probability = 0.6 },
	{ name = "Empty Bottle",       probability = 0.5 },
}

local merchantShop = {
	{ name = "Potion of Healing",   price = 10 },
	{ name = "Cloak of Protection", price = 30 },
}

local startingGold = 100

function displayMerchantShop()
	print("\nMerchant Shop:")
	for i, item in ipairs(merchantShop) do
		print(i .. ". " .. item.name .. " - " .. item.price .. " Gold.")
	end
end

function buyItem(player, index)
	local item = merchantShop[index]
	if item and player.gold >= item.price then
		table.insert(player.inventory, item)
		player.gold = player.gold - item.price
		print("You bought a " .. item.name .. " for " .. item.price .. " Gold.")
	else
		print("You don't have enough gold to buy that item.")
	end
end

function sellItem(player, index)
	if index >= 1 and index <= #player.inventory then
		local item = player.inventory[index]
		player.gold = player.gold + math.floor(item.price * 0.5)
		print("You sold a " .. item.name .. " for " .. math.floor(item.price * 0.5) .. " Gold.")
		table.remove(player.inventory, index)
		displayPlayerStats(player)
	else
		print("Invalid inventory index")
	end
end

local monsters = {
	{ name = "Goblin",  health = 10,  attack = 2 },
	{ name = "Orc",     health = 20,  attack = 4 },
	{ name = "Cyclops", health = 50,  attack = 20 },
	{ name = "Dragon",  health = 100, attack = 50 },
}

function findGroundItem()
	local roll = math.random()
	for _, item in ipairs(grounditems) do
		if roll <= item.probability then
			return item.name
		else
			roll = roll - item.probability
		end
	end
	return nil
end

function rollDice()
	math.randomseed(os.time())
	return math.random(1, 6)
end

function getItem(roll)
	if roll == 1 or roll == 2 then
		return items.Common[math.random(#items.Common)]
	elseif roll == 3 or roll == 4 then
		return items.Uncommon[math.random(#items.Uncommon)]
	elseif roll == 5 then
		return items.Rare[math.random(#items.Rare)]
	elseif roll == 6 then
		return items.Legendary[math.random(#items.Legendary)]
	end
end

function displayInventory(inventory)
	print("\nCurrent Inventory:")
	if #inventory == 0 then
		print("Your inventory is empty")
	else
		for i, item in ipairs(inventory) do
			print(i .. ". " .. item.name)
		end
	end
	print()
end

function displayPlayerStats(player)
	print("\nPlayer Stats:")
	print("Health: " .. player.health)
	print("Attack: " .. player.attack)
	print("Defense: " .. player.defense)
	print()
end

function combat(player, monster)
	print("\nYou encountered a " .. monster.name .. "!")
	while player.health > 0 and monster.health > 0 do
		print("Your health: " .. player.health .. " | " .. monster.name .. " Health: " .. monster.health)
		io.write("Type 'Attack' to attack the monster: ")
		local action = io.read()

		if action == "Attack" then
			monster.health = monster.health - player.attack
			print("You attacked the " .. monster.name .. " for " .. player.attack .. " damage.")
		elseif action == "Defend" then
			local damagetaken = monster.attack - player.defense
			if damagetaken > 0 then
				player.health = player.health - damagetaken
				print("You defended against the " .. monster.name .. " and took " .. damagetaken .. " damage.")
			else
				print("You defended against the " .. monster.name .. " and took no damage.")
			end

			if monster.health > 0 then
				player.health = player.health - monster.attack
				print("The " .. monster.name .. " attacked you for " .. monster.attack .. " damage.")
			end
		else
			print("Invalid action. Type 'Attack' to fight the monster.")
		end
	end

	if player.health <= 0 then
		print("You have been defeated by the " .. monster.name .. ". Game Over")
		return false
	else
		print("You defeated the " .. monster.name .. "!")
		return true
	end
end

function applyItemEffects(player, item)
	if item.healing then
		player.health = player.health + item.healing
		if player.health == 100 then
			print("You have max health.")
		end
	end
	if item.weapondamage then
		player.attack = player.attack + item.weapondamage
		print("Your attack increased by " .. item.weapondamage .. ".")
	end
	if item.adddefense then
		player.defense = player.defense + item.adddefense
		print("Your defense increased by " .. item.adddefense .. ".")
	end
end

function playGame()
	local inventory = {}
	local player = { health = 30, attack = 5, defense = 10, gold = startingGold, }

	print("Welcome to ItemRNG!")
	print("Press Enter to roll the dice to collect items.")
	print("You can check your inventory at any time by typing 'Inventory'.")
	print("Type 'Quit' to stop playing.")

	while true do
		io.write("Enter an operation: ")
		local input = io.read()

		if input == "Quit" then
			break
		elseif input == "Inventory" then
			displayInventory(inventory)
		elseif input == "Stat" then
			displayPlayerStats(player)
		elseif input == "Merchant" then
			displayMerchantShop()
			io.write("Enter the number of the item you want to buy or sell:")
			local merchantAction = io.read()
			if tonumber(merchantAction) then
				local index = tonumber(merchantAction)
				if index >= 1 and index <= #merchantShop then
					buyItem(player, index)
				else
					print("Invalid item number")
				end
			elseif merchantAction == "Sell" then
				displayInventory(player.inventory)
				io.write("Enter the number of the item you want to sell: ")
				local sellIndex = tonumber(io.read())
				sellItem(player, sellIndex)
			else
				print("Invalid action at merchant")
			end
		else
			local roll = rollDice()
			local item = getItem(roll)
			table.insert(inventory, item)

			print("You rolled a " .. roll .. " and received " .. item.name .. "!")
			applyItemEffects(player, item)

			if math.random() < 0.3 then -- 30% chance for combat
				local monster = monsters[math.random(#monsters)]
				if not combat(player, monster) then
					break
				end
			end
		end
	end

	local foundItem = findGroundItem()
	if foundItem then
		table.insert(inventory, foundItem)
		print("You found a " .. foundItem .. " on the ground!")
		displayInventory(inventory)
	end

	if player.health > 0 then
		print("\nGame Over! Here are the items you collected:")
		displayInventory(inventory)
	end
end

playGame()
