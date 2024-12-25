﻿// ArcherShop.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "CheckSpam.as";
#include "CTFShopCommon.as";
#include "MakeMat.as";
#include "MakeSeed.as";
#include "MakeCrate.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	Random@ rand = Random(this.getNetworkID());

	this.Tag("upkeep building");
	this.set_u8("upkeep cap increase", 2);
	this.set_u8("upkeep cost", 0);

	this.Tag("invincible");
	this.Tag("no_die");

	// this.Tag("respawn");

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("change team on fort capture");
	this.addCommandID("write");

	getMap().server_SetTile(this.getPosition(), CMap::tile_castle_back);

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	// AddIconToken("$bp_mechanist$", "Blueprints.png", Vec2f(16, 16), 2);
	// AddIconToken("$mat_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	// AddIconToken("$musicdisc$", "MusicDisc.png", Vec2f(8, 8), 0);
	// AddIconToken("$seed$", "Seed.png",Vec2f(8,8),0);
	// AddIconToken("$icon_cake$", "Cake.png", Vec2f(16, 8), 0);
	// AddIconToken("$icon_car$", "Icon_Car.png", Vec2f(16, 8), 0);

	this.getCurrentScript().tickFrequency = 30 * 3;

	addTokens(this); //colored shop icons

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(6, 6));
	this.set_string("shop description", "Merchant");

	this.Tag("can be captured by neutral");
	
	if (this.hasTag("name_changed"))
	{
		this.setInventoryName(this.get_string("text"));
		this.set_string("shop description", this.get_string("text"));
	}
	
	this.set_u8("shop icon", 25);

	// {
		// ShopItem@ s = addShopItem(this, "Sell Grain (1)", "$COIN$", "coin-40", "Sell 1 Grain for 40 coins.");
		// AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		// s.spawnNothing = true;
	// }
	{
		ShopItem@ s = addShopItem(this, "Buy Gold Ingot (1)", "$mat_goldingot_1x$", "mat_goldingot-1", "Buy 1 Gold Ingot for 100 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Gold Ingot (10)", "$mat_goldingot_10x$", "mat_goldingot-10", "Buy 10 Gold Ingots for 1000 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Stone (250)", "$mat_stone_1x$", "mat_stone-250", "Buy 250 stone for 125 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Stone (2500)", "$mat_stone_10x$", "mat_stone-2500", "Buy 2500 stone for 1250 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 1250);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Wood (250)", "$mat_wood_1x$", "mat_wood-250", "Buy 250 wood for 80 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy Wood (2500)", "$mat_wood_10x$", "mat_wood-2500", "Buy 2500 wood for 800 coins.");
		AddRequirement(s.requirements, "coin", "", "Coins", 800);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Gold Ingot (1)", "$COIN$", "coin-100", "Sell 1 Gold Ingot for 100 coins.");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Gold Ingot (10)", "$COIN$", "coin-1000", "Sell 10 Gold Ingots for 1000 coins.");
		AddRequirement(s.requirements, "blob", "mat_goldingot", "Gold Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Stone (250)", "$COIN$", "coin-100", "Sell 250 stone for 100 coins.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Stone (2500)", "$COIN$", "coin-1000", "Sell 2500 stone for 1000 coins.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 2500);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Wood (250)", "$COIN$", "coin-70", "Sell 250 wood for 70 coins.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Wood (2500)", "$COIN$", "coin-750", "Sell 2500 wood for 700 coins.");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 2500);
		s.spawnNothing = true;
	}
	/*if (isServer())
	{
		if (XORRandom(2) == 1) this.set_string("stuff", "pumpkin");
		else this.set_string("stuff", "ganja");
		this.Sync("stuff", true);
	}
	if (this.get_string("stuff") == "pumpkin")
	{
		{
			u32 cost = getRandomCost(@rand, 250, 375);
			ShopItem@ s = addShopItem(this, "Sell Pumpkin (1)", "$COIN$", "coin-" + cost, "Sell 1 pumpkin for " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "pumpkin", "Pumpkin", 1);
			s.spawnNothing = true;
		}
	}
	else if (this.get_string("stuff") == "ganja")
	{
		{
			u32 cost = getRandomCost(@rand, 250, 375);
			ShopItem@ s = addShopItem(this, "Sell ganja (10)", "$COIN$", "coin-" + cost, "Sell 10 ganja leaves for " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "mat_ganja", "Ganja", 10);
			s.spawnNothing = true;
		}
	}*/
	{
		u32 cost = getRandomCost(@rand, 150, 250);
		{
			ShopItem@ s = addShopItem(this, "Sell Scrub's Chow (1)", "$COIN$", "coin-" + cost, "Sell 1 Scrub's Chow for " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "foodcan", "Scrub's Chow", 1);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell Scrub's Chow (4)", "$COIN$", "coin-" + cost*4, "Sell 4 Scrub's Chow for " + cost*4 + " coins.");
			AddRequirement(s.requirements, "blob", "foodcan", "Scrub's Chow", 4);
			s.spawnNothing = true;
		}
	}
	u32 oilcost = getRandomCost(@rand, 400, 600);
	{
		u32 cost = oilcost;
		ShopItem@ s = addShopItem(this, "Sell Oil Drum (50 l)", "$COIN$", "coin-" + cost, "Sell 50 litres of oil for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "mat_oil", "Oil Drum (50 l)", 50);
		s.spawnNothing = true;
	}
	{
		u32 cost = oilcost*4;
		ShopItem@ s = addShopItem(this, "Sell Oil Drum (200 l)", "$COIN$", "coin-" + cost, "Sell 200 litres of oil for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "mat_oil", "Oil Drum (200 l)", 200);
		s.spawnNothing = true;
	}
	//u32 fuelcost = getRandomCost(@rand, 650, 950);
	//{
	//	u32 cost = fuelcost;
	//	ShopItem@ s = addShopItem(this, "Sell Fuel Drum (25 l)", "$COIN$", "coin-" + cost, "Sell 25 litres of fuel for " + cost + " coins.");
	//	AddRequirement(s.requirements, "blob", "mat_fuel", "fuel Drum (25 l)", 25);
	//	s.spawnNothing = true;
	//}
	//{
	//	u32 cost = fuelcost*4;
	//	ShopItem@ s = addShopItem(this, "Sell Fuel Drum (100 l)", "$COIN$", "coin-" + cost, "Sell 100 litres of fuel for " + cost + " coins.");
	//	AddRequirement(s.requirements, "blob", "mat_fuel", "fuel Drum (100 l)", 100);
	//	s.spawnNothing = true;
	//}
	u32 applecost = getRandomCost(@rand, 65, 115);
	{
		u32 cost = applecost;
		ShopItem@ s = addShopItem(this, "Sell Apple (1)", "$COIN$", "coin-" + cost, "Sell 1 apple for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "apple", "Apple", 1);
		s.spawnNothing = true;
	}
	{
		u32 cost = applecost*4;
		ShopItem@ s = addShopItem(this, "Sell Apple (4)", "$COIN$", "coin-" + cost, "Sell 4 apple for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "apple", "Apple", 4);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Grain (1)", "$COIN$", "coin-75", "Sell 1 grain for 75 coins.");
		AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Grain (5)", "$COIN$", "coin-375", "Sell 5 grain for 375 coins.");
		AddRequirement(s.requirements, "blob", "grain", "Grain", 5);
		s.spawnNothing = true;
	}
	u32 pumpkincost = getRandomCost(@rand, 300, 425);
	{
		u32 cost = pumpkincost;
		ShopItem@ s = addShopItem(this, "Sell Pumpkin (1)", "$COIN$", "coin-" + cost, "Sell 1 pumpkin for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "pumpkin", "Pumpkin", 1);
		s.spawnNothing = true;
	}
	{
		u32 cost = pumpkincost*4;
		ShopItem@ s = addShopItem(this, "Sell Pumpkin (4)", "$COIN$", "coin-" + cost, "Sell 4 pumpkin for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "pumpkin", "Pumpkin", 4);
		s.spawnNothing = true;
	}
	u32 ganjacost = getRandomCost(@rand, 300, 425);
	{
		u32 cost = ganjacost;
		ShopItem@ s = addShopItem(this, "Sell ganja (15)", "$COIN$", "coin-" + cost, "Sell 15 ganja leaves for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "mat_ganja", "Ganja", 15);
		s.spawnNothing = true;
	}
	{
		u32 cost = ganjacost*5;
		ShopItem@ s = addShopItem(this, "Sell ganja (75)", "$COIN$", "coin-" + cost, "Sell 75 ganja leaves for " + cost + " coins.");
		AddRequirement(s.requirements, "blob", "mat_ganja", "Ganja", 75);
		s.spawnNothing = true;
	}
	{
		u32 cost = getRandomCost(@rand, 200, 325);
		{
			ShopItem@ s = addShopItem(this, "Sell vodka (1)", "$COIN$", "coin-" + cost, "Sell 1 homemade vodka for " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "vodka", "Vodka.", 1);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell vodka (4)", "$COIN$", "coin-" + (cost*4), "Sell 4 homemade vodkas for " + (cost*4) + " coins.");
			AddRequirement(s.requirements, "blob", "vodka", "Vodka.", 4);
			s.spawnNothing = true;
		}
	}
	{
		u32 cost = getRandomCost(@rand, 500, 700);
		{
			ShopItem@ s = addShopItem(this, "Sell cider (1)", "$COIN$", "coin-" + cost, "Sell 1 pumpkin cider for " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "cider", "Pumpkin Cider.", 1);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell cider (4)", "$COIN$", "coin-" + (cost*4), "Sell 4 pumpkin ciders for " + (cost*4) + " coins.");
			AddRequirement(s.requirements, "blob", "cider", "Pumpkin Cider.", 4);
			s.spawnNothing = true;
		}
	}
	{
		u32 cost = getRandomCost(@rand, 200, 300);
		{
			ShopItem@ s = addShopItem(this, "Sell egg (1)", "$COIN$", "coin-" + cost, "Sell 1 egg for " + cost + " coins.");
			AddRequirement(s.requirements, "blob", "egg", "Egg.", 1);
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Sell egg (4)", "$COIN$", "coin-" + (cost*4), "Sell 4 eggs for " + (cost*4) + " coins.");
			AddRequirement(s.requirements, "blob", "egg", "Egg.", 4);
			s.spawnNothing = true;
		}
	}
	{
		ShopItem@ s = addShopItem(this, "Building for Dummies", "$artisancertificate$", "artisancertificate", "Simplified Builder manuscript for those dumb peasants.", true);
		AddRequirement(s.requirements, "coin", "", "Coins", getRandomCost(@rand, 200, 400));
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Kitten", "$icon_kitten$", "kitten", "A cute little kitten! Take care of it!", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", getRandomCost(@rand, 225, 325));
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Tree Seed", "$seed$", "seed", "A tree seed. Trees don't have seeds, though.");
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Cinnamon Bun", "$icon_cake$", "cake", "Pastry made with love.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mototorized Horse", "$icon_car$", "car", "Makes you extremely cool.", false, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);
		s.crate_icon = 0;

		s.spawnNothing = true;
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;
	}
	{
		ShopItem@ s = addShopItem(this, "Gramophone Record", "$musicdisc$", "musicdisc", "A random gramophone record.");
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		s.spawnNothing = true;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Sell Mystery Meat (50)", "$COIN$", "coin-50", "Sell 50 Mystery Meat for 50 coins.");
		// AddRequirement(s.requirements, "blob", "mat_meat", "Mystery Meat", 50);
		// s.spawnNothing = true;
	// }
	// {
		// ShopItem@ s = addShopItem(this, "Sell Grain (1)", "$COIN$", "coin-30", "Sell 1 Grain for 30 coins.");
		// AddRequirement(s.requirements, "blob", "grain", "Grain", 1);
		// s.spawnNothing = true;
	// }


	CSprite@ sprite = this.getSprite();

	if (sprite !is null)
	{
		// string sex = traderRandom.NextRanged(2) == 0 ? "TraderMale.png" : "TraderFemale.png";
		string sex = "TraderFemale.png";
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", sex, 16, 16, 0, 0);
		trader.SetRelativeZ(20);
		Animation@ stop = trader.addAnimation("stop", 1, false);
		stop.AddFrame(0);
		Animation@ walk = trader.addAnimation("walk", 1, false);
		walk.AddFrame(0); walk.AddFrame(1); walk.AddFrame(2); walk.AddFrame(3);
		walk.time = 10;
		walk.loop = true;
		trader.SetOffset(Vec2f(0, 8));
		trader.SetFrame(0);
		trader.SetAnimation(stop);
		trader.SetIgnoreParentFacing(true);
		this.set_bool("trader moving", false);
		this.set_bool("moving left", false);
		this.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
		this.set_u32("next offset", traderRandom.NextRanged(16));

	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	// reset shop colors
	addTokens(this);
}

void addTokens(CBlob@ this)
{
	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;

	AddIconToken("$icon_car$", "Icon_Car.png", Vec2f(16, 8), 0, teamnum);
}

int getRandomCost(Random@ random, int min, int max, int rounding = 10)
{
	return Maths::Round(f32(min + random.NextRanged(max - min)) / rounding) * rounding;
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		const u8 myTeam = this.getTeamNum();
		if (myTeam >= 100) return;

		int count = getPlayerCount();
		for (uint i = 0; i < count; i++)
		{
			CPlayer@ ply = getPlayer(i);
			if (ply.getTeamNum() == myTeam)
			{
				if (ply !is null) ply.server_setCoins(ply.getCoins() + 1);
			}
		}

		// const u8 myTeam = this.getTeamNum();
		// if (myTeam >= 100) return;

		// CBlob@[] players;
		// getBlobsByTag("player", @players);
		
		// for (uint i = 0; i < players.length; i++)
		// {
			// if (players[i].getTeamNum() == myTeam)
			// {
				// CPlayer@ ply = players[i].getPlayer();

				// if (ply !is null) ply.server_setCoins(ply.getCoins() + 1);
			// }
		// }
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("shop made item"))
	{
		this.getSprite().PlaySound("/ChaChing.ogg");

		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);

		if (callerBlob is null) return;

		if (isServer())
		{
			string[] spl = name.split("-");

			if (spl[0] == "coin")
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
			}
			else if (spl[0] == "seed")
			{
				CBlob@ blob = server_MakeSeed(this.getPosition(),XORRandom(2)==1 ? "tree_pine" : "tree_bushy");

				if (blob is null) return;

				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
			else if (spl[0] == "kitten")
			{
				u8 rand = XORRandom(3);
				CBlob@ blob = server_CreateBlob(rand == 0 ? "kitten" : rand == 1 ? "kittenwhite" : "kittenblack", callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				callerBlob.server_Pickup(blob);
			}
			else if (name.findFirst("mat_") != -1 && spl.length > 1)
			{
				CPlayer@ callerPlayer = callerBlob.getPlayer();
				if (callerPlayer is null) return;

				CBlob@ mat = server_CreateBlob(spl[0]);

				if (mat !is null)
				{
					mat.Tag("do not set materials");
					mat.server_SetQuantity(parseInt(spl[1]));
					if (!callerBlob.server_PutInInventory(mat))
					{
						mat.setPosition(callerBlob.getPosition());
					}
				}
			}
			else if(spl[0] == "seed")
			{
				CBlob@ blob = server_MakeSeed(this.getPosition(),XORRandom(2)==1 ? "tree_pine" : "tree_bushy");

				if (blob is null) return;

				if (!blob.canBePutInInventory(callerBlob))
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
			else if(spl[0] == "car")
			{
				CBlob@ crate = server_MakeCrate("car", "Car", 0, callerBlob.getTeamNum(), this.getPosition(), false);
				crate.Init();
				callerBlob.server_Pickup(crate);
			}
			else
			{
				CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

				if (blob is null) return;

				if (!blob.canBePutInInventory(callerBlob) || blob.getName() == "kitten")
				{
					callerBlob.server_Pickup(blob);
				}
				else if (callerBlob.getInventory() !is null && !callerBlob.getInventory().isFull())
				{
					callerBlob.server_PutInInventory(blob);
				}
			}
		}
	}
	if (cmd == this.getCommandID("write"))
	{
		if (isServer())
		{
			CBlob @caller = getBlobByNetworkID(params.read_u16());
			CBlob @carried = getBlobByNetworkID(params.read_u16());

			if (caller !is null && carried !is null)
			{
				this.set_string("text", carried.get_string("text"));
				this.Sync("text", true);
				this.set_string("shop description", this.get_string("text"));
				this.Sync("shop description", true);
				carried.server_Die();
				this.Tag("name_changed");
			}
		}
		if (isClient())
		{
			this.setInventoryName(this.get_string("text"));
		}
	}
}

void onTick(CSprite@ this)
{
	//TODO: empty? show it.
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ trader = this.getSpriteLayer("trader");
	bool trader_moving = blob.get_bool("trader moving");
	bool moving_left = blob.get_bool("moving left");
	u32 move_timer = blob.get_u32("move timer");
	u32 next_offset = blob.get_u32("next offset");
	if (!trader_moving)
	{
		if (move_timer <= getGameTime())
		{
			blob.set_bool("trader moving", true);
			trader.SetAnimation("walk");
			trader.SetFacingLeft(!moving_left);
			Vec2f offset = trader.getOffset();
			offset.x *= -1.0f;
			trader.SetOffset(offset);
		}
	}
	else
	{
		//had to do some weird shit here because offset is based on facing
		Vec2f offset = trader.getOffset();
		if (moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", false);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
		else if (!moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (!moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", true);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	//this.set_Vec2f("shop offset", Vec2f(2,0));
	this.set_bool("shop available", this.isOverlapping(caller));

	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;

	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "paper" && caller.getTeamNum() == this.getTeamNum())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -8), this, this.getCommandID("write"), "Rename the shop.", params);
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		Animation@ destruction = sprite.getAnimation("destruction");
		if (destruction !is null)
		{
			f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			sprite.animation.frame = frame;
		}
	}
}
