#include "Knocked.as";
#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "EmotesCommon.as";
#include "RgbStuff.as";

const int steroid_duration = 20 * 8 * 1.30f;
const f32 steroid_step = 1.00f / steroid_duration;

void onInit(CBlob@ this)
{
	this.add_f32("steroid_effect", 1.00f);
	this.set_f32("voice pitch", 0.40f);

	if (isClient() && this.isMyPlayer()) 
	{
		getMap().CreateSkyGradient("Dead_skygradient.png");
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("OverwhelmingStrength.ogg");
		sprite.SetEmitSoundVolume(0.60f);
		sprite.SetEmitSoundPaused(false);
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) this.getCurrentScript().runFlags |= Script::remove_after_this;

	f32 true_level = this.get_f32("steroid_effect");		
	f32 level = 0.50f + true_level;
	f32 withdrawal = 1.00f - Maths::Min(true_level, 1);

	if (true_level <= 0.00f)
	{
		if (isServer() && !this.hasTag("transformed"))
		{
			if (this.hasTag("human") && this.getConfig() != "freak")
			{
				CBlob@ blob = server_CreateBlob("freak", this.getTeamNum(), this.getPosition());
				blob.set_f32("voice pitch", 0.70f);
				if (this.getPlayer() !is null) 
				{
					blob.server_SetPlayer(this.getPlayer());
				}

			}
			
			this.Tag("transformed");
			this.server_Die();
		}

	this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	else
	{
		RunnerMoveVars@ moveVars;
		if (this.get("moveVars", @moveVars))
		{
			moveVars.walkFactor *= 0.50f - (withdrawal * 1.50f);
			moveVars.jumpFactor *= 0.50f - (withdrawal * 2.00f);
		}	
		
		if (true_level < 0.50f)
		{
			if (this.getTickSinceCreated() % (30 + XORRandom(60)) == 0)
			{
				SetKnocked(this, 20);
				if (isClient())
				{
					this.getSprite().PlaySound("TraderScream.ogg", 0.8f, this.get_f32("voice pitch") + (XORRandom(50) * 0.01f));
					
					if (this.isMyPlayer())
					{
						this.getSprite().PlaySound("Thunder2", 1.50f, 1.00f + (XORRandom(100) * 0.01f));
					
						ShakeScreen(200, 20, this.getPosition());
						SetScreenFlash(255, 255, 255, 255, 0.25f);
					}
				}
			}
			
			Vec2f vel = this.getVelocity();
			if (Maths::Abs(vel.x) > 0.1)
			{
				f32 angle = this.get_f32("angle");
				angle += vel.x * this.getRadius();
				if (angle > 360.0f) angle -= 360.0f;
				else if (angle < -360.0f) angle += 360.0f;
				
				this.set_f32("angle", angle);
				this.setAngleDegrees(angle);
			}
		}
		else
		{
			if (isClient())
			{
				if (this.isMyPlayer())
				{
					ShakeScreen(50.0f * (withdrawal + 0.10f), 1, this.getPosition());
					
					if (XORRandom(100 * true_level) == 0)
					{
						u8 emote = 0;
						if (true_level < 0.40f) emote = Emotes::skull;
						else if (true_level < 0.50f) emote = Emotes::skull;
						else if (true_level < 0.60f) emote = Emotes::skull;
						else emote = Emotes::flex;
						set_emote(this, emote);
					}
				}
			}
		}
		
		this.add_f32("steroid_effect", -steroid_step);
	}
}
