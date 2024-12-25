﻿#include "MakeMat.as";
#include "FilteringCommon.as";

void onInit(CSprite@ this)
{
	this.SetZ(-50);

	// this.RemoveSpriteLayer("gear");
	// CSpriteLayer@ gear = this.addSpriteLayer("gear", "Inserter.png", 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());

	// if (gear !is null)
	// {
		// Animation@ anim = gear.addAnimation("default", 0, false);
		// anim.AddFrame(1);
		// gear.SetOffset(Vec2f(0.0f, 2.0f));
		// gear.SetAnimation("default");
		// gear.SetRelativeZ(-60);
	// }
}

// void onTick(CSprite@ this)
// {
	// if(this.getSpriteLayer("gear") !is null){
		// this.getSpriteLayer("gear").RotateBy(-15, Vec2f(0.0f, 0.0f));
	// }
// }

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > 96.0f) return;
	if(caller.getCarriedBlob() !is this){
		CBitStream params;
		params.write_u16(caller.getNetworkID());

		int icon = !this.isFacingLeft() ? 18 : 17;

		CButton@ button = caller.CreateGenericButton(icon, Vec2f(0, -8), this, this.getCommandID("use"), "Use", params);
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	if (cmd == this.getCommandID("use"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;
		CBlob@ caller = getBlobByNetworkID(id);
		if (caller !is null)
		{
			this.SetFacingLeft(!this.isFacingLeft());
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this);
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.getShape().getConsts().mapCollisions = false;
	this.getCurrentScript().tickFrequency = 30;

	this.Tag("ignore extractor");
	this.Tag("builder always hit");
	this.addCommandID("use");

	this.inventoryButtonPos = Vec2f(16, 0);
}

void onTick(CBlob@ this)
{
	const f32 sign = this.isFacingLeft() ? -1 : 1;
	CInventory@ t_inv = this.getInventory();
	CMap@ map = getMap();
	
	//push item out of inserter
	if(t_inv.getItemsCount() > 0)
	{
		CBlob@ left = map.getBlobAtPosition(this.getPosition() + Vec2f(-12 * sign, 0));
		if (left !is null)
		{
			CBlob@ item = t_inv.getItem(0);
			if (item !is null)
			{
				if (!left.hasTag("player") && item.canBePutInInventory(left) &&
				left.getInventory() !is null && !left.getInventory().isFull()) 
				{
					left.server_PutInInventory(item);
					this.getSprite().PlaySound("bridge_close.ogg", 1.00f, 1.00f);
				}
			}
			
		}
	}
	//pull item into inserter
	else
	{
		CBlob@ right = map.getBlobAtPosition(this.getPosition() + Vec2f(12 * sign, 0));
		if (right !is null && !right.hasTag("ignore inserter") && !right.hasTag("player"))
		{
			CInventory@ inv = right.getInventory();

			if (inv !is null)
			{
				if(this.hasTag("whitelist"))
				{
					string[]@ filter;
					if(this.get("filtered_items", @filter)){
					
						for(int i = 0;i < filter.length();i++){
						
							CBlob@ item = inv.getItem(filter[i]);
							if (item !is null)
							{
								this.server_PutInInventory(item);
								this.getSprite().PlaySound("bridge_open.ogg", 1.00f, 1.00f);
								break;
							}
						}
					
					}
					
				}
				else
				{	
					for (int i = 0; i < inv.getItemsCount(); i++)
					{
						CBlob@ item = inv.getItem(i);
						if (server_isItemAccepted(this, item.getName()) && item.canBePutInInventory(this))
						{
							this.server_PutInInventory(item);
							this.getSprite().PlaySound("bridge_open.ogg", 1.00f, 1.00f);
							break;
						}
					}
				}
			
			}
		}
	}

}
