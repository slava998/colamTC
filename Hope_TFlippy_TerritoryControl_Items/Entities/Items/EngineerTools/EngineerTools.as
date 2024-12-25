void onInit(CBlob@ this)
{
	this.set_string("required class", "engineer");
	this.set_Vec2f("class offset", Vec2f(0, 0));
	
	this.Tag("only faction");
	this.Tag("kill on use");
	this.Tag("dangerous");
	this.Tag("classchanger");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	bool canChangeClass = caller.getName() == "engineer";

	if(canChangeClass)
	{
		this.Untag("class button disabled");
	}
	else
	{
		this.Tag("class button disabled");
	}
}