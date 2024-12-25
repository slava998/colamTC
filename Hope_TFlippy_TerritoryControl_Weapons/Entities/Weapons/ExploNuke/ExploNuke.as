#include "Hitters.as";
#include "Explosion.as";

const u32 fuel_timer_max = 30 * 0.50f;

void onInit(CBlob@ this)
{
	this.set_f32("map_damage_ratio", 0.75f);
	this.set_f32("map_damage_radius", 42.0f);
	this.set_string("custom_explosion_sound", "Keg.ogg");
		
	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 9.0f);
	
	this.getShape().SetRotationsAllowed(true);
	
	this.set_u32("fuel_timer", getGameTime() + fuel_timer_max + XORRandom(15));
	
	this.Tag("projectile");
	this.Tag("explosive");

	this.Tag("no_mithril");
	this.Tag("no_fallout");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Shell_Whistle.ogg");
	sprite.SetEmitSoundSpeed(1.1f);
	sprite.SetEmitSoundVolume(1.0f);
	sprite.SetEmitSoundPaused(false);
}

void onTick(CBlob@ this)
{
	// f32 modifier = Maths::Max(0, this.getVelocity().y * 0.3f);
	// this.getSprite().SetEmitSoundVolume(Maths::Max(0, modifier));

	if (this.get_u32("fuel_timer") > getGameTime())
	{
		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.15f, 10.0f));
		
		Vec2f dir = Vec2f(0, 1);
		dir.RotateBy(this.getAngleDegrees());
					
		this.setVelocity(dir * -this.get_f32("velocity") + Vec2f(0, this.getTickSinceCreated() > 5 ? XORRandom(50) / 100.0f : 0));
		
		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
	}
	else
	{
		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
		this.getSprite().SetEmitSoundPaused(true);
	}		
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ boom = server_CreateBlobNoInit("nukeexplosion");
		boom.Tag("no mithril");
		boom.Tag("no fallout");
		boom.setPosition(this.getPosition());
		boom.set_u8("boom_start", 0);
		boom.set_u8("boom_end", 9);
		boom.set_f32("flash_distance", 320);
		// boom.Tag("no mithril");
		// boom.Tag("no flash");
		boom.Init();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() && blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null) if (blob.hasTag("gas")) return; 
	if (this.getTickSinceCreated() > 5 && (solid ? true : (blob !is null && blob.isCollidable())))
	{
		if (isServer())
		{
			this.server_Die();
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}