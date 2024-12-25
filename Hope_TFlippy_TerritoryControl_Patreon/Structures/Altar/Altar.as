﻿#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "DeityCommon.as";
#include "CustomBlocks.as";
#include "MinableMatsCommon.as";

// A script by TFlippy

void onInit(CBlob@ this)
{
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_TileType("background tile", CMap::tile_castle_back);
	if (this.getName() == "altar_tflippy") this.set_TileType("background tile", CMap::tile_bconcrete);
	this.Tag("builder always hit");
	
	if (!this.exists("deity_id")) this.set_u8("deity_id", Deity::none);

	HarvestBlobMat[] mats = {};
	mats.push_back(HarvestBlobMat(500.0f, "mat_stone"));
	this.set("minableMats", mats);	
	
	if (this.getName() == "altar")
	{
		this.set_Vec2f("shop menu size", Vec2f(10, 4));
		this.set_string("shop description", "Select a Deity");
		this.set_u8("shop icon", 15);
		this.Tag(SHOP_AUTOCLOSE);
		
		AddIconToken("$icon_mithrios$", "Altar.png", Vec2f(24, 32), 1);
		AddIconToken("$icon_ivan$", "Altar.png", Vec2f(24, 32), 2);
		AddIconToken("$icon_gregor$", "Altar.png", Vec2f(24, 32), 3);
		AddIconToken("$icon_mason$", "Altar.png", Vec2f(24, 32), 4);
		AddIconToken("$icon_cocok$", "Altar.png", Vec2f(24, 32), 5);
		AddIconToken("$icon_swaglag$", "Altar.png", Vec2f(24, 32), 6);
		AddIconToken("$icon_dragonfriend$", "Altar.png", Vec2f(24, 32), 7);
		AddIconToken("$icon_trollbird$", "Altar.png", Vec2f(24, 32), 9);
		AddIconToken("$icon_leutnant$", "Altar.png", Vec2f(24, 32), 10);
		AddIconToken("$icon_tflippy$", "Altar.png", Vec2f(24, 32), 12);
		
		{
			ShopItem@ s = addShopItem(this, "TFlippy, The Creator", "$icon_tflippy$", "altar_tflippy", "Missing good ol' days? This may help you feel nostalgic!");
			AddRequirement(s.requirements, "no more global", "altar_tflippy", "Altar of TFlippy", 1);
			AddRequirement(s.requirements, "coin", "", "Coins", 250);
			AddRequirement(s.requirements, "blob", "hobo", "Hobo", 1);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Mithrios, God of Death", "$icon_mithrios$", "altar_mithrios", "A demon known for his cruelty and hunger for blood.\n\nAfter being banished from the mortal realm, he returned as a weapon of destruction.\n\n- Damage Reflection\n- Kill a random person\n- Create a Mithrios Device\n- Gain Demonic Power by killing people");
			AddRequirement(s.requirements, "no more global", "altar_mithrios", "Altar of Mithrios", 1);
			AddRequirement(s.requirements, "blob", "slaveball", "Slave Ball", 1);
			AddRequirement(s.requirements, "blob", "mat_meat", "Meat", 250);
			AddRequirement(s.requirements, "coin", "", "Coins", 2500);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Ivan, God of Ivan", "$icon_ivan$", "altar_ivan", "A squatter worshipped by anarchists, slavs and those who indulge in drinking.\n\nAfter annoying the Illuminati Council and being banished three times, a cult worshipping him formed.\n\n- Immunity to enslavement\n- Anti-faction field around altar\n- Running speed bonus\n- Build a blessed AK-47\n- Raise a Hobo\n- Respawn graduated\n- Knowledge to use engineer tools");
			AddRequirement(s.requirements, "no more global", "altar_ivan", "Altar of Ivan", 1);
			AddRequirement(s.requirements, "blob", "vodka", "Vodka", 4);
			AddRequirement(s.requirements, "coin", "", "Coins", 1500);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Gregor Builder, God of Destruction", "$icon_gregor$", "altar_gregor", "A deranged inventor known for his bizarre contraptions - such as the deadly ebola rune.\n\nOne day after being beaten in a wizard duel, he threatened to wipe out the entire world. The Illuminati Council removed him from existence for one month instead.\n\n- No one knows how to summon him yet");
			AddRequirement(s.requirements, "no more global", "altar_gregor", "Altar of Gregor Builder", 1);
			AddRequirement(s.requirements, "blob", "builder", "Virgin Builder Corpse", 1);
			AddRequirement(s.requirements, "blob", "foof", "Foof", 1);
			AddRequirement(s.requirements, "coin", "", "Coins", 2000);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Grand Mason, God of Masonry", "$icon_mason$", "altar_mason", "A determined architect responsible for creation of many bridges, castles and palaces.\n\He's humble.\n\n- Chance to not consume materials when placing a block.");
			AddRequirement(s.requirements, "no more global", "altar_gregor", "Altar of Gregor Builder", 1);
			AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 4000);
			AddRequirement(s.requirements, "blob", "artisancertificate", "Building for Dummies", 1);
			AddRequirement(s.requirements, "coin", "", "Coins", 1000);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Cocok, God of Cocok", "$icon_cocok$", "altar_cocok", "The bestest player in this region.\n\Specializes in illegal weaponry.\n\n- Infidels feel heavier around the altar.\n- Create Molotov Cocktails\n- Construct a Molothrower\n- Build a Cocok Bomba");
			AddRequirement(s.requirements, "no more global", "altar_cocok", "Altar of Cocok", 1);
			AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril", 200);
			AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 200);
			AddRequirement(s.requirements, "blob", "mat_smallbomb", "Small Bomb", 8);
			AddRequirement(s.requirements, "blob", "vodka", "Vodka", 2);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "SwagLag, God of Swag", "$icon_swaglag$", "altar_swaglag", "The god of drugs, Mountain Dew and scopeless sniper rifles.\n\n- Increased gun damage up to +200%\n- Create Protopopov seed\n- Construct a MLG rifle\n- Buy Doritos");
			AddRequirement(s.requirements, "no more global", "altar_swaglag", "Altar of SwagLag", 1);
			AddRequirement(s.requirements, "blob", "sniper", "UPF Sniper Rifle", 2);
			AddRequirement(s.requirements, "coin", "", "Coins", 4200);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Dragonfriend, God of Greed", "$icon_dragonfriend$", "altar_dragonfriend", "The god of wealth, power and greed.\n\n- Stonks Trading\n- Fire Resistance up to 100%\n- Summon a meteor\n\nPress V to conjure a fireball");
			AddRequirement(s.requirements, "no more global", "altar_dragonfriend", "Altar of the Dragon", 1);
			AddRequirement(s.requirements, "coin", "", "Coins", 8000);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "trollbird, God of Trolling", "$icon_trollbird$", "altar_troll", "The god of trolling. I bet you its a worth investment");
			AddRequirement(s.requirements, "no more global", "altar_troll", "Altar of the trollbird", 1);
			AddRequirement(s.requirements, "coin", "", "Coins", 5000);
			AddRequirement(s.requirements, "blob", "mat_dirt", "Dirt", 5000);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
		{
			ShopItem@ s = addShopItem(this, "Leutnant, God of War Crimes", "$icon_leutnant$", "altar_leutnant", "*Essay about how Skemonde is actually a supervillain*\n\n- Construct a weapon of genocide\n- Immunity to mustardgas\n- Construct an inbalanced helmet");
			AddRequirement(s.requirements, "coin", "", "Coins", 1488);
			AddRequirement(s.requirements, "blob", "villaincap", "Cool looking military cap", 1);
			AddRequirement(s.requirements, "blob", "bandit", "Bandit's Corpse", 1);
			//AddRequirement(s.requirements, "blob", "shito", "WHY?", 1);
			s.customButton = true;
			s.buttonwidth = 2;	
			s.buttonheight = 2;
			
			s.spawnNothing = true;
		}
	}
	else
	{
		this.set_f32("deity_power", 100);
	
		this.set_Vec2f("shop menu size", Vec2f(2, 2));
		this.set_string("shop description", "Make an offering");
		this.set_u8("shop icon", 15);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (this.getName() == "altar")
	{
		if (isServer())
		{
			if (cmd == this.getCommandID("shop made item"))
			{
				u16 caller, item;
				if (!params.saferead_netid(caller) || !params.saferead_netid(item)) return;
				string data = params.read_string();
				
				Vec2f pos = this.getPosition();
				u8 team = this.getTeamNum();
			
				this.getSprite().PlaySound("/Construct.ogg");
				this.getSprite().getVars().gibbed = true;
				
				if (isServer())
				{
					CBlob@ newBlob = server_CreateBlob(data, team, pos);
					this.server_Die();
				}
			}
		}
	}
}

void onDie(CBlob@ this)
{
	if (!isServer()) return;
	u8 self_deity_id = this.get_u8("deity_id");

	int count = getPlayerCount();
	for (int i = 0; i < count; i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			if (player.get_u8("deity_id") == self_deity_id)
			{
				player.set_u8("deity_id", 0);
				
				CBlob@ blob = player.getBlob();
				if (blob !is null)
				{
					blob.set_u8("deity_id", 0);
					blob.Sync("deity_id", true);
				}
			}
		}
	}
}
