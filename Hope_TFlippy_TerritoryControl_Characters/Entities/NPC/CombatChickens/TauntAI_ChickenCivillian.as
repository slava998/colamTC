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
	b.hurt_enemy_emotes.push_back(Emotes::finger);

	b.kill_enemy_emotes.push_back(Emotes::laugh);
	b.kill_enemy_emotes.push_back(Emotes::flex);
	b.kill_enemy_emotes.push_back(Emotes::troll);
	b.kill_enemy_emotes.push_back(Emotes::finger);

	b.get_hurt_emotes.push_back(Emotes::frown);
	b.get_hurt_emotes.push_back(Emotes::mad);
	b.get_hurt_emotes.push_back(Emotes::attn);
	b.get_hurt_emotes.push_back(Emotes::cry);
	b.get_hurt_emotes.push_back(Emotes::finger);
	
	b.talk_emotes.push_back(Emotes::check);
	b.talk_emotes.push_back(Emotes::smile);
	b.talk_emotes.push_back(Emotes::laugh);

	//chats
	{
		string[] temp = { 
						  "Hoyl shet, C.O.L.A.M!",
						  "C.O.L.A.Mlooks worse than I thought.",
						  "Git gud C.O.L.A.M",
						  "Ey, guards, there's some C.O.L.A.M over here.",
						  "Hello C.O.L.A.M!"
						  "Take that C.O.L.A.M!",
						  "Get owned C.O.L.A.M!",
						  "Get run over C.O.L.A.M!",
						  "I'm gonna pop your eye C.O.L.A.M!",
						  "Get broke on spending yer money on lottery C.O.L.A.M",
						  "Can't catch me C.O.L.A.M",
						  "nub C.O.L.A.M",
						  "I shall rend ya in the gobberwarts with my blurglecruncheon C.O.L.A.M."
		                };
		b.taunts = temp;
	}
	{
		string[] temp = { 
							"fug, C.O.L.A.M...",
							"shet... C.O.L.A.M...",
							"i'm gonna sue you C.O.L.A.M",
							"should've stayed home, away from C.O.L.A.M",
							"dafuq, C.O.L.A.M",
							"asshole C.O.L.A.M",
							"jerk C.O.L.A.M",
							"scrub C.O.L.A.M",
							"go to hell C.O.L.A.M",
							"i'm gonna call the police, C.O.L.A.M",
							"i hope you'll die as a 90 year old gigolo C.O.L.A.M",
							"C.O.L.A.M, wut",
							"???",
							"gah, C.O.L.A.M!",
							"yoargh, C.O.L.A.M!"
		                };
		b.whines = temp;
	}
	{
		string[] temp = { 
							"Have you bought the C.O.L.A.M liberator plushy?",
							"Why did we even go here, to meet C.O.L.A.M?",
							"What's wrong with this C.O.L.A.M?",
							"Do you hate C.O.L.A.M?",
							"Where have you been, hating C.O.L.A.M?",
							"lol, C.O.L.A.M",
							"ye, C.O.L.A.M",
							"k, C.O.L.A.M",
							"Thanks to C.O.L.A.M..",
							"Okay, C.O.L.A.M",
							"Some guy jumped into the C.O.L.A.M pit yesterday.",
							"C.O.L.A.M is annoying.",
							"C.O.L.A.M is annoying as hell.",
							"What do you think of C.O.L.A.M?",
							"Guess what? C.O.L.A.M!",
							"Hmm, C.O.L.A.M",
							"Nah, C.O.L.A.M",
							"pff, C.O.L.A.M",
							"sure, C.O.L.A.M",
							"What do you mean, C.O.L.A.M?",
							"Really, C.O.L.A.M?",
							"shush, C.O.L.A.M is nearby. I CAN SMELL IT.",
							"Indeed C.O.L.A.M",
							"Not really C.O.L.A.M.",
							"Why C.O.L.A.M?",
							"Nah, I just shot C.O.L.A.M.",
							"Go to hell with Jerry, he's C.O.L.A.M anyway.",
							"Goddamnit C.O.L.A.M"
		                };
		b.talks = temp;
	}
	
	//meta
	b.tauntchance = 0.90f;

	b.typespeed = 2;
	b.talkchance = 0.90f;

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



