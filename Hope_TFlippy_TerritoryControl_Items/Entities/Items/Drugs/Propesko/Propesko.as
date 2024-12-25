void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.addCommandID("consume");
	this.Tag("hopperable");
	this.Tag("dartguninjectable");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	if (getGameTime() <= this.get_u32("button_delay")) return;
	this.set_u32("button_delay", getGameTime()+5);

	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("consume"), "Smoke!", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("consume"))
	{
		if (getGameTime() < this.get_u32("consume_delay")) return;
		this.set_u32("consume_delay", getGameTime()+2);
		// this.getSprite().PlaySound("Huuu.ogg", 1.0f, 1.5f);
		this.getSprite().PlaySound("drunk_fx3.ogg", 2.00f, 0.75f);

		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if (caller !is null)
		{
			if (!caller.hasScript("Propeskoed.as")) caller.AddScript("Propeskoed.as");
			caller.add_f32("propeskoed", 1);
			caller.add_f32("propeskorate", 0.001);
			
			if (isServer())
			{
				this.server_Die();
			}
		}
	}
}
