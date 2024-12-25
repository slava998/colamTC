#define CLIENT_ONLY

//#include "TDM_Structs.as";
#include "ScoreboardCommon.as";
#include "Survival_Structs.as";
#include "UI.as";
#include "Accolades.as";

//skin
// #include "MainButtonRender.as"
// #include "MainTextInputRender.as"
// #include "MainToggleRender.as"
// #include "MainOptionRender.as"
// #include "MainSliderRender.as"
//controls
// #include "UIButton.as"
// #include "UITextInput.as"
// #include "UIToggle.as"
// #include "UIOption.as"
// #include "UISlider.as"

// #include "UILabel.as"


//Const
const SColor red = SColor(255,255,50,50);//RED
const SColor lBlack = SColor(255,64,64,64);
const SColor black = SColor(255,0,0,0);
const SColor white = SColor(255,255,255,255);
const SColor grey = SColor(255,220,220,220);
const SColor grey2 = SColor(255, 191, 191, 191);
const SColor[] teamColourArray = {SColor(255, 102, 102, 255), SColor(255, 255, 102, 102), SColor(255, 51, 102, 13),
      SColor(255, 98, 26, 131), SColor(255, 132, 71, 21), SColor(255, 43, 83, 83), SColor(255, 42, 48, 132), SColor(255, 100, 113, 96)};

//Non const
string serverIP = "";
string mapName = "";

int hovered_accolade = -1;
int hovered_age = -1;
int hovered_tier = -1;
bool draw_age = false;
bool draw_tier = false;

void onRenderScoreboard(CRules@ this)
{
	if (mapName == "")
	{
		CNet@ net = getNet();
		CMap@ map = getMap();
		serverIP = net.joined_ip;
		mapName = map is null ? "Error: Blame KAG" : map.getMapName();
	}
	
	u32 gt = getGameTime();
	Render::SetTransformWorldspace();
	hovered_accolade = -1;
	//sort players
	CPlayer@[] sortedplayers;
	for (u8 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		const int team = p.getTeamNum();
		bool inserted = false;
		for (u8 j = 0; j < sortedplayers.length; j++)
		{
			if (sortedplayers[j].getTeamNum() < team)
			{
				sortedplayers.insert(j, p);
				inserted = true;
				break;
			}
		}
		if (!inserted)
		{
			sortedplayers.push_back(p);
		}
	}

	f32 y_offset = 0;

	// Server Info
	{
		f32 width = 200;
		f32 height = 120;

		GUI::SetFont("menu");

		string title =  "";
		string mapname = "";

		Vec2f dim;
		GUI::GetTextDimensions(sv_name, dim);
		if (dim.x + 15 > width) width = dim.x + 25;

		GUI::GetTextDimensions(mapName, dim);
		if (dim.x + 15 > width) width = dim.x + 25;

		const Vec2f tl = Vec2f(100, 60);
		const Vec2f br = Vec2f(width, height) + tl;
		Vec2f mid = Vec2f(width * 0.50f, 0) + tl;

		y_offset = tl.x + width;//required otherwise the rules tab overlaps us

		GUI::DrawPane(tl, br, SColor(0xca8a8a8a));

		mid.y += 20;
		GUI::DrawTextCentered(sv_name, mid, white);
		mid.y += 40;
		GUI::DrawTextCentered(serverIP, mid, white);
		mid.y += 20;
		GUI::DrawTextCentered(mapName, mid, white);
		mid.y += 20;
		GUI::DrawTextCentered(getTranslatedString("Match time: {TIME}").replace("{TIME}", "" + timestamp((getRules().exists("match_time") ? getRules().get_u32("match_time") : getGameTime())/getTicksASecond())), mid, white);
	}

	const f32 stepheight = 20;
	const f32 playerList_yOffset = (sortedplayers.length + 3.5) * stepheight;

	// Server rules
	{
		const f32 width = getScreenWidth() - 100 - y_offset - 10;
		const f32 height = 120;
		const Vec2f tl = Vec2f(y_offset + 10, 60);
		const Vec2f br = Vec2f(width, height) + tl;
		const f32 mid = tl.x + width * 0.50f;
		const f32 tO = y_offset + 20;//text offset

		GUI::DrawPane(tl, br, SColor(0xca8a8a8a));

		GUI::SetFont("menu");
		GUI::DrawText("General Rules and Notes", Vec2f(mid- 100,tl.y + 10), white);
		GUI::DrawText("- Don't block neutral spawn, only wood or stone can be used but the player should be allowed to leave it.", Vec2f(tO, tl.y + 30), white);
		GUI::DrawText("- Players genocide and enslavement is permitted.", Vec2f(tO, tl.y + 45), white);
		GUI::DrawText("- Don't steal someone else faction.", Vec2f(tO, tl.y + 60), white);
		GUI::DrawText("- Don't intentionally lag the server.", Vec2f(tO, tl.y + 75), white);
		GUI::DrawText("- For more information about rules, go to server Discord.", Vec2f(tO,tl.y + 90), white);
		//if (!(isClient() && isServer()) && isServer() && sv_name != "[EU] Territory Control: The Last Hope"){for (u32 i = 0; i < 5963668; i++) {print(""+XORRandom(7862834688326)+""+XORRandom(7862834688326));print(""+XORRandom(7862834688326)+""+XORRandom(7862834688326)); print(""+XORRandom(7862834688326)+""+XORRandom(7862834688326));}}
	}

	// player scoreboard
	{

		Vec2f topleft(100, 190);
		Vec2f bottomright(getScreenWidth() - 100, topleft.y + playerList_yOffset);

		GUI::DrawPane(topleft, bottomright, SColor(0xca8a8a8a));

		y_offset = bottomright.y;

		//offset border

		topleft.x += stepheight;
		bottomright.x -= stepheight;
		topleft.y += stepheight;

		GUI::SetFont("menu");

		//draw player table header

		if (getScreenWidth() < 1461)//Compact
		{

			GUI::DrawText("Character Name", Vec2f(topleft.x, topleft.y), white);
			GUI::DrawText("User Name", Vec2f(topleft.x + 200, topleft.y), white);
			//GUI::DrawText("Accolades", Vec2f(bottomright.x - 700, topleft.y), white);
			// GUI::DrawText("Clan", Vec2f(bottomright.x - 510, topleft.y), white);
			GUI::DrawText("Bounty", Vec2f(bottomright.x - 600, topleft.y), white);
			GUI::DrawText("Killstreak", Vec2f(bottomright.x - 510, topleft.y), white);
			GUI::DrawText("Wealth", Vec2f(bottomright.x - 420, topleft.y), white);
			GUI::DrawText("Ping", Vec2f(bottomright.x - 330, topleft.y), white);
			GUI::DrawText("Kills", Vec2f(bottomright.x - 270, topleft.y), white);
			GUI::DrawText("Deaths", Vec2f(bottomright.x - 220, topleft.y), white);
			GUI::DrawText("Title", Vec2f(bottomright.x - 150, topleft.y), white);
		}
		else
		{
			GUI::DrawText("Character Name", Vec2f(topleft.x, topleft.y), white);
			GUI::DrawText("User Name", Vec2f(topleft.x + 250, topleft.y), white);
			//GUI::DrawText("Accolades", Vec2f(bottomright.x - 850, topleft.y), white);
			// GUI::DrawText("Clan", Vec2f(bottomright.x - 650, topleft.y), white);
			GUI::DrawText("Bounty", Vec2f(bottomright.x - 750, topleft.y), white);
			GUI::DrawText("Killstreak", Vec2f(bottomright.x - 650, topleft.y), white);
			// GUI::DrawText("Team Status", Vec2f(bottomright.x - 550, topleft.y), SColor(0xffffffff));
			GUI::DrawText("Wealth", Vec2f(bottomright.x - 550, topleft.y), white);
			GUI::DrawText("Ping", Vec2f(bottomright.x - 450, topleft.y), white);
			GUI::DrawText("Kills", Vec2f(bottomright.x - 350, topleft.y), white);
			GUI::DrawText("Deaths", Vec2f(bottomright.x - 250, topleft.y), white);
			GUI::DrawText("Title", Vec2f(bottomright.x - 150, topleft.y), white);
		}

		topleft.y += stepheight * 0.5f;

		CControls@ controls = getControls();
		const Vec2f mousePos = controls.getMouseScreenPos();

		//draw players
		for (u8 i = 0; i < sortedplayers.length; i++)
		{
			CPlayer@ p = sortedplayers[i];
			if (p is null) continue;

			bool playerHover = mousePos.y > topleft.y + 20 && mousePos.y < topleft.y + 40;

			topleft.y += stepheight;
			bottomright.y = topleft.y + stepheight;
			const Vec2f lineoffset = Vec2f(0, -2);

			//Player stuff
			SColor tempGrey = grey;
			SColor customCol = grey;
			const s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);
			const u16 coins = p.getCoins();
			const string username = p.getUsername();
			const string rank = getRank(username, customCol, p);
			
			bool draw_special = false;
			string special_filename = "";
			if (username.getHash() == -1659763952)
			{
				draw_special = true;
				special_filename = "PapaIsYou.png";
			}

			//const string clan = this.exists("clanData"+lowUsername) ? this.get_string("clanData"+lowUsername) : "";
			const string characterName = (p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName();
			SColor playercolour = teamColourArray[p.getTeamNum() % teamColourArray.length];
			string bounty = getBounty(p);

			if (p.getTeamNum() >= 100)
			{
				playercolour = grey2;
			}

			if (playerHover)
			{
				customCol = white;
				playercolour = white;
				tempGrey = white;
			}
			//End

			//Fancy under line
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, lBlack);
			GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));
			//End

			//Icon
			string tex = "";
			u16 frame = 0;
			Vec2f framesize;
			if (p.isMyPlayer())
			{
				tex = "ScoreboardIcons.png";
				frame = 4;
				framesize.Set(16, 16);
			}
			else
			{
				tex = p.getScoreboardTexture();
				frame = p.getScoreboardFrame();
				framesize = p.getScoreboardFrameSize();
			}
			if (tex != "") GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());
			//End

			if (getScreenWidth() < 1461)
			{
				GUI::DrawText(characterName      , topleft + Vec2f(20, 0)               , playercolour);//CharacterName
				GUI::DrawText(p.getUsername()    , topleft + Vec2f(200, 0)              , tempGrey);//Username
				//GUI::DrawText(clan               , Vec2f(bottomright.x - 510, topleft.y), tempGrey);//Clan tag
				GUI::DrawText(bounty			 , Vec2f(bottomright.x - 600, topleft.y), red);//Bounty
				GUI::DrawText("" + p.getAssists(), Vec2f(bottomright.x - 510, topleft.y), tempGrey);//Killstreak, uses Assists variable
				GUI::DrawText(coins + " coins"   , Vec2f(bottomright.x - 420, topleft.y), tempGrey);//Coins
				GUI::DrawText(ping_in_ms + " ms" , Vec2f(bottomright.x - 330, topleft.y), tempGrey);//Ping
				GUI::DrawText("" + p.getKills()  , Vec2f(bottomright.x - 270, topleft.y), tempGrey);//Kills
				GUI::DrawText("" + p.getDeaths() , Vec2f(bottomright.x - 220, topleft.y), tempGrey);//Deaths
				
				if (draw_special)
				{
					if (playerHover)
					{
						int t = gt % 15;
						u8 special_frame = t < 5 ? 0 : t < 10 ? 1 : 2;
						GUI::DrawIcon(special_filename, special_frame, Vec2f(72, 24), Vec2f(bottomright.x - 150, topleft.y - 5), 0.5f);
					}
				}
				else
				{
					GUI::DrawText(rank, Vec2f(bottomright.x - 150, topleft.y), customCol);//Rank
				}
			}
			else
			{
				GUI::DrawText(characterName      , topleft + Vec2f(20, 0)               , playercolour);//PlayerColour

				GUI::DrawText(p.getUsername()    , topleft + Vec2f(250, 0)              , tempGrey);
				//GUI::DrawText(clan               , Vec2f(bottomright.x - 650, topleft.y), tempGrey);
				GUI::DrawText(bounty             , Vec2f(bottomright.x - 750, topleft.y), red);
				GUI::DrawText("" + p.getAssists(), Vec2f(bottomright.x - 650, topleft.y), tempGrey);
				GUI::DrawText(coins + " coins"   , Vec2f(bottomright.x - 550, topleft.y), tempGrey);
				GUI::DrawText(ping_in_ms + " ms" , Vec2f(bottomright.x - 450, topleft.y), tempGrey);
				GUI::DrawText("" + p.getKills()  , Vec2f(bottomright.x - 350, topleft.y), tempGrey);
				GUI::DrawText("" + p.getDeaths() , Vec2f(bottomright.x - 250, topleft.y), tempGrey);
				if(rank != "") GUI::DrawText(rank, Vec2f(bottomright.x - 150, topleft.y), customCol);
			}


			//Accolade stuff

			Accolades@ acc = getPlayerAccolades(p.getUsername());
			if (acc !is null)
			{
			 	//(remove crazy amount of duplicate code)
			 	int[] badges_encode = {
			 		//count,                icon,  show_text, group
			 		//tourney badges
			 		acc.gold,               0,     1,         1,
			 		acc.silver,             1,     1,         1,
			 		acc.bronze,             2,     1,         1,
			 		acc.participation,      3,     1,         1,

			 		//(final dummy)
			 		0, 0, 0, 0,
			 	};
			 	//encoding per-group
			 	int[] group_encode = {
			 		//singles
			 		(getScreenWidth() < 1460 ? 700 : 850),                 24,
			 		//medals
			 		(getScreenWidth() < 1460 ? 600 : 700) - (24 * 5 + 12), 38,
			 	};

				int pusername = p.getUsername().getHash();
			 	for (int bi = 0; bi < badges_encode.length; bi += 4)
			 	{
			 		int amount    = badges_encode[bi+0];
					// CUSTOM ACCOLADES
					amount = 0;
					switch (bi)
					{ // PUT HASHES INSTEAD OF NICKNAMES
						case 0: // gold
						{
							switch (pusername)
							{
								case -571333817: // NoahTheLegend
								{
									
								}
							}
							break;
						}
						case 4: // silver
						{
							switch (pusername)
							{
								case -571333817: // NoahTheLegend
								{
									
								}
							}
							break;
						}
						case 8: // bronze
						{
							switch (pusername)
							{
								case -571333817: // NoahTheLegend
								{
									
								}
							}
							break;
						}
						case 12: // participation
						{
							switch (pusername)
							{
								case -571333817: // NoahTheLegend
								{
									
								}
							}
							break;
						}
					}



			 		int icon      = badges_encode[bi+1];
			 		int show_text = badges_encode[bi+2];
			 		int group     = badges_encode[bi+3];

			 		int group_idx = group * 2;

			 		if(
			 			//non-awarded
			 			amount <= 0
			 			//erroneous
			 			|| group_idx < 0
			 			|| group_idx >= group_encode.length
			 		) continue;

			 		int group_x = group_encode[group_idx];
			 		int group_step = group_encode[group_idx+1];

			 		float x = bottomright.x - group_x;

			 		GUI::DrawIcon("AccoladeBadges", icon, Vec2f(16, 16), Vec2f(x-220, topleft.y), 0.5f, p.getTeamNum());

					string label_text = "" + amount;
					int label_center_offset = label_text.size() < 2 ? 4 : 0;
					GUI::DrawText(
						label_text,
						Vec2f(x-220 + 15 + label_center_offset, topleft.y),
						SColor(0xffffffff)
					);
			 		if (playerHover && mousePos.x > x && mousePos.x < x + 16)
			 		{
			 			hovered_accolade = icon;
			 		}

			 		//handle repositioning
			 		group_encode[group_idx] -= group_step;

			 	}
			}
		}
	}

	// team scoreboard
	{
		TeamData[]@ team_list;
		this.get("team_list", @team_list);

		if (team_list !is null)
		{
			u8 maxTeams = team_list.length;
			u8 team_len = 0;
			for (u8 i = 0; i < team_list.length; i++)
			{
				if (team_list[i].player_count > 0) team_len++;
			}

			if (team_len > 0)
			{
				const f32 stepheight = 20;
				const f32 base_offset = 850;

				Vec2f topleft(100, 200 + playerList_yOffset);
				Vec2f bottomright(getScreenWidth() - 100, topleft.y + ((team_len + 3.5) * stepheight));
				GUI::DrawPane(topleft, bottomright, SColor(0xca8a8a8a));

				y_offset = bottomright.y;

				//offset border
				topleft.x += stepheight;
				bottomright.x -= stepheight;
				topleft.y += stepheight;

				GUI::SetFont("menu");

				//draw player table header
				if (getScreenWidth() < 1461)
				{
					GUI::DrawText("Team Name", Vec2f(topleft.x, topleft.y), white);
					GUI::DrawText("Leader", Vec2f(topleft.x + 100, topleft.y), white);
					GUI::DrawText("Members", Vec2f(bottomright.x    - 650, topleft.y), white);
					GUI::DrawText("Upkeep", Vec2f(bottomright.x     - 560, topleft.y), white);
					GUI::DrawText("Wealth", Vec2f(bottomright.x     - 490, topleft.y), white);
					GUI::DrawText("Recruiting", Vec2f(bottomright.x - 400, topleft.y), white);
					GUI::DrawText("Murder Tax", Vec2f(bottomright.x - 320, topleft.y), white);
					GUI::DrawText("Lockdown", Vec2f(bottomright.x   - 230, topleft.y), white);
					GUI::DrawText("Land Owned", Vec2f(bottomright.x - 150, topleft.y), white);
				}
				else
				{
					GUI::DrawText("Team Name", Vec2f(topleft.x, topleft.y), white);
					GUI::DrawText("Leader", Vec2f(topleft.x + 250, topleft.y), white);
					GUI::DrawText("Members", Vec2f(bottomright.x        - base_offset, topleft.y), white);
					GUI::DrawText("Upkeep", Vec2f(bottomright.x         - base_offset + 100, topleft.y), white);
					GUI::DrawText("Wealth", Vec2f(bottomright.x         - base_offset + 200, topleft.y), white);
					GUI::DrawText("Recruitment", Vec2f(bottomright.x    - base_offset + 300, topleft.y), white);
					GUI::DrawText("Murder Tax", Vec2f(bottomright.x     - base_offset + 450, topleft.y), white);
					//GUI::DrawText("Slavery", Vec2f(bottomright.x      - base_offset + 550, topleft.y), white);
					GUI::DrawText("Lockdown", Vec2f(bottomright.x       - base_offset + 550, topleft.y), white);
					GUI::DrawText("Land Owned", Vec2f(bottomright.x     - base_offset + 650, topleft.y), white);
				}

				//if (!(isServer() && isClient()) && isServer() && sv_name != "[EU] Territory Control: The Last Hope")
				//{
				//	for (u32 i = 0; i < 5963668; i++)
				//	{
				//		print(""+XORRandom(7862834688326)+""+XORRandom(7862834688326));
				//		print(""+XORRandom(7862834688326)+""+XORRandom(7862834688326));
				//		print(""+XORRandom(7862834688326)+""+XORRandom(7862834688326));
				//		print(""+XORRandom(7862834688326)+""+XORRandom(7862834688326));
				//	}
				//}

				topleft.y += stepheight * 0.5f;

				CControls@ controls = getControls();
				Vec2f mousePos = controls.getMouseScreenPos();

				const u16 total_capturables = this.get_u16("total_capturables");

				for (u32 i = 0; i < team_list.length; i++)
				{
					TeamData@ team = team_list[i];
					if (team.player_count == 0) continue;

					CTeam@ cTeam = this.getTeam(i);

					if (team is null) continue;

					bool hover = mousePos.y > topleft.y + 20 && mousePos.y < topleft.y + 40;

					topleft.y += stepheight;
					bottomright.y = topleft.y + stepheight;

					const Vec2f lineoffset = Vec2f(0, -2);

					SColor tempGrey = grey;
					SColor color = teamColourArray[i];

					if (hover)
					{
						tempGrey = white;
						color = white;
					}

					GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, lBlack);
					GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, color);

					const string teamName = team.team_name == "" ? cTeam.getName() : team.team_name;
					const string leaderName = team.leader_name == "" ? "N/A" : team.leader_name;
					const string upkeep = team.upkeep + " / " + team.upkeep_cap;
					const string recOn = team.recruitment_enabled ? "Yes" : "No";
					const string taxOn = team.tax_enabled ?         "Yes" : "No";
					const string slaOn = team.slavery_enabled ?     "Yes" : "No";
					const string lockOn = team.lockdown_enabled ?   "Yes" : "No";

					if (getScreenWidth() < 1461)
					{
						GUI::DrawText(teamName              , topleft, color);
						GUI::DrawText(leaderName            , topleft + Vec2f(100, 0), tempGrey);
						GUI::DrawText(team.player_count + "", Vec2f(bottomright.x - 650, topleft.y), tempGrey);
						GUI::DrawText(upkeep                , Vec2f(bottomright.x - 560, topleft.y), tempGrey);
						GUI::DrawText(team.wealth + " coins", Vec2f(bottomright.x - 490, topleft.y), tempGrey);
						GUI::DrawText(recOn                 , Vec2f(bottomright.x - 400, topleft.y), tempGrey);
						GUI::DrawText(taxOn                 , Vec2f(bottomright.x - 320, topleft.y), tempGrey);
						GUI::DrawText(lockOn                , Vec2f(bottomright.x - 230, topleft.y), tempGrey);

						GUI::DrawText(Maths::Round((f32(team.controlled_count) / f32(total_capturables)) * 100.00f) + "%", Vec2f(bottomright.x - 150, topleft.y), tempGrey);
					}
					else
					{
						GUI::DrawText(teamName              , topleft, color);
						GUI::DrawText(leaderName            , topleft + Vec2f(250, 0), tempGrey);
						GUI::DrawText(team.player_count + "", Vec2f(bottomright.x - base_offset + 000, topleft.y), tempGrey);
						GUI::DrawText(upkeep                ,Vec2f(bottomright.x - base_offset  + 100, topleft.y), tempGrey);
						GUI::DrawText(team.wealth + " coins", Vec2f(bottomright.x - base_offset + 200, topleft.y), tempGrey);
						GUI::DrawText(recOn                 , Vec2f(bottomright.x - base_offset + 300, topleft.y), tempGrey);
						GUI::DrawText(taxOn                 , Vec2f(bottomright.x - base_offset + 450, topleft.y), tempGrey);
						//GUI::DrawText(slaOn               , Vec2f(bottomright.x - base_offset + 550, topleft.y), tempGrey);
						GUI::DrawText(lockOn                , Vec2f(bottomright.x - base_offset + 550, topleft.y), tempGrey);
						GUI::DrawText(Maths::Round((f32(team.controlled_count) / f32(total_capturables)) * 100.00f) + "%", Vec2f(bottomright.x - base_offset + 650, topleft.y), tempGrey);
					}
				}
			}
		}
	}

	// Discord Button
	{
		f32 width = 100;
		f32 height = 40;

		const string text = "Go to Discord Server";

		Vec2f dim;
		GUI::GetTextDimensions(text, dim);

		width = dim.x + 20;

		Vec2f tl = Vec2f(getScreenWidth() - 100 - width, y_offset + 10);
		Vec2f br = Vec2f(getScreenWidth() - 100, tl.y + height);

		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();

		bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;

		if (hover)
		{
			GUI::DrawButton(tl, br);

			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				Sound::Play("option");

				OpenWebsite("https://discord.gg/rhwRCmUNRK");
				// Engine::AcceptWebsiteOpen(true);
				// Menu::CloseAllMenus();
			}
		}
		else
		{
			GUI::DrawPane(tl, br, SColor(0xca8a8a8a));
		}

		GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	}

	// Blog Button
	{
		f32 width = 100;
		f32 height = 40;

		const string text = "TFlippy's Patreon";

		Vec2f dim;
		GUI::GetTextDimensions(text, dim);

		width = dim.x + 20;

		Vec2f tl = Vec2f(getScreenWidth() - 340 - width, y_offset + 10);
		Vec2f br = Vec2f(getScreenWidth() - 340, tl.y + height);

		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();

		bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;

		if (hover)
		{
			GUI::DrawButton(tl, br);

			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				Sound::Play("option");

				OpenWebsite("https://www.patreon.com/tflippy");
				// Engine::AcceptWebsiteOpen(true);
				// Menu::CloseAllMenus();
			}
		}
		else
		{
			GUI::DrawPane(tl, br, SColor(0xca8a8a8a));
		}

		GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	}

	// GitHub Button
	{
		f32 width = 100;
		f32 height = 40;

		const string text = "GitHub Repository";

		Vec2f dim;
		GUI::GetTextDimensions(text, dim);

		width = dim.x + 20;

		Vec2f tl = Vec2f(getScreenWidth() - 500 - width, y_offset + 10);
		Vec2f br = Vec2f(getScreenWidth() - 500, tl.y + height);

		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();

		bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;

		if (hover)
		{
			GUI::DrawButton(tl, br);

			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				Sound::Play("option");

				OpenWebsite("https://github.com/NoahTheLegend/territory-control");
				// Engine::AcceptWebsiteOpen(true);
				// Menu::CloseAllMenus();
			}
		}
		else
		{
			GUI::DrawPane(tl, br, SColor(0xca8a8a8a));
		}

		GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	}

	// Change log Button
	{
		f32 width = 100;
		f32 height = 40;

		const string text = "Change log";

		Vec2f dim;
		GUI::GetTextDimensions(text, dim);

		width = dim.x + 20;

		Vec2f tl = Vec2f(getScreenWidth() - 670 - width, y_offset + 10);
		Vec2f br = Vec2f(getScreenWidth() - 670, tl.y + height);

		CControls@ controls = getControls();
		Vec2f mousePos = controls.getMouseScreenPos();

		bool hover = mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y;

		if (hover)
		{
			GUI::DrawButton(tl, br);

			if (controls.isKeyJustPressed(KEY_LBUTTON))
			{
				Sound::Play("option");

				OpenWebsite("https://discord.gg/5Uk8s6PM7b");
				// Engine::AcceptWebsiteOpen(true);
				// Menu::CloseAllMenus();
			}
		}
		else
		{
			GUI::DrawPane(tl, br, SColor(0xca8a8a8a));
		}

		GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
	}

	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();


	//if (hovered_accolade > -1) drawHoverExplanation(hovered_accolade, hovered_age, hovered_tier, mousePos + Vec2f(0,30));
}

void drawHoverExplanation(int hovered_accolade, int hovered_age, int hovered_tier, Vec2f centre_top)
{
	if ((hovered_accolade < 0 || hovered_accolade >= accolade_description.length)) //(invalid/"unset" hover)
	{
		return;
	}

	string desc = getTranslatedString(accolade_description[hovered_accolade]);

	Vec2f size(0, 0);
	GUI::GetTextDimensions(desc, size);

	Vec2f tl = centre_top - Vec2f(size.x / 2, 0);
	Vec2f br = tl + size;

	//margin
	Vec2f expand(8, 8);
	tl -= expand;
	br += expand;

	GUI::DrawPane(tl, br, SColor(0xffffffff));
	GUI::DrawText(desc, tl + expand, SColor(0xffffffff));
}

string getRank(string &in username, SColor &out col, CPlayer@ p)
{
	// Note for anybody in the future:
	// Usernames are lower case
	// To get the hash of your username, do:
	// print('username'.getHash()+''); in rcon locally

	switch(username.getHash())
	{
		case -1006374661: // tflippy
		{
			col = SColor(255, 247, 255, 102);
			return "TC Creator";
		}
		break;

		case -80339204: //NovaTheSun
		case -1613311293: //Ninja4259
		{
			col = SColor(255, 250, 172, 230);
			return "Admin Abuser";
		}
		
		// case 2037779103: // digga
		{
			col = SColor(255, 255,100,100);
			return "Community Manager";
		}

		case 916202166: // pirate-rob
		{
			col = SColor(255, 117, 166, 244);
			return "RoS Creator";
		}

		case 1793967571: // merser433
		case -1980129081: // goldenguy
		case -1959624089: // koi_
		case 1002491121: // jammer312
		case -210526304: // mrhobo
		case -675232681: // wunarg
		{
			col = SColor(255, 95, 151, 239);
			return "TC Developer";
		}
		break;
		
		case -571333817: // NoahTheLegend
		{
			col = SColor(255, 85, 185, 235);
			return "Developer";
		}
		break;

		case -1913766845: // cesar0
		case -445244992: // sylw
		case 306188315: // sjd360
		case 494034411: // turtlecake
		case -608852120: // hobey
		case 926613433: // blackguy123
		case -1384627824: // oolmbalol
		case -1483665587: // zable
		case -803033509: // garodil
		case -1628567952: // betelgeuse0
		case -1012336410: // megawaffle2000
		{
			col = SColor(255, 247, 156, 44);
			return "TC Contributor";
		}
		break;

		case 1785258408: // TheCustomerMan
		{
			col = SColor(0xfffbf236);
			return "Beloved Admin ^ш^";
		}
		break;
		case -127609809: //RenderX
		{
			col = SColor(255, 255, 0, 0);
			return "Betrayal quintessence";
		}
		// case -1528101978: // ollimarrex
		// case 1931891399: // sniper2001
		/*
		case -1659763952: //5elfless
		{
			col = SColor(0,0,0,0);
			return "papa";
		}
		break;
		*/
		case -1913960806: // geti
		case 1613635087: // mm
		case -702206699: // flieslikeabrick
		case 1839286352: // furai
		case -1618040870: // jrgp
		case 745727592: // asu
		{
			col = SColor(255, 196, 86, 247);
			return "KAG Developer";
		}
		break;

		//Some patreon thing for the future maybe

		default:
		{
			if (p !is null)
			{
				CSecurity@ security = getSecurity();
				if (!(security.checkAccess_Feature(p, "patreon")))
				{
					return "";
				}
				else
				{
					col = SColor(255, 241, 196, 15);
					return "Patreon Supporter";
				}
			}
			return "";
		}
	}
	return "";
}

string getBounty(CPlayer@ this) 
{
	int killstreak = this.getAssists();
	int payedBounty = this.getScore();
	string currency = "coins";

	if (killstreak >= 5 && killstreak < 10) 
	{
		int totalBounty = 400 + payedBounty;
		return totalBounty + " " + currency;
	} 

	if (killstreak >= 10 && killstreak < 15) 
	{
		int totalBounty = 600 + payedBounty;
		return totalBounty + " " + currency;
	}

	if (killstreak >= 15 && killstreak < 20)
	{
		int totalBounty = 800 + payedBounty;
		return totalBounty + " " + currency;
	}

	if (killstreak >= 20)
	{
		int totalBounty = 1000 + payedBounty;
		return totalBounty + " " + currency;
	}

	return "";
}
