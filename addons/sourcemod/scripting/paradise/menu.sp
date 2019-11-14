
#define AUTO 1
#define LEGIT 2
#define FREESTYLE 3
#define PARKOUR 4
#define HALF-SIDEWAYS 5
#define SIDEWAYS 6
#define W-ONLY 7

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Timer | MENUS",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}




/* Paradise Styles
**
** Description: Players Select Their Style, or Learn More About A Style.
** Pages: mStyle_Main | mStyle_Info1 | mStyle_Info2
** -------------------------------------------------------------------------- */

public mStyle_Main(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise Styles");

	DrawPanelItem(panel, "Auto");
	DrawPanelItem(panel, "Legit");
	DrawPanelItem(panel, "Freestyle");
	DrawPanelItem(panel, "Parkour");
	DrawPanelItem(panel, "Half-Sideways");
	DrawPanelItem(panel, "Sideways");
	DrawPanelItem(panel, "W-Only");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 8);
	DrawPanelItem(panel, "More Info");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mStyle_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mStyle_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		//Player Selected A Style
		if(param2 == 8)
		{
			mStyle_Info1(param1);
		}
		else if(param2 <= 8)
		{
			g_info[param1][Style] = param2;
			CS_RespawnPlayer(param1);
			if((g_ZonesLoaded) && g_ZoneExists[0])
				TeleportToZone(param1, 0);
		}
	}
}

public mStyle_Info1(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise Styles  pg. 1/2");
	DrawPanelText(panel, "\n ");
	DrawPanelText(panel, "Select a Style to Learn More");
	DrawPanelItem(panel, "Auto");
	DrawPanelItem(panel, "Legit");
	DrawPanelItem(panel, "Freestyle");
	DrawPanelItem(panel, "Parkour");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	DrawPanelItem(panel, "Next Page");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mStyle_Info1Handler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}
public mStyle_Info1Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				//Load Auto Video Tutorial
			}
			case 2:
			{
				//Load Legit Video Tutorial
			}
			case 3:
			{
				//Load Freestyle Video Tutorial
			}
			case 4:
			{
				//Load Parkour Video Tutorial
			}
			case 7:
			{
				mStyle_Main(param1);
			}
			case 8:
			{
				mStyle_Info2(param1);
			}
		}
	}
}

public mStyle_Info2(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise Styles  pg. 2/2");

	DrawPanelText(panel, "\n");
	DrawPanelItem(panel, "Half-Sideways");
	DrawPanelItem(panel, "Sideways");
	DrawPanelItem(panel, "W-Only");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	DrawPanelItem(panel, "Prev. Page");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mStyle_Info2Handler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}
public mStyle_Info2Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				//Load HSW Video Tutorial
			}
			case 2:
			{
				//Load Sideways Video Tutorial
			}
			case 3:
			{
				//Load W-Only Video Tutorial
			}
			case 7:
			{
				mStyle_Main(param1);
			}
			case 8:
			{
				mStyle_Info1(param1);
			}
		}
	}
}



/* Paradise Commands
**
** Description: List of Paradise Commands
** Pages: mCommand_Main | mCommand_Basic | mCommand_Style | mCommand_Record | 
	  mCommand_Map | mCommand_Misc | mCommand_VIP | m_Command_ListHandler
** --------------------------------------------------------------------------*/

public mCommand_Main(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Select a Category");
	DrawPanelText(panel, "\n ");
	DrawPanelItem(panel, "Basic Commands");
	DrawPanelItem(panel, "Style Commands");
	DrawPanelItem(panel, "Record Commands");
	DrawPanelItem(panel, "Map Commands");
	DrawPanelItem(panel, "Misc. Commands");
	DrawPanelItem(panel, "VIP Commands");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mCommand_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}
public mCommand_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				mCommand_Basic(param1);
			}
			case 2:
			{
				mCommand_Style(param1);
			}
			case 3:
			{
				mCommand_Record(param1);
			}
			case 4:
			{
				mCommand_Map(param1);
			}
			case 5:
			{
				mCommand_Misc(param1);
			}
			case 6:
			{
				mCommand_VIP(param1);
			}
		}
	}
}

public mCommand_Basic(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Basic Commands");

	DrawPanelText(panel, "\n ");
	DrawPanelText(panel, "!style  - Select a Style");
	DrawPanelText(panel, "!r  - Respawn");
	DrawPanelText(panel, "!me  - Player Profile");
	DrawPanelText(panel, "!spec  - Spectate");
	DrawPanelText(panel, "!hide  - Hide Players");
	DrawPanelText(panel, "!report  - Report Player");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mCommand_ListHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mCommand_Style(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Style Commands");

	DrawPanelText(panel, "\n ");
	DrawPanelText(panel, "!style     - Select a Style");
	DrawPanelText(panel, "!tutorial  - Video Tutorial");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mCommand_ListHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mCommand_Record(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Record Commands");

	DrawPanelText(panel, "\n ");
	DrawPanelText(panel, "!me      - Your Profile");
	DrawPanelText(panel, "!pb      - Personal Best");
	DrawPanelText(panel, "!player  - Player Profile");
	DrawPanelText(panel, "!wr      - World Records");
	DrawPanelText(panel, "!top     - Top Records");
	DrawPanelText(panel, "!ranks   - Level Ranks");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mCommand_ListHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mCommand_Map(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Map Commands");

	DrawPanelText(panel, "\n ");
	DrawPanelText(panel, "!map       - Map Info");
	DrawPanelText(panel, "!nominate  - Select Map");
	DrawPanelText(panel, "!rtv       - Rock The Vote");
	DrawPanelText(panel, "!extend    - Extend Vote");
	DrawPanelText(panel, "!bug       - Report Bug");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mCommand_ListHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mCommand_Misc(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Misc. Commands");

	DrawPanelText(panel, "\n ");
	DrawPanelText(panel, "!join      - Community Info");
	DrawPanelText(panel, "!donate    - Donation Menu");
	DrawPanelText(panel, "!usp       - Get USP");
	DrawPanelText(panel, "!scout     - Get Scout");
	DrawPanelText(panel, "!settings  - Server Settings");
	DrawPanelText(panel, "!website   - Paradise Website");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mCommand_ListHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mCommand_VIP(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "VIP Commands");

	DrawPanelText(panel, "\n ");
	DrawPanelText(panel, "!vip      - VIP Settings");
	DrawPanelText(panel, "!models   - Player Models");
	DrawPanelText(panel, "!vipranks - Donation Ranks");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mCommand_ListHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mCommand_ListHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 7:
			{
				mCommand_Main(param1);
			}
		}
	}
}



/* Paradise Player Profile
**
** Description: Players Profile Showing Statistics
** Pages: mProfile_Main | mProfile_MapTimes1 | mProfile_MapTimes2
** --------------------------------------------------------------------------*/

public ShowProfile(client, const String: p_SSID[], const String:p_Name[], p_Level, p_Score, p_RankUser, p_RankTotal, p_WRCount, p_MapComp, const String:p_MapTimes[7][])
{
	decl String:panelString[64], String:ScoreString[64];
	
	decl Float:p_MapAvg, p_MapTotal;
	
	p_MapTotal = MapCounter;
	p_MapAvg = ((float(p_MapComp))/(float(p_MapTotal))) * 100;
	
	FormatNumberInt(p_Score, ScoreString, 64)
	
	Format(g_curSSID[client], 64, "%s", p_SSID);
	
	new Handle:panel = CreatePanel();
	Format(panelString, 64, "|★|  [Lvl %d] %s  |★|", p_Level, p_Name);
	SetPanelTitle(panel, panelString);
	DrawPanelText(panel, "\n ");
	
	if(p_RankUser > 0 )
	{
		Format(panelString, 64, "Player Progress | Rank %i/%i", p_RankUser, p_RankTotal);
	}
	else
	{
		Format(panelString, 64, "Player Progress | Unranked", p_RankUser, p_RankTotal);
	}
	
	DrawPanelItem(panel, panelString);
	Format(panelString, 64, "Paradise Score: %s", ScoreString);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "World Records: %i", p_WRCount);
	DrawPanelItem(panel, panelString);
	Format(panelString, 64, "Map Completion: %.2f%% (%i/%i Maps)", p_MapAvg, p_MapComp, p_MapTotal);
	DrawPanelItem(panel, panelString);
	DrawPanelText(panel, "\n ");
	DrawPanelItem(panel, "Current Map Records");
	Format(panelString, 64, "[A]: %s                   [L]: %s", p_MapTimes[0], p_MapTimes[1]);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "[F]: %s                  [P]: %s", p_MapTimes[2], p_MapTimes[3]);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "[HSW]: %s            [SW]: %s", p_MapTimes[4], p_MapTimes[5]);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "[W]: %s", p_MapTimes[6]);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");
	DrawPanelItem(panel, "View Player Info");
	DrawPanelText(panel, "\n ");
	DrawPanelItem(panel, "Recent Activity");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mProfile_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public mProfile_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				ClientCommand(param1, "sm_ranks");
			}
			case 2:
			{
				WorldRecordList(param1, g_curSSID[param1]);
			}
			case 3:
			{
				MapCompMenu(param1, g_curSSID[param1]);
			}
			case 4:
			{
				ClientCommand(param1, "sm_maptop");
			}
			case 5:
			{
				LoadInfo(param1, g_curSSID[param1]);
			}
			case 6:
			{
				RecentRecords(param1, g_curSSID[param1]);
			}
		}
	}
}

public ShowPlayerInfo(client, const String:p_SSID[], const String:p_Name[], const String:p_Date[], const String:p_fStyle[], const String:p_Status[])
{
	decl String:panelString[64];
	
	new Handle:panel = CreatePanel();
	Format(panelString, 64, "|★|  %s - Player Details  |★|", p_Name);
	SetPanelTitle(panel, panelString);
	DrawPanelText(panel, "\n ");
	Format(panelString, 64, "SteamID: %s", p_SSID);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "View Community Profile");
	DrawPanelItem(panel, panelString);
	DrawPanelText(panel, "\n ");
	Format(panelString, 64, "Joined: %s", p_Date);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "Favorite Style: %s", p_fStyle);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");
	Format(panelString, 64, "Current Status: %s", p_Status);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");

	SendPanelToClient(panel, client, mPlayerInfo_Handler, MENU_TIME_FOREVER);
	
	CloseHandle(panel);
}

public mPlayerInfo_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				decl String:SteamURL[512], String:SteamIDString[21], String:CommunityID[18];
				Format(SteamIDString, sizeof(SteamIDString), "%s", g_curSSID[param1]);
				
				GetCommunityIDString(SteamIDString, CommunityID, sizeof(CommunityID));
				
				Format(SteamURL, sizeof(SteamURL), "http://www.steamcommunity.com/profiles/%s", CommunityID);
				
				PrintToConsole(param1, "URL: %s", SteamURL);
				
				if(StrContains(SteamURL, "http://", false) != 0) Format(SteamURL, sizeof(SteamURL), "http://%s", SteamURL);
				
				FixMotdCSGO(SteamURL,"height=720,width=1280");
				
				ShowMOTDPanel(param1, "Player Profile", SteamURL, MOTDPANEL_TYPE_URL );
			}
			case 7:
			{
				LoadProfile(param1, g_curSSID[param1]);
			}
		}
	}
}

public MapCompMenu(client, const String:p_SSID[])
{
	decl String:panelString[64];
	
	new Handle:panel = CreatePanel();
	Format(panelString, 64, " Paradise Map Progress ");
	SetPanelTitle(panel, panelString);
	DrawPanelText(panel, "\n ");
	Format(panelString, 64, "Completed Maps");
	DrawPanelItem(panel, panelString);
	Format(panelString, 64, "Incomplete Maps");
	DrawPanelItem(panel, panelString);
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");

	SendPanelToClient(panel, client, MapCompMenu_Handler, MENU_TIME_FOREVER);
	
	CloseHandle(panel);
}
public MapCompMenu_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				MapCompletionList(param1, g_curSSID[param1], 1);
			}
			case 2:
			{
				MapCompletionList(param1, g_curSSID[param1], 2);
			}
			case 7:
			{
				LoadProfile(param1, g_curSSID[param1]);
			}
		}
	}
}

public ShowRecord(client, const String:p_SSID[], const String:p_Name[], const String:p_Map[], const String:p_fStyle[], const String:p_Record[], const String:p_Date[], p_Jumps, p_Strafes, Float:p_Sync, Float:p_PreSpeed, p_WallRuns, p_WallJumps)
{
	decl String:panelString[64];
	
	new Handle:panel = CreatePanel();
	Format(panelString, 64, "[%s] Record | %s", p_fStyle, p_Map);
	SetPanelTitle(panel, panelString);
	DrawPanelText(panel, "\n ");
	Format(panelString, 64, "Date: %s", p_Date);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "Player: %s", p_Name);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "Map: %s", p_Map);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "Record Time: %ss", p_Record);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");
	Format(panelString, 64, "Style: %s", p_fStyle);
	DrawPanelText(panel, panelString);
	Format(panelString, 64, "Jumps: %i", p_Jumps);
	DrawPanelText(panel, panelString);
	
	if(!StrEqual(p_fStyle, "Half-Sideways") || !StrEqual(p_fStyle, "Sideways") || !StrEqual(p_fStyle, "W-Only"))
	{
		Format(panelString, 64, "Strafes: %i", p_Strafes);
		DrawPanelText(panel, panelString);
		Format(panelString, 64, "Sync: %0.f%%", p_Sync);
		DrawPanelText(panel, panelString);
		
		if(StrEqual(p_fStyle, "Freestyle") || StrEqual(p_fStyle, "Parkour"))
		{
			Format(panelString, 64, "Pre-Speed: %0.f u/s", p_PreSpeed);
			DrawPanelText(panel, panelString);
			
			if(StrEqual(p_fStyle, "Parkour"))
			{
				Format(panelString, 64, "Wall Runs: %i", p_WallRuns);
				DrawPanelText(panel, panelString);
				Format(panelString, 64, "Wall Jumps: %i", p_WallJumps);
				DrawPanelText(panel, panelString);
			}
		}
	}
	
	DrawPanelText(panel, "\n ");
	if(LastMenu[client][0] != EOS)
	{
		SetPanelCurrentKey(panel, 7);
		DrawPanelItem(panel, "Back");
	}
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");

	SendPanelToClient(panel, client, mShowRecord_Handler, MENU_TIME_FOREVER);
	
	CloseHandle(panel);
}

public mShowRecord_Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				LoadProfile(param1, g_curSSID[param1]);
			}
			case 7:
			{
				if(StrEqual(LastMenu[param1], "PlayerWorldRecords"))
				{
					WorldRecordList(param1, g_curSSID[param1]);
					
					Format(LastMenu[param1], 64, "");
				}
				else if(StrEqual(LastMenu[param1], "RecentRecords"))
				{
					RecentRecords(param1, g_curSSID[param1])
					
					Format(LastMenu[param1], 64, "");
				}
				else if(StrContains(LastMenu[param1], "MapTop_", true) != -1)
				{
					decl String:mp_Style[64];
					
					Format(mp_Style, 64, "%s", LastMenu[param1]);
					ReplaceString(mp_Style, 64, "MapTop_", "");

					MapTopRecords(param1, g_curMap[param1], mp_Style);
					
					Format(LastMenu[param1], 64, "");
				}
				else if(StrContains(LastMenu[param1], "WorldRecords_", true) != -1)
				{
					decl String:mp_Page[64];
					
					Format(mp_Page, 64, "%s", LastMenu[param1]);
					ReplaceString(mp_Page, 64, "WorldRecords_", "");
					new page_num = StringToInt(mp_Page);
					
					switch(page_num)
					{
						case 1:
						{
							mWorldRecords_Main(param1);
						}
						case 2:
						{
							mWorldRecords_Main2(param1);
						}
						case 3:
						{
							mWorldRecords_Main3(param1);
						}
						case 4:
						{
							mWorldRecords_Main4(param1);
						}
					}
					
					Format(LastMenu[param1], 64, "");
				}
			}
		}
	}
}


/* Paradise World Records
**
** Description: World Records For Current Map
** Pages: mWorldRecords_Main | mWorldRecords_Main2 | mWorldRecords_Main3
** --------------------------------------------------------------------------*/

public mWorldRecords_Main(client)
{
	decl String:panelString[35], String:time[35];
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise World Records  pg. 1/4");

	DrawPanelText(panel, "\n ");

	DrawPanelItem(panel, "World Record [Auto]");
	Format(panelString, 35, "Player: %s", Auto_WR[PlayerName]);
	DrawPanelText(panel, panelString);
	FormatPlayerTime(Auto_WR[Time], time, sizeof(time), false, 0);
	Format(panelString, 35, "Time: %ss", time);
	DrawPanelText(panel, panelString);

	DrawPanelText(panel, "\n ");

	DrawPanelItem(panel, "World Record [Legit]");
	Format(panelString, 35, "Player: %s", Legit_WR[PlayerName]);
	DrawPanelText(panel, panelString);
	FormatPlayerTime(Legit_WR[Time], time, sizeof(time), false, 0);
	Format(panelString, 35, "Time: %ss", time);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");

	SetPanelCurrentKey(panel, 8);
	DrawPanelItem(panel, "Next Page");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mWorldRecords_MainHandler, MENU_TIME_FOREVER);
	
	Format(g_curMap[client], 128, "%s", Map[MapName]);
	Format(LastMenu[client], 64, "WorldRecords_1");
 
	CloseHandle(panel);
}
public mWorldRecords_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				WRLookup(param1, Map[MapName], "Auto");
			}
			case 2:
			{
				WRLookup(param1, Map[MapName], "Legit");
			}
			case 8:
			{
				mWorldRecords_Main2(param1);
			}
		}
	}
}

public mWorldRecords_Main2(client)
{
	decl String:panelString[35], String:time[35];
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise World Records  pg. 2/4");

	DrawPanelText(panel, "\n ");

	DrawPanelItem(panel, "World Record [Freestyle]");
	Format(panelString, 35, "Player: %s", Freestyle_WR[PlayerName]);
	DrawPanelText(panel, panelString);
	FormatPlayerTime(Freestyle_WR[Time], time, sizeof(time), false, 0);
	Format(panelString, 35, "Time: %ss", time);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");
	DrawPanelItem(panel, "World Record [Parkour]");
	Format(panelString, 35, "Player: %s", Parkour_WR[PlayerName]);
	DrawPanelText(panel, panelString);
	FormatPlayerTime(Parkour_WR[Time], time, sizeof(time), false, 0);
	Format(panelString, 35, "Time: %ss", time);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");

	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Prev. Page");
	DrawPanelItem(panel, "Next Page");
	DrawPanelItem(panel, "Exit");

	SendPanelToClient(panel, client, mWorldRecords_Main2Handler, MENU_TIME_FOREVER);
	
	Format(g_curMap[client], 128, "%s", Map[MapName]);
	Format(LastMenu[client], 64, "WorldRecords_2");

	CloseHandle(panel);
}
public mWorldRecords_Main2Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				WRLookup(param1, Map[MapName], "Freestyle");
			}
			case 2:
			{
				WRLookup(param1, Map[MapName], "Parkour");
			}
			case 7:
			{
				mWorldRecords_Main(param1);
			}
			case 8:
			{
				mWorldRecords_Main3(param1);
			}
		}
	}
}

public mWorldRecords_Main3(client)
{
	decl String:panelString[35], String:time[35];
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise World Records  pg. 3/4");
	DrawPanelText(panel, "\n ");
	DrawPanelItem(panel, "World Record [Half-Sideways]");
	Format(panelString, 35, "Player: %s", HalfSideways_WR[PlayerName]);
	DrawPanelText(panel, panelString);
	FormatPlayerTime(HalfSideways_WR[Time], time, sizeof(time), false, 0);
	Format(panelString, 35, "Time: %ss", time);
	DrawPanelText(panel, panelString);
	
	DrawPanelText(panel, "\n ");
	
	DrawPanelItem(panel, "World Record [Sideways]");
	Format(panelString, 35, "Player: %s", Sideways_WR[PlayerName]);
	DrawPanelText(panel, panelString);
	FormatPlayerTime(Sideways_WR[Time], time, sizeof(time), false, 0);
	Format(panelString, 35, "Time: %ss", time);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");
	
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Prev. Page");
	DrawPanelItem(panel, "Next Page");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mWorldRecords_Main3Handler, MENU_TIME_FOREVER);
	
	Format(g_curMap[client], 128, "%s", Map[MapName]);
	Format(LastMenu[client], 64, "WorldRecords_3");
 
	CloseHandle(panel);
}
public mWorldRecords_Main3Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				WRLookup(param1, Map[MapName], "Half-Sideways");
			}
			case 2:
			{
				WRLookup(param1, Map[MapName], "Sideways");
			}
			case 7:
			{
				mWorldRecords_Main2(param1);
			}
			case 8:
			{
				mWorldRecords_Main4(param1);
			}
		}
	}
}

public mWorldRecords_Main4(client)
{
	decl String:panelString[35], String:time[35];
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise World Records  pg. 4/4");
	DrawPanelText(panel, "\n ");
	DrawPanelItem(panel, "World Record [W-Only]");
	Format(panelString, 35, "Player: %s", WOnly_WR[PlayerName]);
	DrawPanelText(panel, panelString);
	FormatPlayerTime(WOnly_WR[Time], time, sizeof(time), false, 0);
	Format(panelString, 35, "Time: %ss", time);
	DrawPanelText(panel, panelString);
	DrawPanelText(panel, "\n ");
	
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Prev. Page");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mWorldRecords_Main4Handler, MENU_TIME_FOREVER);
	
	Format(g_curMap[client], 128, "%s", Map[MapName]);
	Format(LastMenu[client], 64, "WorldRecords_4");
 
	CloseHandle(panel);
}
public mWorldRecords_Main4Handler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				WRLookup(param1, Map[MapName], "W-Only");
			}
			case 7:
			{
				mWorldRecords_Main3(param1);
			}
		}
	}
}


/* Paradise Top Players by Style
**
** Description: Top Players For Each Style.
** Pages: TopPlayers_Main
** -------------------------------------------------------------------------- */

public TopPlayers_Main(client)
{
	decl String:panelString[64];
	
	new Handle:panel = CreatePanel();
	
	Format(panelString, sizeof(panelString), "Paradise Style Rankings");
	
	SetPanelTitle(panel, panelString);
	DrawPanelItem(panel, "Auto");
	DrawPanelItem(panel, "Legit");
	DrawPanelItem(panel, "Freestyle");
	DrawPanelItem(panel, "Parkour");
	DrawPanelItem(panel, "Half-Sideways");
	DrawPanelItem(panel, "Sideways");
	DrawPanelItem(panel, "W-Only");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, TopPlayers_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public TopPlayers_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				TopPlayers(param1, "Auto");
			}
			case 2:
			{
				TopPlayers(param1, "Legit");
			}
			case 3:
			{
				TopPlayers(param1, "Freestyle");
			}
			case 4:
			{
				TopPlayers(param1, "Parkour");
			}
			case 5:
			{
				TopPlayers(param1, "Half-Sideways");
			}
			case 6:
			{
				TopPlayers(param1, "Sideways");
			}
			case 7:
			{
				TopPlayers(param1, "W-Only");
			}
		}
	}
}



/* Paradise Top Map Records by Style
**
** Description: Top 100 Records For Each Style.
** Pages: mMapTop_Main
** -------------------------------------------------------------------------- */

public MapTop_Main(client, const String:TopMap[])
{
	decl String:panelString[64];
	
	new Handle:panel = CreatePanel();
	
	decl String:ReplacedString[128];
	
	Format(g_curMap[client], 128, "%s", TopMap);
	Format(ReplacedString, 128, "%s", TopMap);
	ReplaceString(ReplacedString, sizeof(ReplacedString), "_csgo", "", false);
	Format(panelString, sizeof(panelString), "Top Records - %s", TopMap);
	
	SetPanelTitle(panel, panelString);
	DrawPanelItem(panel, "Auto");
	DrawPanelItem(panel, "Legit");
	DrawPanelItem(panel, "Freestyle");
	DrawPanelItem(panel, "Parkour");
	DrawPanelItem(panel, "Half-Sideways");
	DrawPanelItem(panel, "Sideways");
	DrawPanelItem(panel, "W-Only");
	DrawPanelText(panel, "\n ");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, MapTop_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);
}

public MapTop_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				MapTopRecords(param1, g_curMap[param1], "Auto");
			}
			case 2:
			{
				MapTopRecords(param1, g_curMap[param1], "Legit");
			}
			case 3:
			{
				MapTopRecords(param1, g_curMap[param1], "Freestyle");
			}
			case 4:
			{
				MapTopRecords(param1, g_curMap[param1], "Parkour");
			}
			case 5:
			{
				MapTopRecords(param1, g_curMap[param1], "Half-Sideways");
			}
			case 6:
			{
				MapTopRecords(param1, g_curMap[param1], "Sideways");
			}
			case 7:
			{
				MapTopRecords(param1, g_curMap[param1], "W-Only");
			}
		}
	}
}





/* Paradise Zone Editor
**
** Description: Zone Editor
** Pages: mZones_Main | mZones_Editor
** -------------------------------------------------------------------------- */
public mZones_Main(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise Zones");

	SetPanelCurrentKey(panel, 1);
	DrawPanelItem(panel, "Start Zone");
	DrawPanelItem(panel, "End Zone");
	DrawPanelItem(panel, "Bonus Start");
	DrawPanelItem(panel, "Bonus End");
	DrawPanelItem(panel, "Cheat Zone");
	SetPanelCurrentKey(panel, 9);
	DrawPanelText(panel, " \n");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mZones_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);

}

public mZones_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(0 < param2 < 7)
		{
			switch(param2)
			{
				case 1:{g_SelectedZone[param1] = START_ZONE; mZones_Editor(param1);}
				case 2:{g_SelectedZone[param1] = END_ZONE; mZones_Editor(param1);}
				case 3:{g_SelectedZone[param1] = BONUS_START; mZones_Editor(param1);}
				case 4:{g_SelectedZone[param1] = BONUS_END; mZones_Editor(param1);}
				case 5:{g_SelectedZone[param1] = CHEAT_ZONE; mZones_Editor(param1);}
			}
		}
	}
}

public mZones_Editor(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Paradise Zone Editor");

	SetPanelCurrentKey(panel, 1);
	DrawPanelItem(panel, "Start Point");
	DrawPanelItem(panel, "Next Point");
	DrawPanelItem(panel, "Undo Point");
	DrawPanelItem(panel, "+ Height");
	DrawPanelItem(panel, "- Height");
	DrawPanelItem(panel, "Save Zone");
	DrawPanelItem(panel, "Clear Zone");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelText(panel, " \n");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mZones_EditorHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);

}
public mZones_EditorHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new CurZone = g_SelectedZone[param1];
		
		new Float:TempPoint[3];
		Array_Copy(g_Zone[CurZone][PointA], TempPoint, 3);
		
		if (g_Zone[CurZone][zHeight] == 0.0)
		{
			g_Zone[CurZone][zHeight] = 128.0;
		}

		switch(param2)
		{
			//Start Point
			case 1:
			{
				new Float:pos[3], Float:ang[3];
				GetClientEyePosition(param1, pos);
				GetClientEyeAngles(param1, ang);
			
				TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, param1);
				TR_GetEndPosition(g_Positions[param1][0]);
				Array_Copy(g_Positions[param1][0], g_Zone[CurZone][PointA], 3);
				g_Zone[CurZone][PointCount] = 1;
			
				mZones_Editor(param1);
			}
			//Next Point
			case 2:
			{
				if(0 < g_Zone[CurZone][PointCount] < 6)
				{
					new Float:pos[3], Float:ang[3];
					GetClientEyePosition(param1, pos);
					GetClientEyeAngles(param1, ang);
				
					TR_TraceRayFilter(pos, ang, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, param1);
					TR_GetEndPosition(g_Positions[param1][1]);
				
					switch(g_Zone[CurZone][PointCount])
					{
						case 1:{Array_Copy(g_Positions[param1][1], g_Zone[CurZone][PointB], 3);}
						case 2:{Array_Copy(g_Positions[param1][1], g_Zone[CurZone][PointC], 3);}
						case 3:{Array_Copy(g_Positions[param1][1], g_Zone[CurZone][PointD], 3);}
						case 4:{Array_Copy(g_Positions[param1][1], g_Zone[CurZone][PointE], 3);}
						case 5:{Array_Copy(g_Positions[param1][1], g_Zone[CurZone][PointF], 3);}
					}
				
					++g_Zone[CurZone][PointCount];
				}
				
				mZones_Editor(param1);
			}
			//Undo
			case 3:
			{
				if(0 < g_Zone[CurZone][PointCount] < 7)
				{
					new Float:BlankPoint[3];
					BlankPoint[0] = 0.0;
					BlankPoint[1] = 0.0;
					BlankPoint[2] = 0.0;

					switch(g_Zone[CurZone][PointCount])
					{
						case 1:{Array_Copy(BlankPoint, g_Zone[CurZone][PointA], 3);}
						case 2:{Array_Copy(BlankPoint, g_Zone[CurZone][PointB], 3);}
						case 3:{Array_Copy(BlankPoint, g_Zone[CurZone][PointC], 3);}
						case 4:{Array_Copy(BlankPoint, g_Zone[CurZone][PointD], 3);}
						case 5:{Array_Copy(BlankPoint, g_Zone[CurZone][PointE], 3);}
						case 6:{Array_Copy(BlankPoint, g_Zone[CurZone][PointF], 3);}
					}
				
					--g_Zone[CurZone][PointCount];
				}
				
				mZones_Editor(param1);
			}
			//+ Height
			case 4:
			{ g_Zone[CurZone][zHeight]++; mZones_Editor(param1);}\
			//- Height
			case 5:
			{ g_Zone[CurZone][zHeight]--; mZones_Editor(param1);}
			//Save Zone
			case 6:
			{
				if(2 < g_Zone[CurZone][PointCount] < 7)
				{

					new verts = g_Zone[CurZone][PointCount];
					new Float:height = g_Zone[CurZone][zHeight];
					
					new Float:A[3], Float:B[3], Float:C[3], Float:D[3], Float:E[3], Float:F[3];
					
					Array_Copy(g_Zone[CurZone][PointA], A, 3);
					Array_Copy(g_Zone[CurZone][PointB], B, 3);
					Array_Copy(g_Zone[CurZone][PointC], C, 3);
					Array_Copy(g_Zone[CurZone][PointD], D, 3);
					Array_Copy(g_Zone[CurZone][PointE], E, 3);
					Array_Copy(g_Zone[CurZone][PointF], F, 3);

					
					if(!g_ZoneExists[CurZone])
					{
						CreateZone(CurZone, verts, height, A, B, C, D, E, F);
						PrintToChat(param1, "[Paradise] Zone Saved!");
						LoadZones(Map[MapName]);
					}
					else
					{
						UpdateZone(CurZone, verts, height, A, B, C, D, E, F);
						PrintToChat(param1, "[Paradise] Zone Updated!");
						LoadZones(Map[MapName]);
					}
				}
				else
				{
					PrintToChat(param1, "[Paradise] Error: Can't Save Zone!");
				}
				
				mZones_Editor(param1);
			}
			//Clear Zone
			case 7:
			{
				if(g_ZoneExists[CurZone])
				{
					DeleteZone(CurZone);
				}
				
				if(0 < g_Zone[CurZone][PointCount] < 7)
				{
					for(new j = 0; j < 3; j++)
					{
						g_Zone[CurZone][PointA][j] = 0.0;
						g_Zone[CurZone][PointB][j] = 0.0;
						g_Zone[CurZone][PointC][j] = 0.0;
						g_Zone[CurZone][PointD][j] = 0.0;
						g_Zone[CurZone][PointE][j] = 0.0;
						g_Zone[CurZone][PointF][j] = 0.0;
					}
					
					g_Zone[CurZone][PointCount] = 0;
				}
				
				g_ZoneExists[CurZone] = false;
				PrintToChat(param1, "[Paradise] Zone has been cleared!");
				mZones_Editor(param1);
			}

			//Back
			case 8:
			{
				mZones_Main(param1);
			}
		}
	}
}



/* Paradise Donators
**
** Description: Menu For Players To Select Donator Settings
** Pages: mDonator_Main | mDonator_Models | mDonator_Trails
** -------------------------------------------------------------------------- */

public mDonator_Main(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "★ Paradise VIP Menu ★");

	SetPanelCurrentKey(panel, 1);
	DrawPanelItem(panel, "Player Models");
	DrawPanelItem(panel, "Weapons");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mDonator_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);

}
public mDonator_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				mDonator_Models(param1);
			}
			case 2:
			{
				mDonator_Weapons(param1);
			}
		}
	}
}


public mDonator_Models(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Select Your Player Model");

	SetPanelCurrentKey(panel, 1);
	DrawPanelItem(panel, "Pokemon Trainer");
	DrawPanelItem(panel, "Hatsune Miku");
	DrawPanelItem(panel, "Sonic The Hedgehog");
	DrawPanelItem(panel, "Super Mario");
	DrawPanelItem(panel, "Elsa - HunnyBop");
	DrawPanelItem(panel, "Rosalina - Miku");
	SetPanelCurrentKey(panel, 7);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mDonator_ModelsHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);

}
public mDonator_ModelsHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		
		decl String:OldModel[100];
		Format(OldModel, sizeof(OldModel), "%s", g_vip[param1][Model]);

		switch(param2)
		{
			case 1:
			{
				Format(g_vip[param1][Model], 100, "models/player/pokemon_trainer/pokemon_trainer.mdl");
				SetEntityModel(param1, g_vip[param1][Model]);
				PrintToChat(param1, " \x01\x06[Paradise]\x01 Pokemon Trainer Model Equipped!");
				SaveVIPSettings(param1);
			}
			case 2:
			{
				Format(g_vip[param1][Model], 100, "models/player/bbs_93x_net/miku_skin/miku_spring.mdl");
				SetEntityModel(param1, g_vip[param1][Model]);
				PrintToChat(param1, " \x01\x06[Paradise]\x01 Hatsune Miku Model Equipped!");
				SaveVIPSettings(param1);
			}
			case 3:
			{
				Format(g_vip[param1][Model], 100, "models/player/paradise/sonic/sonic.mdl");
				SetEntityModel(param1, g_vip[param1][Model]);
				PrintToChat(param1, " \x01\x06[Paradise]\x01 Sonic The Hedgehog Model Equipped!");
				SaveVIPSettings(param1);
			}
			case 4:
			{
				Format(g_vip[param1][Model], 100, "models/player/paradise/mario/mario2.mdl");
				SetEntityModel(param1, g_vip[param1][Model]);
				PrintToChat(param1, " \x01\x06[Paradise]\x01 Super Mario Model Equipped!");
				SaveVIPSettings(param1);
			}
			case 5:
			{
				decl String:AuthID[32];
				GetClientAuthString(param1, AuthID, sizeof(AuthID));
				
				PrintToConsole(param1, "%s", AuthID);
				
				if(StrEqual(AuthID, "STEAM_1:0:98064868"))
				{
					Format(g_vip[param1][Model], 100, "models/player/paradise/elsa/elsa2.mdl");
					SetEntityModel(param1, g_vip[param1][Model]);
					PrintToChat(param1, " \x01\x06[Paradise]\x01 Welcome Back Hunny Bop! Your Elsa Model has been set.(:");
					SaveVIPSettings(param1);
				}
				else
				{
					PrintToChat(param1, " \x01\x06[Paradise]\x01 You Don't Have Access To This Model");
				}
			}
			case 6:
			{
				decl String:AuthID[32];
				GetClientAuthString(param1, AuthID, sizeof(AuthID));

				if(StrEqual(AuthID, "STEAM_1:0:131895746"))
				{
					Format(g_vip[param1][Model], 100, "models/player/kuristaja/paradise/rosalina/rosalinaluma.mdl");
					SetEntityModel(param1, g_vip[param1][Model]);
					PrintToChat(param1, " \x01\x06[Paradise]\x01 Welcome Back Miku! Your Rosalina Model has been set.(:");
					SaveVIPSettings(param1);
				}
				else
				{
					PrintToChat(param1, " \x01\x06[Paradise]\x01 You Don't Have Access To This Model");
				}
			}
			case 7:
			{
				mDonator_Main(param1);
			}
		}
	}
}

public mDonator_Weapons(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Select A Weapon");

	SetPanelCurrentKey(panel, 1);
	DrawPanelItem(panel, "AWP");
	DrawPanelItem(panel, "Scout");
	DrawPanelItem(panel, "Deagle");
	DrawPanelItem(panel, "AK-47");
	DrawPanelItem(panel, "M4A4");
	DrawPanelItem(panel, "M4A1-S");
	DrawPanelItem(panel, "R8 Revolver");
	DrawPanelText(panel, " \n");
	SetPanelCurrentKey(panel, 8);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mDonator_WeaponsHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);

}

public mDonator_WeaponsHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:CurWeapon[64];
		
		switch(param2)
		{	
			case 1:
			{
				GetClientWeapon(param1, CurWeapon, sizeof(CurWeapon));
				
				if(!StrEqual(CurWeapon, "weapon_awp", false))
					GivePlayerItem(param1, "weapon_awp");
			}
			case 2:
			{
				GetClientWeapon(param1, CurWeapon, sizeof(CurWeapon));
				
				if(!StrEqual(CurWeapon, "weapon_ssg08", false))
					GivePlayerItem(param1, "weapon_ssg08");
			}
			case 3:
			{
				GetClientWeapon(param1, CurWeapon, sizeof(CurWeapon));
				
				if(!StrEqual(CurWeapon, "weapon_deagle", false))
					GivePlayerItem(param1, "weapon_deagle");
			}
			case 4:
			{
				GetClientWeapon(param1, CurWeapon, sizeof(CurWeapon));
				
				if(!StrEqual(CurWeapon, "weapon_ak47", false))
					GivePlayerItem(param1, "weapon_ak47");
			}
			case 5:
			{
				GetClientWeapon(param1, CurWeapon, sizeof(CurWeapon));
				
				if(!StrEqual(CurWeapon, "weapon_m4a1", false))
					GivePlayerItem(param1, "weapon_m4a1");
			}
			case 6:
			{
				GetClientWeapon(param1, CurWeapon, sizeof(CurWeapon));
				
				if(!StrEqual(CurWeapon, "weapon_m4a1_silencer", false))
					GivePlayerItem(param1, "weapon_m4a1_silencer");
			}
			case 7:
			{
				GetClientWeapon(param1, CurWeapon, sizeof(CurWeapon));
				
				if(!StrEqual(CurWeapon, "weapon_revolver", false))
					GivePlayerItem(param1, "weapon_revolver");
			}
			case 8:
			{
				mDonator_Main(param1);
			}
		}
	}
}

public mEVE_Main(client)
{
	new Float:rank1 = 0.0, Float:rank2 = 0.0, Float:rank3 = 0.0, Float:rank4 = 0.0, Float:rank5 = 0.0;
	
	//Find Top 5 Auto Test
	for(new i = 1; i <= MaxClients; i++)
	{
		if(g_info[i][Auto] > 0.0)
		{
			if(g_info[i][Auto] > g_info[rank1][Auto])
			{
				rank5 = rank4;
				rank4 = rank3;
				rank3 = rank2;
				rank2 = rank1;
				rank1 = g_info[i][Auto];
			}
			else if(g_info[i][Auto] > g_info[rank2][Auto])
			{
				rank5 = rank4;
				rank4 = rank3;
				rank3 = rank2;
				rank2 = g_info[i][Auto];
			}
			else if(g_info[i][Auto] > g_info[rank3][Auto])
			{
				rank5 = rank4;
				rank4 = rank3;
				rank3 = g_info[i][Auto];
			}
			else if(g_info[i][Auto] > g_info[rank4][Auto])
			{
				rank5 = rank4;
				rank4 = g_info[i][Auto];
			}
			else if(g_info[i][Auto] > g_info[rank5][Auto])
			{
				rank5 = g_info[i][Auto];
			}
		}
	}

	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "EVE - BunnyHop Companion");

	SetPanelCurrentKey(panel, 1);
	DrawPanelItem(panel, "Replay World Records");
	SetPanelCurrentKey(panel, 9);
	DrawPanelText(panel, " \n");
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mEVE_MainHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);

}
public mEVE_MainHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 1)
		{
			mEVE_Replays(param1);
		}
	}
}

public mEVE_Replays(client)
{
	decl String:MenuString[255];
	decl String:sTime[25];
	
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Select A Replay");

	SetPanelCurrentKey(panel, 1);
	FormatPlayerTime(Auto_WR[Time], sTime, 15, false, 2);
	Format(MenuString, 255, "[A] %s - %s", sTime, Auto_WR[PlayerName]);
	DrawPanelItem(panel, MenuString);
	FormatPlayerTime(Legit_WR[Time], sTime, 15, false, 2);
	Format(MenuString, 255, "[L] %s - %s", sTime, Legit_WR[PlayerName]);
	DrawPanelItem(panel, MenuString);
	FormatPlayerTime(Freestyle_WR[Time], sTime, 15, false, 2);
	Format(MenuString, 255, "[F] %s - %s", sTime, Freestyle_WR[PlayerName]);
	DrawPanelItem(panel, MenuString);
	FormatPlayerTime(Parkour_WR[Time], sTime, 15, false, 2);
	Format(MenuString, 255, "[P] %s - %s", sTime, Parkour_WR[PlayerName]);
	DrawPanelItem(panel, MenuString);
	FormatPlayerTime(HalfSideways_WR[Time], sTime, 15, false, 2);
	Format(MenuString, 255, "[HSW] %s - %s", sTime, HalfSideways_WR[PlayerName]);
	DrawPanelItem(panel, MenuString);
	FormatPlayerTime(Sideways_WR[Time], sTime, 15, false, 2);
	Format(MenuString, 255, "[SW] %s - %s", sTime, Sideways_WR[PlayerName]);
	DrawPanelItem(panel, MenuString);
	FormatPlayerTime(WOnly_WR[Time], sTime, 15, false, 2);
	Format(MenuString, 255, "[W] %s - %s", sTime, WOnly_WR[PlayerName]);
	DrawPanelItem(panel, MenuString);
	DrawPanelText(panel, " \n");
	SetPanelCurrentKey(panel, 8);
	DrawPanelItem(panel, "Back");
	SetPanelCurrentKey(panel, 9);
	DrawPanelItem(panel, "Exit");
 
	SendPanelToClient(panel, client, mEVE_ReplaysHandler, MENU_TIME_FOREVER);
 
	CloseHandle(panel);

}
public mEVE_ReplaysHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 <= 7)
		{
			new g_EVEBot = -1;
			
			decl String:sPath[PLATFORM_MAX_PATH];
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) >= CS_TEAM_T)
				{
					g_EVEBot = i;
				}
			}
			
			if(g_EVEBot != -1)
			{
				if(!BotMimic_IsPlayerMimicing(g_EVEBot))
				{
					if(!IsPlayerAlive(g_EVEBot))
					{
						CS_RespawnPlayer(g_EVEBot);
					}
					
					Format(sPath, sizeof(sPath), "%sWR-%i", Map[MapName], param2);
					
					BotMimic_PlayRecordByName(g_EVEBot, sPath);
			
				}
				else
				{
					PrintToChat(param1, " \x01\x03[EVE]: \x01Please Wait, While I Finish My Current Replay.");
				}
			}
			
		}
		else if (param2 == 8)
		{
			mEVE_Main(param1);
		}
	}
}