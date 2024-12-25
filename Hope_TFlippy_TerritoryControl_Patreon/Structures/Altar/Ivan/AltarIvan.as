﻿#include "Requirements.as";
#include "Requirements_Tech.as";
#include "ShopCommon.as";
#include "Knocked.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "DeityCommon.as";
#include "RgbStuff.as";

const SColor[] colors =
{
	SColor(255, 255, 30, 30),
	SColor(255, 30, 255, 30),
	SColor(255, 30, 30, 255)
};

const u8 rgbStep = 10;

void onInit(CBlob@ this)
{
	this.set_u8("deity_id", Deity::ivan);
	this.Tag("colourful");

	this.addCommandID("turn_sounds");
	this.addCommandID("sync_deity");

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Ivan_Music.ogg");
	sprite.SetEmitSoundVolume(0.4f);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundPaused(false);

	CSpriteLayer@ shield = sprite.addSpriteLayer("shield", "Ivan_Shield.png" , 16, 64, this.getTeamNum(), 0);
	if (shield !is null)
	{
		Animation@ anim = shield.addAnimation("default", 3, false);

		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		anim.AddFrame(5);
		anim.AddFrame(6);
		anim.AddFrame(7);

		shield.SetRelativeZ(-1.0f);
		shield.SetVisible(false);
		shield.setRenderStyle(RenderStyle::outline_front);
		shield.SetIgnoreParentFacing(true);
	}

	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_Vec2f("shop offset", Vec2f(-10,0));

	AddIconToken("$icon_ivan_follower$", "InteractionIcons.png", Vec2f(32, 32), 11);
	{
		ShopItem@ s = addShopItem(this, "Rite of Ivan", "$icon_ivan_follower$", "follower", "Gain Ivan's goodwill by offering him a bottle of vodka.");
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 1);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;

		s.spawnNothing = true;
	}

	AddIconToken("$icon_ivan_offering_0$", "AltarIvan_Icons.png", Vec2f(24, 24), 0);
	{
		ShopItem@ s = addShopItem(this, "Squat of Hoboness", "$icon_ivan_offering_0$", "offering_hobo", "Bring this corpse back from the dead as a filthy hobo.");
		AddRequirement(s.requirements, "blob", "bandit", "Bandit's Corpse", 1);
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 1);
		AddRequirement(s.requirements, "blob", "ratburger", "Rat Burger", 1);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}

	AddIconToken("$icon_ivan_offering_1$", "AltarIvan_Icons.png", Vec2f(24, 24), 1);
	{
		ShopItem@ s = addShopItem(this, "Squat of Kalashnikov", "$icon_ivan_offering_1$", "offering_ak47", "Bless your AK47 with Ivan's power.");
		AddRequirement(s.requirements, "blob", "log", "Log", 2);
		AddRequirement(s.requirements, "blob", "vodka", "Vodka", 2);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "High Caliber Ammunition (10)", "$icon_rifleammo$", "mat_rifleammo-10", "Saint bullets for saint rifles.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}	
	AddIconToken("$icon_badgercar$", "Badger.png", Vec2f(32, 16), 0);
	{
		ShopItem@ s = addShopItem(this, "Squat of Badger", "$icon_badgercar$", "badgercar", "Just don't hit it once", false, true);
		AddRequirement(s.requirements, "blob", "badger", "Badger", 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 1;

		s.spawnNothing = true;
	}
}


void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	if (caller is null) return;
 	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(27, Vec2f(0, -10), this, this.getCommandID("turn_sounds"), "Turn sounds off/onn", params);
	
	if (this.hasTag("colourful"))
		caller.CreateGenericButton(27, Vec2f(10, 0), this, ToggleButton, "STOP THE RAVE? >:(");
	else
			caller.CreateGenericButton(23, Vec2f(10, 0), this, ToggleButton, "LET'S GET THIS RAVE STARTED!!!");
}

void ToggleButton(CBlob@ this, CBlob@ caller)
{
	if (this.hasTag("colourful"))
		this.Untag("colourful");
	else
		this.Tag("colourful");
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	const f32 power = blob.get_f32("deity_power");
	const f32 radius = 64.00f + Maths::Sqrt(power);

	blob.setInventoryName("Altar of Ivan\n\nIvanic Power: " + power + "\nRadius: " + int(radius / 8.00f));

	CBlob@ localBlob = getLocalPlayerBlob();
	if (blob.hasTag("colourful") && localBlob !is null)
	{
		const f32 diameter = radius * 2.00f;

		const f32 dist = blob.getDistanceTo(localBlob);
		const f32 distMod = 1.00f - (dist / diameter);
		const f32 sqrDistMod = 1.00f - Maths::FastSqrt(dist / radius);

		if (dist < diameter)
		{
			ShakeScreen(50.0f, 15, blob.getPosition());

			if (getGameTime() % 8 == 0)
			{
				s16 step = blob.get_s16("rgbStep");

				if (step > 360) blob.set_bool("rgbReverse", true);
				else if (step <0) blob.set_bool("rgbReverse", false);

				const bool reverse = blob.get_bool("rgbReverse");

				if (reverse) step = blob.sub_s16("rgbStep", power / 10);
				else step = blob.add_s16("rgbStep", power / 10);

				const SColor color = HSVToRGB(step, 1.0f, 1.0f);
				SetScreenFlash(Maths::Min((power * 0.20f) * distMod, 50), color.getRed(), color.getGreen(), color.getBlue(), 0.75f);
			}
		}
	}

	if (getGameTime() % 8 == 0)
	{
		const SColor color = colors[getGameTime() % colors.size()];
		blob.SetLight(true);
		blob.SetLightRadius(radius);
		blob.SetLightColor(color);


		this.SetEmitSoundVolume(Maths::Max(power * 0.002f, 0.50f));
		this.SetEmitSoundSpeed(0.70f + (power * 0.0002f));
	}
}

void onTick(CBlob@ this)
{
	const f32 power = this.get_f32("deity_power");
	const f32 radius = 64.00f + Maths::Sqrt(power);

	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
	{
		int index = -1;
		f32 s_dist = 1337;
		u8 myTeam = this.getTeamNum();

		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			u8 team = b.getTeamNum();

			if (team < 7 && team <= 200 && b.hasTag("flesh"))
			{
				f32 dist = (b.getPosition() - this.getPosition()).Length();
				if (dist < s_dist)
				{
					s_dist = dist;
					index = i;
				}
			}
		}

		if (index < 0) return;

		CBlob@ target = blobsInRadius[index];
		Zap(this, target);

		// print("" + target.getName());
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("turn_sounds"))
	{
		u16 caller;
		if (params.saferead_netid(caller))
		{
			CBlob@ b = getBlobByNetworkID(caller);
			if (isClient() && b.isMyPlayer() && this.getSprite() !is null)
			{
				this.getSprite().SetEmitSoundPaused(!this.getSprite().getEmitSoundPaused());
			}
		}
	}
	else if (cmd == this.getCommandID("sync_deity"))
	{
		if (isClient())
		{
			u8 deity;
			u16 blobid;

			if (!params.saferead_u8(deity)) return;
			if (!params.saferead_u16(blobid)) return;
			
			CBlob@ b = getBlobByNetworkID(blobid);
			if (b is null) return;
			b.set_u8("deity_id", deity);
			if (b.getPlayer() is null) return;
			b.getPlayer().set_u8("deity_id", deity);
		}
	}
	else if (cmd == this.getCommandID("shop made item"))
	{
		u16 caller, item;

		if(!params.saferead_netid(caller) || !params.saferead_netid(item))
			return;

		string name = params.read_string();
		CBlob@ callerBlob = getBlobByNetworkID(caller);
		CPlayer@ callerPlayer = callerBlob.getPlayer();

		if (callerBlob is null) return;

		// if (isServer())
		{
			string[] spl = name.split("-");

			if (name == "follower")
			{
				this.add_f32("deity_power", 50);

				if (isClient())
				{
					// if (callerBlob.get_u8("deity_id") != Deity::mithrios)
					// {
						// client_AddToChat(callerPlayer.getCharacterName() + " has become a follower of Ivan.", SColor(255, 255, 0, 0));
					// }

					CBlob@ localBlob = getLocalPlayerBlob();
					if (localBlob !is null)
					{
						if (this.getDistanceTo(localBlob) < 128)
						{
							this.getSprite().PlaySound("Ivan_Offering.ogg", 2.00f, 1.00f);
							SetScreenFlash(255, 255, 255, 255, 3.00f);
						}
					}
				}

				if (isServer())
				{
					callerPlayer.set_u8("deity_id", Deity::ivan);
					callerBlob.set_u8("deity_id", Deity::ivan);

					CBitStream params1;
					params1.write_u8(Deity::ivan);
					params1.write_u16(callerBlob.getNetworkID());
					this.SendCommand(this.getCommandID("sync_deity"), params1);
				}

				return;
			}
			else
			{
				if (name == "offering_hobo")
				{
					this.add_f32("deity_power", 25);

					if (isServer())
					{
						CBlob@ hobo = server_CreateBlob("hobo", this.getTeamNum(), this.getPosition());
					}

					if (isClient())
					{
						CBlob@ localBlob = getLocalPlayerBlob();
						if (localBlob !is null)
						{
							if (this.getDistanceTo(localBlob) < 128)
							{
								this.getSprite().PlaySound("Ivan_Offering.ogg", 2.00f, 1.00f);
								SetScreenFlash(255, 255, 255, 255, 3.00f);
							}
						}
					}
					return;
				}
				else if (name == "offering_ak47")
				{
					this.add_f32("deity_power", 100);

					if (isServer())
					{
						CBlob@ gun = server_CreateBlob("ivanak47", this.getTeamNum(), this.getPosition());
					}

					if (isClient())
					{
						CBlob@ localBlob = getLocalPlayerBlob();
						if (localBlob !is null)
						{
							if (this.getDistanceTo(localBlob) < 128)
							{
								this.getSprite().PlaySound("Ivan_Offering.ogg", 2.00f, 1.00f);
								SetScreenFlash(255, 255, 255, 255, 3.00f);
							}
						}
					}
					return;
				}
			}

			this.getSprite().PlaySound("ConstructShort");
			if (isServer())
			{
				if (spl[0] == "coin")
				{
					CPlayer@ callerPlayer = callerBlob.getPlayer();
					if (callerPlayer is null) return;

					callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
				}
				else if (name.findFirst("mat_") != -1)
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
				else
				{
					CBlob@ blob = server_CreateBlob(spl[0], callerBlob.getTeamNum(), this.getPosition());

					if (blob is null) return;

					if (!blob.canBePutInInventory(callerBlob) && blob.canBePickedUp(callerBlob))
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
	}
}

void Zap(CBlob@ this, CBlob@ target)
{
	if (target.get_u32("next zap") > getGameTime()) return;

	const f32 power = this.get_f32("deity_power");
	const f32 radius = 64.00f + Maths::Sqrt(power);

	Vec2f dir = target.getPosition() - this.getPosition();
	f32 dist = Maths::Abs(dir.Length());
	dir.Normalize();

	target.setVelocity(Vec2f(dir.x, dir.y) * (7.0f + (power * 0.001f)));
	SetKnocked(target, 90);
	target.set_u32("next zap", getGameTime() + 5);

	if (isServer())
	{
		f32 damage = 0.125f;
		this.server_Hit(target, target.getPosition(), dir, damage * (target.hasTag("explosive") ? 16.00f : 1.00f) , HittersTC::staff);
	}

	if (isClient())
	{
		this.getSprite().PlaySound("Ivan_Zap.ogg");

		CSpriteLayer@ shield = this.getSprite().getSpriteLayer("shield");
		if (shield !is null)
		{
			shield.SetVisible(true);
			shield.setRenderStyle(RenderStyle::outline_front);

			shield.SetFrameIndex(0);
			shield.SetAnimation("default");
			shield.ResetTransform();
			shield.RotateBy(dir.Angle() * -1.00f, Vec2f());
			shield.TranslateBy(dir * (radius - 8.0f));
		}
	}
}
