// TrapBlock.as

#include "Hitters.as";
#include "MapFlags.as";
#include "MinableMatsCommon.as";

int openRecursion = 0;

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(10);

	this.getShape().SetRotationsAllowed(false);
	this.getShape().AddPlatformDirection(Vec2f(0, -1), 45, false);
	this.set_bool("open", false);
	this.Tag("place norotate");

	//block knight sword
	this.Tag("blocks sword");
	this.Tag("blocks water");

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.Tag("ignore extractor");
	this.Tag("builder always hit");
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.getConsts().accurateLighting = true;

	if (!isStatic) return;

	this.getSprite().PlaySound("/build_door.ogg");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !(this.hasBlob(blob.getName(), 0) || this.hasBlob(blob.getName(), 1));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.hasTag("player")) return;
	if (blob.getPosition().y > this.getPosition().y) return;
	
	blob.setVelocity(Vec2f(this.isFacingLeft() ? -0 : 0, -9));
	
	if(isClient()) this.getSprite().PlaySound("/launcher_boing" + XORRandom(2) + ".ogg", 0.5f, 0.9f);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}