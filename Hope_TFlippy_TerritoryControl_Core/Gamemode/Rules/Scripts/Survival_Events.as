#define SERVER_ONLY

void onInit(CRules@ this)
{
	u32 time = getGameTime();
	this.set_u32("lastMeteor", time);
	this.set_u32("lastWreckage", time);
	this.set_u32("lastCapsule", time);
//	this.set_u32("lastnuke", time);
//	this.set_u32("nuketimer", XORRandom(50*30)+10*30);
//	this.set_u32("timetonuke", 1);
//	this.set_bool("timetonukego", false);
//	this.set_bool("stillnuking?", false);
//	this.set_u32("random", XORRandom(80000)+30000);
//	this.set_bool("activated", false);
//	this.set_bool("alwaysnight", false);
//	this.set_bool("cancelnight", false);


//	this.set_u32("nightevent", XORRandom(11));
	this.addCommandID("callputin");
	this.addCommandID("alwaysnightevent");
	this.addCommandID("alwaysnighteventcancel");
//	nightevent in chatcommands
}

void onRestart(CRules@ this)
{
	u32 time = getGameTime();
	this.set_u32("lastMeteor", time);
	this.set_u32("lastWreckage",time);
//	this.set_u32("lastnuke", time);
//	this.set_u32("lastCapsule", time);
//	this.set_u32("nuketimer", XORRandom(50*30)+10*30);
//	this.set_u32("timetonuke", 1);
//	this.set_bool("timetonukego", false);
//	this.set_bool("stillnuking?", false);
//	this.set_u32("random", XORRandom(80000)+30000);
//	this.set_bool("activated", false);
//	this.set_bool("nightcall", false);
//	this.set_bool("alwaysnight", false);
//	this.set_bool("cancelnight", false);
//	
//	this.set_u32("nightevent", XORRandom(11));
}

void onTick(CRules@ this)
{
    if (getGameTime() % 30 == 0)
    {
		CMap@ map = getMap();

		u32 lastMeteor = this.get_u32("lastMeteor");
		u32 lastWreckage = this.get_u32("lastWreckage");
		u32 lastNuke = this.get_u32("lastnuke");
		
		u32 time = getGameTime();
		u32 timeSinceMeteor = time - lastMeteor;
		u32 timeSinceWreckage = time - lastWreckage;
		u32 timeSinceNuke = time - lastNuke;

        if (timeSinceMeteor > 6000 && XORRandom(Maths::Max(35000 - timeSinceMeteor, 0)) == 0) // Meteor strike
        {
			//tcpr("[RGE] Random event: Meteor");
            server_CreateBlob("meteor", -1, Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
			
			this.set_u32("lastMeteor", time);
        }
		
		if (timeSinceWreckage > 30000 && XORRandom(Maths::Max(250000 - timeSinceWreckage, 0)) == 0) // Wreckage 30000 250000
        {
            //tcpr("[RGE] Random event: Wreckage");
			u8 rnd = XORRandom(100);
			string blobname = rnd < 33 ? "ancientcapsule" : rnd < 66 ? "poisonship" : "ancientship";
            server_CreateBlob(blobname, -1, Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
			
			this.set_u32("lastWreckage", time);
    	}

		this.set_bool("activated", false);

		if (this.get_bool("timetonukego"))
		{
			if (this.get_u32("timetonuke") > 0) 
			{
				this.set_u32("timetonuke", this.get_u32("timetonuke") - 1);
			}
			if (this.get_u32("timetonuke") == 0)
			{
				this.set_bool("stillnuking?", true);
				this.set_bool("timetonukego", false);
			}
		}

		if ((this.get_bool("nightcall") && getGameTime() > 20 && getGameTime() <= 30)
		|| (this.get_bool("alwaysnight") && getGameTime() == this.get_u32("alwaysnighttimeactivated")))
		{
			CBitStream params;
			this.SendCommand(getRules().getCommandID("nightevent"), params);
			this.set_bool("nightcall", false);
		}
    }
}