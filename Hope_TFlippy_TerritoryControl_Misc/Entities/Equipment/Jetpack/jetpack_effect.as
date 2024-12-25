#include "RunnerCommon.as"
#include "MakeDustParticle.as";
#include "Knocked.as";
#include "FireParticle.as"

void onInit(CBlob@ this)
{
	if (this.get_string("reload_script") != "jetpack")
		UpdateScript(this);
}

void UpdateScript(CBlob@ this)
{
	CSpriteLayer@ jetpack = this.getSprite().addSpriteLayer("jetpack", "jetpack_icon.png", 24, 24);

	if (jetpack !is null)
	{
		jetpack.SetVisible(true);
		jetpack.SetRelativeZ(-2);
		jetpack.SetOffset(Vec2f(2, 0));
		if (this.getSprite().isFacingLeft())
			jetpack.SetFacingLeft(true);
	}
}

// bool delay = false;

void onTick(CBlob@ this)
{
	//if (this.get_string("reload_script") == "jetpack")
	//{
	//	UpdateScript(this);
	//	this.set_string("reload_script", "");
	//}

	const bool isknocked = isKnocked(this);
	u32 tmp = this.get_u32("nextJetpack");
	const bool flying = tmp > getGameTime();

	string torsoname = this.get_string("equipment_torso");
	string torso2name = this.get_string("equipment2_torso");

	f32 mod = 1.0f;
	if (torsoname == "jetpack" && torso2name == "jetpack")
	{
		mod = 1.5f;
	}
	
	if (!flying)
	{
		CControls@ controls = this.getControls();
		if (controls !is null && this.isMyPlayer() && controls.isKeyPressed(KEY_LSHIFT) && !isknocked)
		{
			Vec2f dir = this.getAimPos() - this.getPosition();
			dir.Normalize();

			this.setVelocity(dir * 8.00f * mod);

			Vec2f pos = this.getPosition()+  Vec2f( 0.0f, 4.0f);
			if (isClient())
			{
				CBitStream params;
				params.write_bool(true);
				this.SendCommand(this.getCommandID("jetpackv1_effects"), params);

				MakeDustParticle(pos + Vec2f(2.0f, 0.0f), "Dust.png");
				this.getSprite().PlaySound("/Jetpack_Offblast.ogg");
			}

			this.set_u32("nextJetpack", getGameTime() + 90);
		}
	}
	if (isClient())
	{
		if ((getGameTime() + 75) < tmp)
			makeSteamParticle(this, Vec2f(), XORRandom(100) < 30 ? ("SmallFire" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		else if (getGameTime() < tmp)
			makeSteamParticle(this, Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.0015f * this.getRadius(),"SmallSteam",Vec2f(XORRandom(10)-5,XORRandom(10)-5)*0.2*this.getRadius());
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam", const Vec2f displacement = Vec2f(0,0))
{
	if (!isClient()) return;

	ParticleAnimated(filename, this.getPosition()+displacement, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}
