// generic crate
// can hold items in inventory or unpacks to catapult/ship etc.

#include "CrateCommon.as";
#include "VehicleAttachmentCommon.as";
#include "CargoAttachmentCommon.as";
#include "MiniIconsInc.as";
#include "Help.as";
#include "MakeMat.as";

const string required_space = "required space";

const string[] packnames = { 
	"catapult",
	"bomber",
	"ballista",
	"mounted_bow",
	"longboat",
	"warboat",
	"steamtank",
	"gatlinggun",
	"mortar",
	"howitzer",
	"triplane",
	"armoredbomber",
	"rocketlauncher"
};

void onInit(CBlob@ this)
{
	this.addCommandID("unpack");
	//this.addCommandID("getin");
	//this.addCommandID("getout");
	this.addCommandID("stop unpack");
	this.Tag("crate");
	this.set_string("crateType", "default");

	u8 frame = 0;
	
	if (this.hasTag("plasteel"))
	{
		this.getSprite().SetAnimation("plasteel");
		this.set_string("crateType", "plasteel");
	}
	else if (this.getTeamNum() == 250 || this.getName() == "cacrate")
	{
		this.getSprite().SetAnimation("chicken");
		this.set_string("crateType", "chicken");
	}
	else if (this.getName() == "packercrate")
	{
		this.getSprite().SetAnimation("packercrate");
		this.set_string("crateType", "packercrate");
	}
	else if (this.getTeamNum() < 7 && this.getTeamNum() > -1)
	{
		this.getSprite().SetAnimation("team");
		this.set_string("crateType", "team");
	}
	else if (this.exists("frame"))
	{
		frame = this.get_u8("frame");
		string packed = this.get_string("packed");

		// GIANT HACK!!!
		for (int i = 0; i < 13; i++)
		{
			if (packed == packnames[i])	 // HACK:
			{
				CSpriteLayer@ icon = this.getSprite().addSpriteLayer("icon", "/MiniIcons.png" , 16, 16, this.getTeamNum(), -1);
				if (icon !is null)
				{
					Animation@ anim = icon.addAnimation("display", 0, false);
					anim.AddFrame(frame);

					icon.SetOffset(Vec2f(-2, 1));
					icon.SetRelativeZ(1);
				}
				this.getSprite().SetAnimation("label");

				// help
				const string iconToken = "$crate_" + packed + "$";
				AddIconToken("$crate_" + packed + "$", "MiniIcons.png", Vec2f(16, 16), frame);
				SetHelp(this, "help use", "", iconToken + "Unpack " + packed + "   $KEY_E$", "", 4);
			}
			else
			{
				u8 newFrame = 0;

				if (packed == "kitchen")
					newFrame = FactoryFrame::kitchen;
				if (packed == "nursery")
					newFrame = FactoryFrame::nursery;
				if (packed == "tunnel")
					newFrame = FactoryFrame::tunnel;
				if (packed == "healing")
					newFrame = FactoryFrame::healing;
				if (packed == "factory")
					newFrame = FactoryFrame::factory;
				if (packed == "storage")
					newFrame = FactoryFrame::storage;

				if (newFrame > 0)
				{
					CSpriteLayer@ icon = this.getSprite().addSpriteLayer("icon", "/MiniIcons.png" , 16, 16, this.getTeamNum(), -1);
					if (icon !is null)
					{
						icon.SetFrame(newFrame);
						icon.SetOffset(Vec2f(-2, 1));
						icon.SetRelativeZ(1);
					}
					this.getSprite().SetAnimation("label");
					this.set_string("crateType", "label");
				}
			}	 //END OF HACK
		}
	}

 	const uint unpackSecs = 3;
	this.set_u32("unpack secs", unpackSecs);
	this.set_u32("unpack time", 0);

	if (this.exists("packed name"))
	{
		if (this.get_string("packed name").length > 1)
			this.setInventoryName("Crate with " + this.get_string("packed name"));
	}

	if (!this.exists(required_space))
	{
		this.set_Vec2f(required_space, Vec2f(5, 4));
	}
	
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ parachute = sprite.addSpriteLayer("parachute",   32, 32);

	if (parachute !is null)
	{
		Animation@ anim = parachute.addAnimation("default", 0, true);
		anim.AddFrame(4);
		parachute.SetOffset(Vec2f(0.0f, - 17.0f));
		parachute.SetVisible(false);
	}

	this.getSprite().SetZ(-10.0f);
}

void onTick(CBlob@ this)
{
	// parachute

	if (this.hasTag("parachute"))		// wont work with the tick frequency
	{
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ parachute = sprite.getSpriteLayer("parachute");
		
		parachute.SetVisible(true);

		// para force + swing in wind
		this.AddForce(Vec2f(Maths::Sin(getGameTime() * 0.03f) * 1.0f, -30.0f * this.getVelocity().y));

		if (this.isOnGround() || this.isInWater() || this.isAttached())
		{
			Land(this);
		}
	}
	else
	{
		if (hasSomethingPacked(this))
			this.getCurrentScript().tickFrequency = 15;
		else
		{
			this.getCurrentScript().tickFrequency = 0;
			return;
		}

		// unpack
		u32 unpackTime = this.get_u32("unpack time");

		// can't unpack in no build sector or blocked in with walls!
		if (!canUnpackHere(this))
		{
			this.set_u32("unpack time", 0);
			this.getCurrentScript().tickFrequency = 15;
			this.getShape().setDrag(2.0);
			return;
		}

		if (unpackTime != 0 && getGameTime() >= unpackTime)
		{
			Unpack(this);
			return;
		}
	}
}

void Land(CBlob@ this)
{
	this.Untag("parachute");

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ parachute = sprite.getSpriteLayer("parachute");

	if (parachute !is null && parachute.isVisible())
	{
		parachute.SetVisible(false);
		ParticlesFromSprite(parachute);
	}
	// unpack immediately
	if (this.exists("packed") && this.hasTag("unpack on land"))
	{
		Unpack(this);
	}

	if (this.hasTag("destroy on touch"))
	{
		this.server_SetHealth(-1.0f); // TODO: wont gib on client
		this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("parachute") && blob.get_string("crateType") != "chicken";
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (this.hasTag("unpackall"))
		return false;

	if (forBlob.getCarriedBlob() is null && this.getInventory().getItemsCount() == 0)
		return false;

	// not accessible if player in inv
	for (int i = 0; i < this.getInventory().getItemsCount(); i++)
	{
		if (this.getInventory().getItem(i).hasTag("player"))
			return false;
	}

	return (!hasSomethingPacked(this));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	Vec2f buttonpos(0, 0);
	/*if (this.getInventory().getItemsCount() > 0 && this.getInventory().getItem(0) is caller)    // fix - iterate if more stuff in crate
	{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		caller.CreateGenericButton( 6, Vec2f(0,0), this, this.getCommandID("getout"), "Get out", params );
	}
	else*/
	if (this.hasTag("unpackall"))
	{
		caller.CreateGenericButton(12, buttonpos, this, this.getCommandID("unpack"), "Unpack all");
	}
	else if (hasSomethingPacked(this) && !canUnpackHere(this))
	{

		string msg = "Can't unpack " + this.get_string("packed name");

		//if (this.isAttached())
		//	msg += " while carrying it";
		//else
		msg += " here";

		CButton@ button = caller.CreateGenericButton(12, buttonpos, this, 0, msg);
		if (button !is null)
		{
			button.SetEnabled(false);
		}
	}
	else if (isUnpacking(this))
	{
		caller.CreateGenericButton("$DISABLED$", buttonpos, this, this.getCommandID("stop unpack"), "Stop " + this.get_string("packed name"));
	}
	else if (hasSomethingPacked(this))
	{
		caller.CreateGenericButton(12, buttonpos, this, this.getCommandID("unpack"), "Unpack " + this.get_string("packed name"));
	}
	/*else if (this.getInventory().getItemsCount() == 0 && caller.getCarriedBlob() is null)
	{
		CBitStream params;
		params.write_u16( caller.getNetworkID() );
		caller.CreateGenericButton( 4, Vec2f(0,0), this, this.getCommandID("getin"), "Get inside", params );
	}*/
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("unpack"))
	{
		if (hasSomethingPacked(this))
		{
			if (canUnpackHere(this))
			{
				this.set_u32("unpack time", getGameTime() + this.get_u32("unpack secs") * getTicksASecond());
				this.getShape().setDrag(10.0f);
			}
		}
		else
		{
			this.server_SetHealth(-1.0f);
			this.server_Die();
		}
	}
	else if (cmd == this.getCommandID("stop unpack"))
	{
		this.set_u32("unpack time", 0);
	}
	/*else if (cmd == this.getCommandID("getin"))
	{
		CBlob @caller = getBlobByNetworkID( params.read_u16() );

		if (caller !is null) {
			this.server_PutInInventory( caller );
		}
	} else if (cmd == this.getCommandID("getout"))
	{
		CBlob @caller = getBlobByNetworkID( params.read_u16() );

		if (caller !is null) {
			this.server_PutOutInventory( caller );
		}
	}*/
}

void Unpack(CBlob@ this)
{
	if (!isServer()) return;

	if (this.hasTag("unpacking")) return;

	this.Tag("unpacking");

	u8 count = this.exists("count") ? this.get_u8("count") : 1;

	if (this.get_string("packed").findFirst("mat_") != -1)
	{
		MakeMat(this, this.getPosition(), this.get_string("packed"), count);
	}
	else
	{
		for (u8 i = 0; i < count; i++)
		{
			CBlob@ blob = server_CreateBlob(this.get_string("packed"), this.getTeamNum(), Vec2f_zero);
			if (blob !is null && blob.getShape() !is null)
			{
				blob.setPosition(this.getPosition() + Vec2f(0, (this.getHeight() - blob.getHeight()) / 2));
				TryToAttachVehicle(blob);

				if (this.exists("msg blob"))
				{
					CBitStream params;
					params.write_u16(blob.getNetworkID());
					CBlob@ factory = getBlobByNetworkID(this.get_u16("msg blob"));
					if (factory !is null)
					{
						factory.SendCommand(factory.getCommandID("track blob"), params);
					}
				}
			}
		}
	}

	this.server_SetHealth(-1.0f); // TODO: wont gib on client
	this.server_Die();
}

bool isUnpacking(CBlob@ this)
{
	return getGameTime() <= this.get_u32("unpack time");
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	// die on empty crate
	if (!this.isInInventory() && this.getInventory().getItemsCount() == 0)
	{
		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		this.getSprite().Gib();
		Vec2f pos = this.getPosition();
		Vec2f vel = this.getVelocity();
		//custom gibs
		string fname = "Crate.png";
		for (int i = 0; i < 4; i++)
		{
			makeGibParticle(fname, pos, vel + getRandomVelocity(90, 1 , 120), 9, 2 + i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
		}
	}

	if (isServer() && !this.hasTag("unpacking"))
	{
		Unpack(this);
	}
}

bool canUnpackHere(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	Vec2f space = this.get_Vec2f(required_space);
	Vec2f t_off = Vec2f(map.tilesize * 0.5f, map.tilesize * 0.5f);
	Vec2f offsetPos = crate_getOffsetPos(this, map);
	for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
	{
		for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
		{
			Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
			Vec2f v = offsetPos + temp;
			if (map.isTileSolid(v))
			{
				return false;
			}
		}
	}

	string packed = this.get_string("packed");
	bool water = packed == "longboat" || packed == "warboat";
	//if (this.isAttached())
	//{
	//	CBlob@ parent = this.getAttachments().getAttachedBlob("PICKUP", 0);
	//	if (parent !is null)
	//	{
	//		return ((!water && parent.isOnGround()) || (water && map.isInWater(parent.getPosition() + Vec2f(0.0f, 8.0f))));
	//	}
	//}
	bool inwater = map.isInWater(this.getPosition() + Vec2f(0.0f, 8.0f));
	bool supported = ((!water && (this.isOnGround() || inwater)) || (water && inwater));
	return (supported);
}

Vec2f crate_getOffsetPos(CBlob@ blob, CMap@ map)
{
	Vec2f halfSize = blob.get_Vec2f(required_space) * 0.5f;

	Vec2f alignedWorldPos = map.getAlignedWorldPos(blob.getPosition() + Vec2f(0, -2)) + (Vec2f(0.5f, 0.0f) * map.tilesize);
	Vec2f offsetPos = alignedWorldPos - Vec2f(halfSize.x , halfSize.y) * map.tilesize;
	return offsetPos;
}

// SPRITE

// render unpacking time

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!(blob.exists("packed")) || blob.get_string("packed name").size() == 0) return;

	Vec2f pos2d = blob.getInterpolatedScreenPos();
	u32 gameTime = getGameTime();
	u32 unpackTime = blob.get_u32("unpack time");

	if (unpackTime > gameTime)
	{
		// draw drop time progress bar
		int top = pos2d.y - 1.0f * blob.getHeight();
		Vec2f dim(32.0f, 12.0f);
		int secs = 1 + (unpackTime - gameTime) / getTicksASecond();
		Vec2f upperleft(pos2d.x - dim.x / 2, top - dim.y - dim.y);
		Vec2f lowerright(pos2d.x + dim.x / 2, top - dim.y);
		f32 progress = 1.0f - (float(secs) / float(blob.get_u32("unpack secs")));
		GUI::DrawProgressBar(upperleft, lowerright, progress);
	}

	if (blob.isAttached())
	{
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
		if(point is null ){return;}

		CBlob@ holder = point.getOccupied();

		if (holder is null) { return; }

		CPlayer@ local = getLocalPlayer();
		if (local !is null && local.getBlob() is holder)
		{
			CMap@ map = blob.getMap();
			if (map is null) return;

			Vec2f space = blob.get_Vec2f(required_space);
			Vec2f offsetPos = crate_getOffsetPos(blob, map);

			const f32 scalex = getDriver().getResolutionScaleFactor();
			const f32 zoom = getCamera().targetDistance * scalex;
			Vec2f aligned = getDriver().getScreenPosFromWorldPos(offsetPos);
			GUI::DrawIcon("CrateSlots.png", 0, Vec2f(40, 32), aligned, zoom);

			for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
			{
				for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
				{
					Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
					Vec2f v = offsetPos + temp;
					if (map.isTileSolid(v))
					{
						GUI::DrawIcon("CrateSlots.png", 5, Vec2f(8, 8), aligned + (temp - Vec2f(0.5f, 0.5f)* map.tilesize) * 2 * zoom, zoom);
					}
				}
			}
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachCargo(this, blob);
	}
	
	if(!solid)return;

	f32 vellen = this.getOldVelocity().Length();

	if (this.getName() == "crate") {
		if (isServer() && vellen > 5.0f)
		{
			Unpack(this);
		}
	} else {
		if (isServer() && vellen > 50.0f)
		{
			Unpack(this);
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.isAttachedToPoint("CARGO"))
	{
		this.Tag("paradetach");
		this.inventoryButtonPos = Vec2f(-10, 1);
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (this.hasTag("paradetach"))
	{
		this.Tag("parachute");
		this.Untag("paradetach");
		this.setAngleDegrees(0.0f);
		this.inventoryButtonPos = Vec2f(0, 0);
		this.getCurrentScript().tickFrequency = 1;
		if (isClient()) this.getSprite().PlaySound("thud", 2.0f, 1.0f);
	}
}

void onHealthChange(CBlob@ this, f32 oldHealth)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		string animation_name = this.get_string("crateType");
		Animation@ destruction = sprite.getAnimation(animation_name);
		if (destruction !is null)
		{
			f32 frame;
			//f32 frame = Maths::Floor((this.getInitialHealth() - this.getHealth()) / (this.getInitialHealth() / sprite.animation.getFramesCount()));
			if (this.getHealth() == this.getInitialHealth())frame = 0;
			else frame = 1;

			sprite.animation.frame = frame;
		}
	}
}