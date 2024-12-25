// Swing Door logic

#include "Hitters.as"
#include "HittersTC.as"
#include "FireCommon.as"
#include "MapFlags.as"
#include "DoorCommon.as"
#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.addCommandID("static on");
	this.addCommandID("static off");

	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = true;
	
	this.Tag("place norotate");
	this.Tag("door");
	this.Tag("blocks water");
	
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ lever = sprite.addSpriteLayer("lever", "Gate.png", 16, 16);
	if (lever !is null)
	{
		lever.SetRelativeZ(-99.0f);
		lever.SetOffset(this.isFacingLeft() ? Vec2f(-12.0f, 12.0f) : Vec2f(12.0f, 12.0f));
		//lever.SetVisible(false);
		Animation@ anim = lever.addAnimation("active", 3, false);
		if (anim !is null)
		{
			anim.AddFrame(3);
			anim.AddFrame(7);
			anim.AddFrame(11);
			anim.AddFrame(7);
			anim.AddFrame(3);
			lever.SetAnimation(anim);
		}
		lever.SetFrameIndex(0);
	}

	this.addCommandID("set_state");
	this.addCommandID("sync_state");
	//server_Sync(this);
}

void server_Sync(CBlob@ this)
{
	if (isServer())
	{
		CBitStream stream;
		stream.write_bool(this.get_bool("state"));
		
		this.SendCommand(this.getCommandID("sync_state"), stream);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("set_state"))
	{
		bool state = params.read_bool();
		this.set_bool("state", !state);
		this.getSprite().PlaySound(state ? "DoorOpen.ogg" : "DoorClose.ogg", 1.5f, 0.85f);
		setOpen(this, !state);

		this.set_u8("delay", 10);

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				CSpriteLayer@ lever = sprite.getSpriteLayer("lever");
				if (lever !is null)
				{
					lever.SetFrameIndex(0); // activates the animation i guess
					lever.SetAnimation("active");
				}
			}
		}
	}
	else if (cmd == this.getCommandID("sync_state"))
	{
		if (isClient())
		{
			bool ss = params.read_bool();
			
			this.set_bool("state", ss);
		}
	}
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	Vec2f pos = this.getPosition();
	u32 ang = u32(this.getAngleDegrees() / 90.00f) % 2;
	
	CMap@ map = this.getMap();
	this.getShape().getConsts().collidable = true;

	for (int i = 0; i < 5; i++)
	{
		if (ang == 0) map.server_SetTile(Vec2f(pos.x, (pos.y - 16) + i * 8), CMap::tile_wood_back);
		else map.server_SetTile(Vec2f((pos.x - 16) + i * 8, pos.y), CMap::tile_wood_back);
	}
	
	this.getSprite().PlaySound("/build_door.ogg");
}

bool isOpen(CBlob@ this)
{
	return !this.getShape().getConsts().collidable;
}

void setOpen(CBlob@ this, bool open)
{
	CSprite@ sprite = this.getSprite();
	if (open)
	{
		sprite.SetZ(-100.0f);
		sprite.SetAnimation("open");
		this.getShape().getConsts().collidable = false;
		
		this.getSprite().PlaySound("/DoorOpen.ogg", 1.00f, 1.00f);
		// this.getSprite().PlaySound("/Blastdoor_Open.ogg", 1.00f, 1.00f);
	}
	else
	{
		sprite.SetZ(100.0f);
		sprite.SetAnimation("close");
		this.getShape().getConsts().collidable = true;
		Sound::Play("/DoorClose.ogg", this.getPosition(), 1.00f, 0.80f);
	}
	
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			blob.AddForce(Vec2f(0, 0)); // Hack to awake sleeping blobs' physics
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	CBitStream params;
	params.write_bool(this.get_bool("state"));

	if (this is null || caller is null) return;
	if (this.getTeamNum() < 7 && caller.getTeamNum() != this.getTeamNum()) return;
	if (this.getDistanceTo(caller) > 96.0f
	|| (this.isFacingLeft() ? this.getPosition().x > caller.getPosition().x : this.getPosition().x < caller.getPosition().x)) return;

	CButton@ button = caller.CreateGenericButton(8, Vec2f(-4, 0), this, this.getCommandID("set_state"), !this.get_bool("state") ? "Open gate" : "Close gate", params);
	if (button !is null)
	{
		button.SetEnabled(this.getDistanceTo(caller) < 48.0f);
	}
}

bool canClose(CBlob@ this)
{
	const uint count = this.getTouchingCount();
	uint collided = 0;
	for (uint step = 0; step < count; ++step)
	{
		CBlob@ blob = this.getTouchingByIndex(step);
		if (blob.isCollidable())
		{
			collided++;
		}
	}
	return collided == 0;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::builder) damage *= 0.25;
	else if (customData == HittersTC::bullet_low_cal
	|| customData == HittersTC::bullet_high_cal) damage *= 0.25f;
	else if (customData == HittersTC::shotgun) damage *= 0.5f;
	else if (customData == Hitters::saw || customData == Hitters::drill) damage *= 2;
	else if (customData == Hitters::flying) damage *= 0.25f;

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		u8 frame = 0;

		Animation @destruction_anim = sprite.getAnimation("destruction");
		if (destruction_anim !is null)
		{
			if (this.getHealth() < this.getInitialHealth())
			{
				f32 ratio = (this.getHealth() - damage * getRules().attackdamage_modifier) / this.getInitialHealth();


				if (ratio <= 0.0f)
				{
					frame = destruction_anim.getFramesCount() - 1;
				}
				else
				{
					frame = (1.0f - ratio) * (destruction_anim.getFramesCount());
				}

				frame = destruction_anim.getFrame(frame);
			}
		}

		Animation @close_anim = sprite.getAnimation("close");
		u8 lastframe = close_anim.getFrame(close_anim.getFramesCount() - 1);
		if (lastframe < frame)
		{
			close_anim.AddFrame(frame);
		}
	}

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !isOpen(this);
}