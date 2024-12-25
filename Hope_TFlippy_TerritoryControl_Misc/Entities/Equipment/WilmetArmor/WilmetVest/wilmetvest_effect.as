void onTick(CBlob@ this)
{
    if (this.get_string("reload_script") == "wilmetvest")
		this.set_string("reload_script", "");
	
	//print("hp: "+this.get_f32("bpv_health"));
	
	if (this.get_f32("wilmetvest_health") >= 146.0f)
	{
		this.getSprite().PlaySound("ricochet_" + XORRandom(3));
		this.set_string("equipment_torso", "");
		this.set_f32("wilmetvest_health", 145.9f);
		this.RemoveScript("wilmetvest_effect.as");
	}
	// print("torso: "+this.get_f32("bpv_health"));
}
//all stuff for damage located in FleshHit.as