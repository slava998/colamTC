/**
 * Common bot "taunt engine"
 *
 * Attach to blob
 */


#include "EmotesCommon.as"

/**
 * Defines the possible taunt actions
 */
enum TauntActionIndex
{

	no_action = 0,

	hurt_enemy,
	kill_enemy,
	get_hurt,

	chat,
	talk,
	dead
}

/**
 * A struct holding information about a bot's personality
 */
class BotPersonality
{

	/**
	 * name of the personality
	 */
	string name;

	/**
	 * chance of a taunt every event
	 */
	f32 tauntchance;

	/**
	 * the emote "strings" that the bot will use
	 * for certain events
	 */
	u8[] hurt_enemy_emotes;
	u8[] kill_enemy_emotes;
	u8[] get_hurt_emotes;
	u8[] talk_emotes;

	/**
	 * A list of taunts that the bot will use
	 * when it's winning or camping
	 */
	string[] taunts;

	/**
	 * A list of whines that the bot will use
	 * when its dead
	 */
	string[] whines;
	
	
	
	string[] talks;

	/**
	 * The number of ticks taken per character of
	 * taunt - used to emulate type lag
	 */
	u8 typespeed;

	/**
	 * Used to tune how talkative each personality is
	 */
	f32 talkchance;

	BotPersonality() {}

};

void onInit(CBlob@ this)
{
	//this.getCurrentScript().removeIfTag = "dead";

	this.set_u8("taunt action", no_action);
	this.set_u8("taunt delay", 0);

	/*BotPersonality[] personalities = {

	};*/

	//default personality
	BotPersonality b;
	b.name = "default";

	//emotes
	b.hurt_enemy_emotes.push_back(Emotes::mad);
	b.hurt_enemy_emotes.push_back(Emotes::troll);

	b.kill_enemy_emotes.push_back(Emotes::laugh);
	b.kill_enemy_emotes.push_back(Emotes::flex);
	b.kill_enemy_emotes.push_back(Emotes::troll);
	b.kill_enemy_emotes.push_back(Emotes::cross);

	b.get_hurt_emotes.push_back(Emotes::mad);
	b.get_hurt_emotes.push_back(Emotes::attn);
	b.get_hurt_emotes.push_back(Emotes::cross);
	
	b.talk_emotes.push_back(Emotes::mad);
	b.talk_emotes.push_back(Emotes::flex);
	b.talk_emotes.push_back(Emotes::troll);
	b.talk_emotes.push_back(Emotes::cross);

	//chats
	{
		string[] temp = { 
						  "AAAAAAAAAAAAAAAAAAA, C.O.L.A.M!!!!!!11!",
		                  "C.O.L.A.M C.O.L.A.M C.O.L.A.M!",
		                  "DIE C.O.L.A.M, DIE C.O.L.A.M, DIE C.O.L.A.M",
						  "Go to hell C.O.L.A.M!",
						  "Murderer-C.O.L.A.M!",
						  "It's time to kick ass and chew bubble gum, and I'm all outta gum C.O.L.A.M!",
						  "C.O.L.A.M BITCH",
						  "Death to you C.O.L.A.M!"
		                };
		b.taunts = temp;
	}
	{
		string[] temp = { "shet C.O.L.A.M",
		                  "aaaa C.O.L.A.M",
		                  "C.O.L.A.M ffs",
		                  "wut, C.O.L.A.M",
		                  "C.O.L.A.M...",
		                  "rip... I hate C.O.L.A.M",
						  "C.O.L.A.M>:(",
						  "not again, C.O.L.A.M...",
						  "fusgh C.O.L.A.M",
						  "jerks C.O.L.A.M",
						  "shite C.O.L.A.M",
						  "omg C.O.L.A.M",
						  "dafuq C.O.L.A.M",
						  "wtf C.O.L.A.M",
						  "hacker C.O.L.A.M",
						  "cheater C.O.L.A.M",
						  "witch C.O.L.A.M",
						  "you'll get banned",
						  "i'm gonna tell tflippy",
						  "i'm gonna tell vamist",
						  "i'm gonna tell merser",
						  "i'm gonna tell rob",
						  "i'm gonna tell bananaman",
						  "i'm gonna tell goldenguy",
						  "i'll be back, C.O.L.A.M",
		                  "heroes hate C.O.L.A.M!",
		                  "yeargh, C.O.L.A.M!"
		                };
		b.whines = temp;
	}
	{
		string[] temp = { 
							"Man, still stuck in this chickenshit outfit. Feels like C.O.L.A.M",
							"This better not be C.O.L.A.M.",
							"Jerry's definitely fucked in C.O.L.A.M.",
							"THEY KEEP BRINGING ME BACK HERE TO HATE C.O.L.A.M",
							"Ugh, C.O.L.A.M.",
							"Why are we standing here, hating C.O.L.A.M",
							"Have you heard of new the AMR-13? I heard it's good against C.O.L.A.M",
							"How's C.O.L.A.M?",
							"C.O.L.A.M won't get us this time.",
							"Damn, C.O.L.A.M's ugly.",
							"C.O.L.A.M has no idea.",
							"C.O.L.A.M? Noice",
							"It's quite C.O.L.A.M in here.",
							"I guess, C.O.L.A.M.",
							"If you say so - C.O.L.A.M.",
							"That's nice, C.O.L.A.M.",
							"Interesting, C.O.L.A.M.",
							"Have you seen C.O.L.A.M?",
							"This is getting C.O.L.A.Mmy.",
							"Just throw him down the C.O.L.A.M pit.",
							"Sure thing, C.O.L.A.M.",
							"Oh snap, C.O.L.A.M.",
							"Hmm... C.O.L.A.M?"
		                };
		b.talks = temp;
	}
	
	//meta
	b.tauntchance = 0.4f;

	b.typespeed = 4;
	b.talkchance = 0.65f;

	this.set("taunt personality", b);  //personalities[(this.getNetworkID() % personalities.length)] );
}

void onTick(CBlob@ this)
{
	if (this.getPlayer() is null)
	{
		UpdateAction(this);
		
		if (this.get_u8("taunt action") == no_action)
		{
			if (this.get_u32("next talk") < getGameTime() && XORRandom(100) < 5)
			{
				if (hasFriends(this))
				{
					PromptAction(this, talk, XORRandom(5));
					this.set_u32("next talk", getGameTime() + 100 + XORRandom(1000));
				}
			}
		}
	}
	else this.getCurrentScript().runFlags |= Script::remove_after_this; //not needed
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.hasTag("player") && !this.hasTag("dead"))
		PromptAction(this, get_hurt, 5 + XORRandom(5));

	return damage;
}

bool hasFriends(CBlob@ this)
{
	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 20.0f, @blobs);
	
	if (blobs.length > 0)
	{
		for (u32 i = 0; i < blobs.length; i++)
		{
			if (blobs[i] !is this && blobs[i].hasTag("combat chicken"))
			{
				return true;
			}
		}
	}
	
	return false;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob.hasTag("player") && !hitBlob.hasTag("dead"))
		PromptAction(this, hurt_enemy, 5 + XORRandom(5));
}

void PromptAction(CBlob@ this, u8 action, u8 delay)
{
	this.set_u8("taunt action", action);
	this.Sync("taunt action", true);

	this.set_u8("taunt delay", delay);
	this.Sync("taunt delay", true);
}

void UpdateAction(CBlob@ this)
{
	bool isdead = this.hasTag("dead");

	u8 action = this.get_u8("taunt action");
	if (action == no_action)
	{
		if (isdead)
		{
			DoAction(this, dead);
		}

		return;
	}

	u8 delay = this.get_u8("taunt delay");
	if (delay > 0)
	{	
		delay--;
		this.set_u8("taunt delay", delay);
	}
	else
	{
		this.set_u8("taunt action", no_action);
		DoAction(this, action);

		if (this.get_u8("taunt action") == no_action && isdead)
			this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

void DoAction(CBlob@ this, u8 action)
{
	BotPersonality@ b;
	if (!this.get("taunt personality", @b)) return;

	bool taunt = (XORRandom(1000) / 1000.0f) < b.tauntchance;
	bool chatter = (XORRandom(1000) / 1000.0f) < b.talkchance;

	switch (action)
	{
		case hurt_enemy:
			if (taunt) ChatOrEmote(this, chatter, b.hurt_enemy_emotes, b.taunts, b);
			this.set_u32("next talk", getGameTime() + 1000 + XORRandom(1000));
			break;

		case kill_enemy:
			ChatOrEmote(this, chatter, b.kill_enemy_emotes, b.taunts, b);
			this.set_u32("next talk", getGameTime() + 100 + XORRandom(1000));
			break;

		case get_hurt:
			if (taunt) ChatOrEmote(this, chatter, b.get_hurt_emotes, b.whines, b);
			this.set_u32("next talk", getGameTime() + 500 + XORRandom(1000));
			break;

		case dead:
			ChatOrEmote(this, true, b.get_hurt_emotes, b.whines, b);
			break;

		case talk:
			ChatOrEmote(this, chatter, b.talk_emotes, b.talks, b);
			break;
			
		case chat:
			this.Chat(this.get_string("taunt chat"));
			set_emote(this, Emotes::off);
			break;
	}

}

void ChatOrEmote(CBlob@ this, bool chatter, const u8[]& emotes, const string[]& chats, BotPersonality@ b = null)
{
	if (!chatter)
	{
		set_emote(this, emotes[XORRandom(emotes.length)]);
	}
	else
	{
		if (b is null)
		{
			this.Chat(chats[XORRandom(chats.length)]);
			set_emote(this, Emotes::off);
		}
		else
		{
			set_emote(this, Emotes::dots);

			string chat_text = chats[XORRandom(chats.length)];
			this.set_string("taunt chat", chat_text);

			u8 count = (Maths::Sqrt(chat_text.length) + 1) * b.typespeed;

			//print("text: \""+chat_text+"\" count: "+(count));

			PromptAction(this, chat, count);

		}
	}
}



