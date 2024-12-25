#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";

// const Vec2f arm_offset = Vec2f(-2, -4);

// const u8 explosions_max = 25;

// f32 sound_delay;

string[] particles = 
{
	"dust.png",
	"dust2.png",
	"DustSmall.png",
	// "Smoke.png"
};

void onInit(CBlob@ this)
{
	// this.Tag("map_damage_dirt");
	// this.set_string("custom_explosion_sound", "KegExplosion");
	
	this.getShape().SetStatic(true);
	
	// SetScreenFlash(255, 255, 255, 255);
	
	// if (isClient())
	// {
		// Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
		// f32 distance = Maths::Abs(this.getPosition().x - pos.x) / 8;
		// sound_delay = (Maths::Abs(this.getPosition().x - pos.x) / 8) / (340 * 0.4f);
		
		// print("delay: " + sound_delay);
	// }
	
	// this.SetLight(true);
	// this.SetLightColor(SColor(255, 255, 255, 255));
	// this.SetLightRadius(1024.5f);
	
	this.set_f32("map_damage_radius", 0);
	// this.set_f32("map_damage_ratio", 0.25f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("FireWave_EarRape.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.5f);
	sprite.SetEmitSoundSpeed(0.93f+(XORRandom(8)*0.01f));
	this.set_bool("move left", XORRandom(2) == 0 ? true : false);
	
	this.getCurrentScript().tickFrequency = 1;
	if (isServer()) this.server_SetTimeToDie(30 + XORRandom(60));
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	bool server = isServer();
	bool client = isClient();
	
	Vec2f top = Vec2f(this.getPosition().x, 0);
	Vec2f bottom = Vec2f(this.getPosition().x, map.tilemapheight * 8);
	Vec2f pos;
		
	if (map.rayCastSolid(top, bottom, pos))
	{
		if (server)
		{
			if (XORRandom(5)==0) Explode(this, 32.0f, 1.0f);
		
			// if (XORRandom(100) < 75)
			// {
				// CBlob@ flame = server_CreateBlob("flame", this.getTeamNum(), pos);
				// flame.server_SetTimeToDie(3 + XORRandom(10));
			// }
		}
	}
	
	//if (server)
	{
		if (top.x > (map.tilemapwidth * 8) - 8) this.server_Die();

		if (getGameTime()%10==0)
		{
			CBlob@[] blobs;
			if (map.getBlobsInBox(Vec2f(top.x - 32, top.y-64), Vec2f(pos.x+32, pos.y), blobs))
			{
			    for (int i = 0; i < blobs.length; i++)
			    {
				    if (blobs[i] is null) continue;
				    CBlob@ blob = blobs[i];
					if (blob.getPosition().y >= this.getPosition().y-100 || blob.hasTag("aerial")) blob.AddForce((this.getPosition()-(blob.getPosition()+Vec2f(0, 50.0f+XORRandom(50))))*10*(blob.hasTag("aerial") ? 5 : 1));
   				    
					if (server) this.server_Hit(blob, blob.getPosition(), Vec2f(), 0.05f, Hitters::builder, true);
			    }
			}
		}
	}
	
	for (int i = 0; i < 24; i++)
	{
		f32 width = (i * 2);
		Vec2f p =  Vec2f(pos.x + (XORRandom(width * 2) - width), pos.y - (i * 8));
	
		// if (server && i % 16 == 0) 
		// {
			// if (map.isTileWood(map.getTile(p).type)) map.server_setFireWorldspace(p, true);
		// }
		if (client && getGameTime()%2==0) makeSteamParticle(this, p, particles[XORRandom(particles.length)]);
	}
	
	if (client) ShakeScreen(64, 32, pos);
	if (XORRandom(150) == 0) this.set_bool("move left", !this.get_bool("move left"));

	this.setPosition(pos + (Vec2f(this.get_bool("move left") ? -0.5f - (XORRandom(4)*0.25f): 0.5f + (XORRandom(4)*0.25f), 0)));
}

void makeSteamParticle(CBlob@ this, Vec2f pos, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(filename, pos + random, Vec2f(0, 0), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -XORRandom(100) / 400.00f, false);
}