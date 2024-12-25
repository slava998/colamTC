
#include "Hitters.as";
#include "Explosion.as";
#include "ArcherCommon.as";

string[] particles = 
{
	"LargeSmoke.png",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.Tag("gas");
	this.Tag("invincible");

	this.getShape().SetGravityScale(0.40f);

	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);

	this.Tag("map_damage_dirt");
	
	if (!this.exists("toxicity")) this.set_f32("toxicity", 0.01f);
	
	// this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right | CBlob::map_collide_up | CBlob::map_collide_down);
	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 5;

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(60 + XORRandom(15));
	
	if (isClient())
	{
		this.getCurrentScript().runFlags |= Script::tick_onscreen;
	}
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getPosition().y < 0) this.server_Die();
	
	CBlob@[] blobsInRadius;
	if (this.getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 4.0f, @blobsInRadius))
	{
		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ blob = blobsInRadius[i];
			if (blob.hasTag("flesh") && !blob.hasTag("gas immune"))
			{
				f32 value = blob.get_f32("loved");
				if (value == 0)
				{
					if (!blob.hasScript("Love_Effect.as")) blob.AddScript("Love_Effect.as");
				}
				
				blob.set_f32("loved", value + 0.005f);
			}
		}
	}

	if (isClient() && this.isOnScreen())
	{
		MakeParticle(this, "LoveGas.png");
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("gas");
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	CParticle@ particle = ParticleAnimated(filename, this.getPosition() + Vec2f(32 - XORRandom(64), 16 - XORRandom(40)), Vec2f(), float(XORRandom(360)), 1.0f + (XORRandom(50) / 100.0f), 4, 0.00f, false);
	if (particle !is null) 
	{
		particle.collides = false;
		particle.deadeffect = 1;
		particle.bounce = 0.0f;
		particle.fastcollision = true;
		particle.lighting = false;
		particle.setRenderStyle(RenderStyle::additive);
	}
}