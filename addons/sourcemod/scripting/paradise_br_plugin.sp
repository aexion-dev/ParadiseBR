#include <sourcemod>
#include <emitsoundany>
#include <sdktools>	
#include <sdkhooks>
#include <cstrike>
#include <setname>
#include <entity>
#include <smlib>
#include <dhooks>
#include <sourcecomms>
#include <paradise-stocks>
#include <botmimic>


#undef REQUIRE_PLUGIN
#include <sourcebans>
#define REQUIRE_PLUGIN

#include "paradise/map.sp"
#include "paradise/vip.sp"
#include "paradise/zones.sp"
#include "paradise/mysql.sp"
#include "paradise/eve.sp"
#include "paradise/menu.sp"
#include "paradise/commands.sp"
#include "paradise/styles.sp"
#include "paradise/security.sp"
#include "paradise/settings.sp"

#pragma semicolon 1

enum Timer
{
	Enabled,
	Float:StartTime,
	Float:EndTime,
	String:MapTime[64],
	bool:Bonus
}

new g_timers[MAXPLAYERS+1][Timer];

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | <3",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR v2",
	url = ""
}

/*
	Known Issues:
	Check-In System Doesn't Work Correctly
		- EVE Failed To Replay World Records Due To !hide Bug With Players Spectating AGAIN!!
		- Tier1 -15m Tier 2 - 20m Tier 3 - 25m tier 4 30m Tier 5 - 35 min (Next Time)
		- Need A Proper/Visible Scoreboard System
		- HUD Doesn't Show In Spectate If Player Is Under WR Time
		- Make !Profile/!PB A Non-MySQL Static Menu
		- Remove DQ after X timer if they disconnect, they wont get anymore points anyway.
		- Add commands for: Adding whitelist player, Removing whitelist player
		- TEST Map Finish Stuff (Songs, Etc)
*/

//-------------------
// Plugin Loading.. |
//-------------------
public OnPluginStart()
{
	AddCommandListener(HookPlayerChat, "say");
	AddCommandListener(HookPlayerChat, "say_team");
	AddCommandListener(Command_JoinTeam, "jointeam");
	
	LoadTranslations("common.phrases.txt");
	
	HookEvent("player_spawn", event_PlayerSpawn);
	HookEvent("player_jump", event_PlayerJump);
	HookEvent("player_death", event_PlayerDeath);
	HookEvent("cs_win_panel_match", event_MapEnd, EventHookMode_Pre);
	HookEvent("player_disconnect", event_PlayerDisconnect, EventHookMode_Pre);
	HookEvent("round_start", SetAllTalk, EventHookMode_Pre);
	HookEvent("player_team", OnPlayerTeam, EventHookMode_Pre);
	HookEvent("server_cvar", Event_ServerCvar, EventHookMode_Pre);
	HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);
	
	RegConsoleCmd("sm_style", sm_style); // Style Menu
	RegConsoleCmd("sm_mapinfo", sm_mapinfo); // View Map Info
	RegConsoleCmd("sm_minfo", sm_mapinfo);
	RegConsoleCmd("sm_profile", sm_profile); //Player Profile
	RegConsoleCmd("sm_me", sm_profile);
	RegConsoleCmd("sm_wr", sm_wr); //World Records Menu
	RegConsoleCmd("sm_worldrecord", sm_wr);
	RegConsoleCmd("sm_maptop", sm_maptop); //Top Records For Current Map
	RegConsoleCmd("sm_mtop", sm_maptop);
	RegConsoleCmd("sm_autowr", sm_autowr); // Auto WR For Current Map
	RegConsoleCmd("sm_legitwr", sm_legitwr); // Legit WR For Current Map
	RegConsoleCmd("sm_freestylewr", sm_freestylewr); // Freestyle WR For Current Map
	RegConsoleCmd("sm_parkourwr", sm_parkourwr); // Parkour WR For Current Map
	RegConsoleCmd("sm_hswwr", sm_hswwr); // Half-Sideways WR For Current Map
	RegConsoleCmd("sm_swwr", sm_swwr); // Sideways WR For Current Map
	RegConsoleCmd("sm_wonlywr", sm_wonlywr); // W-Only WR For Current Map*/
	
	RegConsoleCmd("sm_r", sm_r); //Respawn Player at Start
	RegConsoleCmd("sm_restart", sm_r); //Respawn At Start
	RegConsoleCmd("sm_auto", sm_auto); //Switch to Auto Style
	RegConsoleCmd("sm_legit", sm_legit); //Switch to Legit Style
	RegConsoleCmd("sm_freestyle", sm_freestyle); //Switch to Freestyle Style
	RegConsoleCmd("sm_parkour", sm_parkour); //Switch to Parkour Style
	RegConsoleCmd("sm_hsw", sm_hsw); //Switch to Half-Sideways Style
	RegConsoleCmd("sm_halfsideways", sm_hsw);
	RegConsoleCmd("sm_sideways", sm_sideways);//Switch to Sideways Style
	RegConsoleCmd("sm_sw", sm_sideways);
	RegConsoleCmd("sm_wonly", sm_wonly);//Switch to W-Only Style
	
	RegConsoleCmd("sm_spec", sm_spectate, "sm_spec <target> - Spectate a player");
	RegConsoleCmd("sm_spectate", sm_spectate, "sm_spectate <target> - Spectate a player");
	RegConsoleCmd("sm_hideweapons", sm_hideweapons, "Toggle Your Weapon Visibility");
	RegConsoleCmd("sm_hideknife", sm_hideweapons, "Toggle Your Weapon Visibility");
	
	RegConsoleCmd("sm_vip", sm_vip);
	RegConsoleCmd("sm_models", sm_models);
	
	RegAdminCmd("sm_setlevel", SetLevel, ADMFLAG_RCON, "Change players in-game level");
	RegAdminCmd("sm_givexp", sm_givexp, ADMFLAG_RCON, "Give Player XP");
	RegAdminCmd("sm_zones", sm_zones, ADMFLAG_RCON, "Paradise Zone Editor");
	RegAdminCmd("sm_addmap", sm_addmap, ADMFLAG_RCON, "Add Map To Database");
	RegAdminCmd("sm_deletemap", sm_deletemap, ADMFLAG_RCON, "Remove Map From Database");
	RegAdminCmd("sm_addvip", sm_addvip, ADMFLAG_RCON, "Give Player Donator Status");
	
	RegAdminCmd("sm_querycount", sm_querycount, ADMFLAG_RCON, "Show # of MySQL Queries Ran This Round");
	
	//Battle Royal Commands//
	
	RegAdminCmd("br_start", br_start, ADMFLAG_RCON, "Start Battle Royal Event");
	//RegAdminCmd("br_end", br_end, ADMFLAG_RCON, "End Battle Royal Event");
	
	//RegAdminCmd("br_startround", br_end, ADMFLAG_RCON, "Force Starts Round Without Checking Players In");
	
	RegConsoleCmd("br_spectate", br_spectate, "Spectator Mode For Staff/Casters");
	RegConsoleCmd("br_hidehud", br_hidehud, "Hide Players HUD");
	RegConsoleCmd("br_showhud", br_showhud, "Show Players HUD");
	RegAdminCmd("br_slowmotion", br_slowmotion, ADMFLAG_RCON, "Slow Motion for Cinematics");
	RegAdminCmd("br_test", br_test, ADMFLAG_RCON, "Test Command");
	
	//HUD Timers
	CreateTimer(0.1, HUD, _, TIMER_REPEAT);
	
	//Style Timers
	StyleTimers();
	
	//Activate Security
	LoadSecurity();
	
	CreateDB(db);
	
	//Assign MapChangeTrie Handle
	MapChangeData = CreateTrie();
}

//----------------
// Map Loading.. |
//----------------
public OnMapStart()
{
	QueryCounter = 0;
	
	//Precache Content
	PrecacheModels();

	//Set Current Map.
	GetCurrentMap(Map[MapName], sizeof(Map[MapName]));
	
	//Reset WR Cache
	Format(Auto_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Auto_WR[Time] = 0.0;
	
	Format(Legit_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Legit_WR[Time] = 0.0;
	
	Format(Freestyle_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Freestyle_WR[Time] = 0.0;
	
	Format(Parkour_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Parkour_WR[Time] = 0.0;
	
	Format(HalfSideways_WR[PlayerName], MAX_NAME_LENGTH, "None");
	HalfSideways_WR[Time] = 0.0;
	
	Format(Sideways_WR[PlayerName], MAX_NAME_LENGTH, "None");
	Sideways_WR[Time] = 0.0;
	
	Format(WOnly_WR[PlayerName], MAX_NAME_LENGTH, "None");
	WOnly_WR[Time] = 0.0;

	WorldRecordsLoaded = false;
	replayCount = 0;

	if(db != INVALID_HANDLE)
	{
		InitZones();
		MapStarted();
		LoadWorldRecords(Map[MapName]);
		ParadiseSettings();
	}
	else
	{
		CreateTimer(5.0, LateLoad);
	}
	
}

public Action:LateLoad(Handle:timer)
{
	if(db != INVALID_HANDLE)
	{
		InitZones();
		MapStarted();
		LoadWorldRecords(Map[MapName]);
		ParadiseSettings();
	}
	else
	{
		PrintToServer("[Paradise] Error: Cannot Connect To Database!");
	}

	return Plugin_Stop;
}

public OnMapEnd()
{
	Format(Map[MapName], 64, "Invalid Map");
	Map[Tier] = 0;
	Format(Map[Stages], 64, "0");
	Map[XPValue] = 0;
}

public Action:event_MapEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	ClearTrie(MapChangeData);
	UpdateCurrentPlayers();
}

//--------------------------------
// Player Connecting To Server.. |
//--------------------------------

public OnClientPutInServer(client)
{
	if (IsFakeClient(client))
	{
		CS_SetMVPCount(client, 1);	
		return;
	}
	
	SDKHook(client, SDKHook_WeaponDrop, Hook_WeaponDrop);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public OnClientAuthorized(client)
{

}

public OnClientPostAdminCheck(client)
{	
	decl String:steamid[64];
	
	if(!IsFakeClient(client))
	{
		new TrieIndex = -1;
		
		GetClientAuthString(client, steamid, sizeof(steamid));
		
		//Reset Client's Data
		g_info[client][Level] = 0;
		g_info[client][XP] = 0;
		g_info[client][XP_Needed] = 0;
		g_info[client][Score] = 0;
		Format(g_info[client][Status], 15, "INVALID");
		g_info[client][Style] = 0;
		g_info[client][BRPoints] = 0.0;
		g_timers[client][Bonus] = false;
		ClientDataLoaded[client] = false;
		
		g_oldXP[client] = -1;
		g_oldLevel[client] = -1;
		
		if(GetTrieValue(MapChangeData, steamid, TrieIndex))
		{
			if(TrieIndex >= 0 && IsValidClient(client, false))
			{
				g_info[client][Level] = g_mapchange[TrieIndex][Level]; 
				g_info[client][XP] = g_mapchange[TrieIndex][XP];
				g_info[client][XP_Needed] = g_mapchange[TrieIndex][XP_Needed]; 
				g_info[client][Score] = g_mapchange[TrieIndex][Score];
				//g_info[client][BRPoints] = g_mapchange[TrieIndex][BRPoints];
				strcopy(g_info[client][Status], 15, g_mapchange[TrieIndex][Status]);
				
				g_oldLevel[client] = g_info[client][Level];
				g_oldXP[client] = g_info[client][XP];
				
				ClientDataLoaded[client] = true;
				
				//CS_SetClientContributionScore(client, RoundToFloor(g_info[client][BRPoints]));
				
				RemoveFromTrie(MapChangeData, steamid);
			}
		}
		
		/*if(BR_Round >= 1)
		{
			for(new f = 0; f <= 29; f++)
			{
				if(StrEqual(steamid, PlayerList[f]))
				{
					g_info[client][BRPoints] = PlayerPoints[f];
					CS_SetClientContributionScore(client, RoundToFloor(g_info[client][BRPoints]));
				}
			}	
		}*/
		
		if(!ClientDataLoaded[client] && IsValidClient(client, false))
		{
			CreateTimer(1.0, LoadData_Delay, client);
			//LoadPlayerData(client);
		}

		//Reset Client's Records
		ClientRecordsLoaded[client] = false;
		
		g_info[client][Auto] = 0.0;
		g_info[client][Legit] = 0.0;
		g_info[client][Freestyle] = 0.0;
		g_info[client][Parkour] = 0.0;
		g_info[client][HalfSideways] = 0.0;
		g_info[client][Sideways] = 0.0;
		g_info[client][WOnly] = 0.0;
		
		LoadPlayerRecords(client, Map[MapName]);
		
		//Reset Temporary Variables
		g_info[client][Style] = 0;
		
		g_timers[client][Enabled] = false;
		g_timers[client][Bonus] = false;	
		
		IsPlayerInZone[0][client] = false;
		IsPlayerInZone[1][client] = false;
		IsPlayerInZone[2][client] = false;
		IsPlayerInZone[3][client] = false;
		IsPlayerInZone[4][client] = false;
		playerpos[client][0] = 0.0;
		playerpos[client][1] = 0.0;
		playerpos[client][2] = 0.0;
		
		g_bViewModel[client] = true;
		SetLevelTag(client);
		
		if(BR_Round >= 0)
		{
			/*Authorize Player*/
			
			new k = -1;
			
			for(new f = 0; f <= 28; f++)
			{
				//Player has a matching AuthToken
				if(StrEqual(steamid, AuthPlayer[f][AuthSID], true))
				{
					PrintToChatAll(" \x01\x06[Paradise] \x01Player %s \x01is is whitelisted. Checking Auth Token..", AuthPlayer[f][AuthName]);
					k++;
					
					switch(AuthPlayer[f][EventGroup])
					{
						//AuthToken is for BR Player
						case 1:
						{
							//BR Warm-Up
							if(BR_Round == 0 && BR_Warmup)
							{
								PrintToChatAll(" \x01\x06[Paradise] \x01Player %s \x01has been Checked In!", AuthPlayer[f][AuthName]);
								AuthPlayer[f][CheckedIn] = true;
							}
							//BR Active 
							else if(BR_Round >= 1 && !BR_Warmup)
							{
								//If Round Check-In Is Still Active & Player Hasn't Been DQ'd.
								//Doesn't Matter If Still In Check-In Phase, Because 5min. Return Timer Will Auto DQ The Player.
								if(AuthPlayer[f][CheckedIn])
								{
									//Player is valid, and is now ready for the round.
									AuthPlayer[f][PlayerReady] = true;
									g_info[client][BRPoints] = AuthPlayer[f][BRScore];
								}
								else
								{
									KickClient(client, "Battle Royale: You are not authorized or have been disqualified from the event!");
								}
							}
							else if(BR_Round == 0 && !BR_Warmup)
							{
								if(!AuthPlayer[f][CheckedIn])
								{
									KickClient(client, "Battle Royale: You are not authorized or have been disqualified from the event!");
								}
							}
						}
						//AuthToken is for BR Staff
						case 2:
						{
							BR_Staff = client;
							
							//BR Warm-Up
							if(BR_Round == 0 && BR_Warmup)
							{
								AuthPlayer[f][CheckedIn] = true;
								PrintToChatAll(" \x01\x06[Paradise] \x01Player %s \x01has been Checked In!", AuthPlayer[f][AuthName]);
							}
							//BR Active 
							else if(BR_Round >= 1 && !BR_Warmup)
							{
								//Player is valid, and is now ready for the round.
								AuthPlayer[f][PlayerReady] = true;
							}
						}
						//AuthToken is for BR Casters
						case 3:
						{
							if(f == 26)
							{
								BR_Caster1 = client;
							}
							else if(f == 27)
							{
								BR_Caster2  = client;
							}
							
							//BR Warm-Up
							if(BR_Round == 0 && BR_Warmup)
							{
								AuthPlayer[f][CheckedIn] = true;
								PrintToChatAll(" \x01\x06[Paradise] \x01Player %s \x01has been Checked In!", AuthPlayer[f][AuthName]);								
							}
							//BR Active 
							else if(BR_Round >= 1 && !BR_Warmup)
							{
								//Player is valid, and is now ready for the round.
								AuthPlayer[f][PlayerReady] = true;
							}
						}
						//AuthToken is for BR Stream
						case 4:
						{
							BR_Stream = client;
							
							//BR Warm-Up
							if(BR_Round == 0 && BR_Warmup)
							{
								AuthPlayer[f][CheckedIn] = true;
								PrintToChatAll(" \x01\x06[Paradise] \x01Player %s \x01has been Checked In!", AuthPlayer[f][AuthName]);								
							}
							//BR Active 
							else if(BR_Round >= 1 && !BR_Warmup)
							{
								//Player is valid, and is now ready for the round.
								AuthPlayer[f][PlayerReady] = true;
							}
						}
					}
				}
			}
			
			//Kick Any Non-Authorized Player
			if(k == -1)
			{
				KickClient(client, "Battle Royale: You are not authorized or have been disqualified from the event!");
			}
		}
	}
	else if(IsFakeClient(client))
	{
		LoadEVE(client);
	}
	
}
public Action:LoadData_Delay(Handle:timer, any:client)
{
	if(IsValidClient(client, false))
	{
		LoadPlayerData(client);
		LogMessage("[ %s]: %N Connection Successful - Loading Player Data From DB", Map[MapName], client);
	}
	else
	{
		LogMessage("[ %s]: %N Connection Failed - Load Player Data Aborted", Map[MapName], client);
	}
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	// Reset Parkour Cache
	g_LastSideMove[client][0]   = 0.0;
	g_LastSideMove[client][0]   = 0.0;
	g_LastDodgeTick[client]     = 0;
	g_LandingTick[client]       = 0;
	g_LastTapTick[client]       = 0;
	g_LastTapKey[client]        = 0;
	g_WallJumpCount[client]		= 0;
	g_bCanDodge[client]         = false;
	g_bWaitingForGround[client] = false;
	g_Jumped[client]            = false;
	g_LastButtons[client]       = 0;
	
	
	//Reset Client Security Cache
	p_time_lasthardfld[client] = 0.0;
	p_cmdcnt_hard[client] = 0;
	p_hard_banned[client] = false;
	
	return true;
}


//-------------------------------------
// Player Disconnecting From Server.. |
//-------------------------------------

public OnClientDisconnect(client)
{
	//Reset Client's Records
	g_info[client][Auto] = 0.0;
	g_info[client][Legit] = 0.0;
	g_info[client][Freestyle] = 0.0;
	g_info[client][Parkour] = 0.0;
	g_info[client][HalfSideways] = 0.0;
	g_info[client][Sideways] = 0.0;
	g_info[client][WOnly] = 0.0;
	
	//Reset Client's Timer
	g_timers[client][Enabled] = false;
	g_timers[client][Bonus] = false;
	
	//Reset Client Zone Positions
	IsPlayerInZone[0][client] = false;
	IsPlayerInZone[1][client] = false;
	IsPlayerInZone[2][client] = false;
	IsPlayerInZone[3][client] = false;
	IsPlayerInZone[4][client] = false;
	playerpos[client][0] = 0.0;
	playerpos[client][1] = 0.0;
	playerpos[client][2] = 0.0;
	
	//Reset VIP Cache
	Format(g_vip[client][Model], 100, "");
	VIP_Player[client] = false;
	
	//Reset Client Security Cache
	aiJumps[client] = 0;
	afAvgJumps[client] = 5.0;
	afAvgSpeed[client] = 250.0;
	afAvgPerfJumps[client] = 0.3333;
	aiPattern[client] = 0;
	aiPatternhits[client] = 0;
	aiAutojumps[client] = 0;
	aiIgnoreCount[client] = 0;
	bBanFlagged[client] = false;
	avVEL[client][2] = 0.0;
	new i;
	while (i < 30)
	{
		aaiLastJumps[client][i] = 0;
		i++;
	}
	
	//Reset Hide Players Setting
	g_bViewModel[client] = true;
	
	//Unload Client's Data Flags
	ClientDataLoaded[client] = false;
	ClientRecordsLoaded[client] = false;
}

public Action:event_PlayerDisconnect(Handle:event, const String:name[], bool:dont_broadcast) 
{
	decl String:steamid[64];
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsValidClient(client, false) && !IsFakeClient(client) && ClientDataLoaded[client])
	{
		LogMessage("[ %s]: %N has disconnected from server. Saving Player Data.", Map[MapName], client);
		
		GetClientAuthString(client, steamid, sizeof(steamid));
		
		CalculateScore(client);
		UpdatePlayer(client);
		
		RemoveFromTrie(MapChangeData, steamid);
	}
	
	g_oldXP[client] = -1;
	g_oldLevel[client] = -1;
	
	//Reset Client's Records
	g_info[client][Auto] = 0.0;
	g_info[client][Legit] = 0.0;
	g_info[client][Freestyle] = 0.0;
	g_info[client][Parkour] = 0.0;
	g_info[client][HalfSideways] = 0.0;
	g_info[client][Sideways] = 0.0;
	g_info[client][WOnly] = 0.0;
	
	//Reset Client's Timer
	g_timers[client][Enabled] = false;
	g_timers[client][Bonus] = false;
	
	//Reset Client Zone Positions
	IsPlayerInZone[0][client] = false;
	IsPlayerInZone[1][client] = false;
	IsPlayerInZone[2][client] = false;
	IsPlayerInZone[3][client] = false;
	IsPlayerInZone[4][client] = false;
	playerpos[client][0] = 0.0;
	playerpos[client][1] = 0.0;
	playerpos[client][2] = 0.0;
	
	//Reset VIP Cache
	Format(g_vip[client][Model], 100, "");
	VIP_Player[client] = false;
	
	//Reset Client Security Cache
	aiJumps[client] = 0;
	afAvgJumps[client] = 5.0;
	afAvgSpeed[client] = 250.0;
	afAvgPerfJumps[client] = 0.3333;
	aiPattern[client] = 0;
	aiPatternhits[client] = 0;
	aiAutojumps[client] = 0;
	aiIgnoreCount[client] = 0;
	bBanFlagged[client] = false;
	avVEL[client][2] = 0.0;
	new i;
	while (i < 30)
	{
		aaiLastJumps[client][i] = 0;
		i++;
	}
	
	//Reset Hide Players Setting
	g_bViewModel[client] = true;
	
	//Unload Client's Data Flags
	ClientDataLoaded[client] = false;
	ClientRecordsLoaded[client] = false;
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	
	/* Update Player AuthToken */
	for(new f = 0; f <= 28; f++)
	{
		//Player has an Active AuthToken
		if(StrEqual(steamid, AuthPlayer[f][AuthSID], true))
		{
			switch(AuthPlayer[f][EventGroup])
			{
				//AuthToken is for BR Player
				case 1:
				{
					//BR Warm-Up
					if(BR_Round == 0 && BR_Warmup)
					{
						AuthPlayer[f][CheckedIn] = false;
					}
					//BR Active 
					else if(BR_Round >= 1 && !BR_Warmup)
					{
						//Player Is Checked-In
						if(AuthPlayer[f][CheckedIn])
						{
							//Player has Disconnected After Round Check-In. If they do not return in 5 min. they will be disqualified.
							if(BR_RoundStart)
							{
								//5 .min DQ-Return Timer
								PrintToChatAll(" \x01\x07Player \x01%s \x01\x07has left the Arena! 5 min. before player will be disqualified.", AuthPlayer[f][AuthName]);
								CreateTimer(300.0, PlayerDQ, f);
								AuthPlayer[f][PlayerReady] = false;
							}
							//Player Disconnected During Round Check-In. Player Must Return Before Round Check-In Ends, or will be Disqualified.
							else if(!BR_RoundStart)
							{
								AuthPlayer[f][PlayerReady] = false;
							}
						}
					}
				}
				//AuthToken is for BR Staff
				case 2:
				{
					BR_Staff = -1;
					
					//BR Warm-Up
					if(BR_Round == 0 && BR_Warmup)
					{
						AuthPlayer[f][CheckedIn] = false;
					}
					//BR Active 
					else if(BR_Round >= 1 && !BR_Warmup)
					{
						//Staff Isn't Ready
						if(!BR_RoundStart)
						{
							AuthPlayer[f][PlayerReady] = false;
						}
					}
				}
				//AuthToken is for BR Casters
				case 3:
				{
					if(f == 26)
					{
						BR_Caster1 = -1;
					}
					else if(f == 27)
					{
						BR_Caster2  = -1;
					}
					
					//BR Warm-Up
					if(BR_Round == 0 && BR_Warmup)
					{
						AuthPlayer[f][CheckedIn] = false;
					}
					//BR Active 
					else if(BR_Round >= 1 && !BR_Warmup)
					{
						//Casters Not Ready
						AuthPlayer[f][PlayerReady] = false;
					}
				}
				//AuthToken is for BR Stream
				case 4:
				{
					BR_Stream = -1;
					
					//BR Warm-Up
					if(BR_Round == 0 && BR_Warmup)
					{
						AuthPlayer[f][CheckedIn] = false;
					}
					//BR Active 
					else if(BR_Round >= 1 && !BR_Warmup)
					{
						//Stream Not Ready
						AuthPlayer[f][PlayerReady] = false;
					}
				}
			}
		}
	}

	return Plugin_Handled;
}

public Action:PlayerDQ(Handle:timer, any:AuthIndex)
{
	if(AuthPlayer[AuthIndex][CheckedIn])
	{
		if(!AuthPlayer[AuthIndex][PlayerReady])
		{
			PrintToChatAll(" \x01\x07Player \x01%s \x01\x07 has been disqualified! (Reason: Abandoned Tournament)", AuthPlayer[AuthIndex][AuthName]);
			AuthPlayer[AuthIndex][CheckedIn] = false;
		}
	}
}


//------------------------
// Player Selects A Team |
//------------------------

public Action:Command_JoinTeam(client, const String:command[], argc) 
{ 
	if(!IsFakeClient(client))
	{
		SetLevelTag(client);
		
		if(!IsPlayerAlive(client))
		{
			if(!GetEntProp(g_iGameRulesEnt, Prop_Send, "m_bWarmupPeriod"))
			{
				//CS_RespawnPlayer(client);
			}
		}
	}
	
	if (!client) 
		return Plugin_Continue;
	
	decl String:g_szTeam[4];
	
	GetCmdArgString(g_szTeam, sizeof(g_szTeam));
	
	new oldteam = GetClientTeam(client);
	new team = StringToInt(g_szTeam);
	
	if (team == 0) return Plugin_Handled;
	
	if (team == 1 && BR_RoundStart && BR_Round >= 1) return Plugin_Handled;
	
	if (oldteam == 1 || oldteam == 0)
	{
		new iCTNumber=0;
		new iTNumber=0;
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && (GetClientTeam(i) == 2) && IsPlayerAlive(i)) 
			{
				iTNumber++;
			}
			if (IsClientInGame(i) && (GetClientTeam(i) == 3) && IsPlayerAlive(i)) 
			{
				iCTNumber++;
			}
		}
		
		if ((team == 2) && (iTNumber <= 15))
		{
			if(!IsFakeClient(client))
			{
				CS_SwitchTeam(client, team);
				CS_RespawnPlayer(client);
				return Plugin_Handled;
			}
		}
		else if ((team == 3) && (iCTNumber <= 15))
		{
			if(IsFakeClient(client))
			{
				CS_SwitchTeam(client, team);
				CS_RespawnPlayer(client);
				return Plugin_Handled;
			}
		}
		else
		{
			return Plugin_Handled;
		}
	}
	else if(oldteam == 2 || oldteam == 3)
	{
		if(BR_RoundStart && BR_Round >= 1)
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue; 
}


//--------------------------
// Player Spawns Into Game |
//--------------------------

public Action:event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsPlayerInZone[4][client])
	{
		IsPlayerInZone[4][client] = false;
	}
	
	if(!WorldRecordsLoaded)
	{
		//Load World Records
		LoadWorldRecords(Map[MapName]);
	}
	
	CreateTimer(0.0, RemoveRadar, client);
	
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	
	//CS_SetClientContributionScore(client, RoundToFloor(g_info[client][BRPoints]));
	
	decl String:AuthID[32];
	GetClientAuthString(client, AuthID, sizeof(AuthID));

	SetEntPropString(client, Prop_Send, "m_szArmsModel", "models/player/paradise/hands/default/paradise_hands.mdl");
	
	if(g_bViewModel[client])
	{
		g_bViewModel[client]=true;
		Client_SetDrawViewModel(client,true);
	}
	else if(!g_bViewModel[client])
	{
		g_bViewModel[client]=false;
		Client_SetDrawViewModel(client,false);
	}
	
	//Player's Timer = Disabled
	g_timers[client][Enabled] = false;
	g_timers[client][Bonus] = false;
	
	if(!IsFakeClient(client))
	{
		//Player Missing Level
		if(g_info[client][Level] == 0 && ClientDataLoaded[client])
		{
			LoadPlayerData(client);
		}
		
		//Player Records Never Loaded
		if(!ClientRecordsLoaded[client] && StrEqual(g_info[client][Status], "INVALID", true))
		{
			LoadPlayerRecords(client, Map[MapName]);
		}
		
		//Player Missing Style
		if(g_info[client][Style] == 0 && BR_RoundStart)
		{
			ClientCommand(client, "sm_style");
		}

		SetLevelTag(client);
	}
	
	//Style = Parkour
	if(g_info[client][Style] == 4)
	{
		SetEntityGravity(client, 0.9);
	}
	else
	{
		SetEntityGravity(client, 0.99);
	}
	
	//Set Custom Player Model
	if(VIP_Player[client] && strlen(g_vip[client][Model]) > 0)
	{
		//SetPlayerModel
		SetEntityModel(client, g_vip[client][Model]);
	}
	else if(IsFakeClient(client))
	{
		//SetPlayerModel
		SetEntityModel(client, "models/player/paradise/eve/eve.mdl");
	}
	
	if((g_ZonesLoaded) && g_ZoneExists[0])
		TeleportToZone(client, 0);
	
	ResetCounters(client);
	
	//Player Round Check-In
	if((!BR_Warmup) && (!BR_RoundStart) && BR_Round > 0 && !IsFakeClient(client))
	{
		//Freeze Player
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
		
		//HUD Display
		SetClientOverlay(client, "effects/loading2.vmt");
		ClientCommand(client, "br_hidehud");

		//Retrieve Player Count
		if(!BR_MOStart && IsPlayerAlive(client))
		{
			BR_PlayerCount = 0;
			
			for(new h = 0; h <= 28; h++)
			{
				for(new k = 1; k <= MaxClients; k++)
				{
					if(IsValidClient(k, true) && !IsFakeClient(k))
					{
						decl String:CLID[64];
						GetClientAuthString(k, CLID, sizeof(CLID));
						
						if(StrEqual(AuthPlayer[h][AuthSID], CLID))
						{
							BR_PlayerCount++;
							
							FakeClientCommand(k, "sm_scvolume 10");
							
							break;
						}
					}
				}
				
			}
			
			//If First Player To Join, Start Round Check-In
			if(BR_PlayerCount == 1 && !BR_CheckIn)
			{
				BR_CheckIn = true;
				
				//Start Round Check-In Timer
				LogMessage("[Paradise] Round Check-In has started! Round will begin when all players connect, or after 3 min.");
				
				CreateTimer(180.0, RoundCheckIn);
			}
			
			//Check If All Players Ready, If So Start Round
			if(BR_CheckIn && !BR_MOLoaded)
			{
				new ActivePlayers = 0;
				new ReadyPlayers = 0;
				
				for(new i = 0; i <= 28; i++)
				{
					if(AuthPlayer[i][CheckedIn])
					{
						if(AuthPlayer[i][PlayerReady])
						{
							ReadyPlayers++;
						}
						
						ActivePlayers++;
					}
				}
				
				PrintToConsole(client, "%i/%i Players In Game.", ReadyPlayers, ActivePlayers);
				
				//All Players Ready, Start Round.
				if(ReadyPlayers == ActivePlayers)
				{
					if(!BR_Results)
					{
						PrintToChatAll(" \x01\x06[Paradise] \x01All Players Have Connected! Launching Map..");
						
						CreateTimer(10.0, LaunchMO);
						BR_MOLoaded = true;
					}
					else
					{
						CreateTimer(5.0, LaunchWinners);
						BR_Results = false;
						BR_MOLoaded = true;
					}
				}
			}
		}
	}
}

public Action:RoundCheckIn(Handle:timer)
{
	//Not All Players Connected, Automatically Start Round.
	if(BR_CheckIn && !BR_MOLoaded)
	{
		PrintToChatAll("[Paradise] Round Check-In is now over. Players that didn't connect have now been disqualified!.");
		
		for(new f = 0; f <= 28; f++)
		{
			//Player Didn't Connect In Time, DQ Player.
			if(AuthPlayer[f][CheckedIn] && (!AuthPlayer[f][PlayerReady]))
			{
				if(f < 25)
				{
					PrintToChatAll(" \x01\x07Player \x01%s \x01has been disqualified! \x01\x07(Reason: Failure To Check-In)", AuthPlayer[f][AuthName]);
					AuthPlayer[f][CheckedIn] = false;
				}
			}
		}
		
		//Check If All Players Ready, If So Start Round
		new ActivePlayers = 0;
		new ReadyPlayers = 0;
		
		for(new i = 0; i <= 28; i++)
		{
			if(AuthPlayer[i][CheckedIn])
			{
				if(AuthPlayer[i][PlayerReady])
				{
					ReadyPlayers++;
				}
				
				ActivePlayers++;
			}
		}
		
		//All Players Ready, Start Round.
		if(ReadyPlayers == ActivePlayers)
		{
			if(!BR_Results)
			{
				PrintToChatAll(" \x01\x06[Paradise] \x01All Players Have Connected! Launching Map..");
				
				CreateTimer(10.0, LaunchMO);
				BR_MOLoaded = true;
			}
			else
			{
				CreateTimer(5.0, LaunchWinners);
				BR_Results = false;
				BR_MOLoaded = true;
			}
		}
	}
	
	return Plugin_Stop;
}

public Action:LaunchMO(Handle:timer)
{
	new g_EVEBot = -1;
	
	switch(BR_Round)
	{
		case 1:{ ServerCommand("sm_scall Worldwar - Cinematic - Aexi0n");}
		//case 2:{ ServerCommand("sm_scall Spongebob - Cinematic - Aexi0n");}
		//case 3:{ ServerCommand("sm_scall Peachrace - Cinematic - Aexi0n");}
		case 4:{ ServerCommand("sm_scall Pillars - Cinematic - Aexi0n");}
	}
				
	decl String:EVEName[MAX_NAME_LENGTH];

	for(new j = 1; j <= MaxClients; j++)
	{
		if(IsClientInGame(j) && IsFakeClient(j) && GetClientTeam(j) >= CS_TEAM_T)
		{
			g_EVEBot = j;
			GetClientName(g_EVEBot, EVEName, MAX_NAME_LENGTH);
			
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
		}
	}

	for(new h = 1; h <= MaxClients; h++)
	{
		if(IsValidClient(h) && !IsFakeClient(h))
		{
			decl String:CLID[64];
			GetClientAuthString(h, CLID, sizeof(CLID));
			
			if(!StrEqual(CLID, "STEAM_1:1:46996013"))
			{
				ChangeClientTeam(h, 1);
				Client_SetObserverMode(h, OBS_MODE_IN_EYE, true);
				SetClientOverlay(h, "pp/tv2.vmt");
			}
		}
	}

	decl String:sPath[PLATFORM_MAX_PATH];

	SetEntPropFloat(g_EVEBot, Prop_Data, "m_flLaggedMovementValue", 0.4);

	Format(sPath, sizeof(sPath), "%sWR-8", Map[MapName]);

	BotMimic_PlayRecordByName(g_EVEBot, sPath);
	
	return Plugin_Stop;
}

public Action:LaunchWinners(Handle:timer)
{
	new g_EVEBot = -1;
				
	decl String:EVEName[MAX_NAME_LENGTH];

	for(new j = 1; j <= MaxClients; j++)
	{
		if(IsClientInGame(j) && IsFakeClient(j) && GetClientTeam(j) >= CS_TEAM_T)
		{
			g_EVEBot = j;
			GetClientName(g_EVEBot, EVEName, MAX_NAME_LENGTH);
			
			if(!IsPlayerAlive(g_EVEBot))
			{
				CS_RespawnPlayer(g_EVEBot);
			}
		}
	}

	for(new h = 1; h <= MaxClients; h++)
	{
		if(IsValidClient(h) && !IsFakeClient(h))
		{
			ChangeClientTeam(h, 1);
			Client_SetObserverMode(h, OBS_MODE_IN_EYE, true);
			SetClientOverlay(h, "none");
		}
	}
	
	decl Float:pOrigin[3], Float:pAngle[3];
	
	pOrigin[0] = 3415.307129;
	pOrigin[1] = 1014.757629;
	pOrigin[2] = 544.093811;
	
	pAngle[0] = -8.867255;
	pAngle[1] = 0.539074;
	pAngle[2] = 0.000000;
	
	TeleportEntity(g_EVEBot, pOrigin, pAngle, NULL_VECTOR); 

	SetEntPropFloat(g_EVEBot, Prop_Data, "m_flLaggedMovementValue", 0.0);

	PrintToChatAll(" \x01\x03[EVE]: \x01\x06Now To Announce The Winners Of The Summer 2016 Bunnyhop Battle Royale...");
	PrintToChatAll("  ");
	
	CreateTimer(10.0, Announce_Results, _, TIMER_REPEAT);
	
	return Plugin_Stop;
}

public Action:Announce_Results(Handle:timer)
{
	static numCount = 3;
	
	if(numCount == 3)
	{
		new rank1 = 0, rank2 = 0, rank3 = 0, rank4 = 0, rank5 = 0;
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(g_info[i][BRPoints] > 0.0)
			{
				if(g_info[i][BRPoints] > g_info[rank1][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = rank2;
					rank2 = rank1;
					rank1 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank2][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = rank2;
					rank2 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank3][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank4][BRPoints])
				{
					rank5 = rank4;
					rank4 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank5][BRPoints])
				{
					rank5 = i;
				}
			}
		}
		
		PrintToChatAll("");
		PrintToChatAll("");
		PrintToChatAll(" \x01\x10Third Place Goes To..\x01 %N \x01\x10with \x01 %f \x01\x10Points!", rank3, g_info[rank3][BRPoints]);

		decl Float:pOrigin[3], Float:pAngle[3];
		
		pOrigin[0] = 3188.061279;
		pOrigin[1] = 2374.949707;
		pOrigin[2] = 292.093811;

		pAngle[0] = 85.092812;
		pAngle[1] = 178.901642;
		pAngle[2] = 0.000000;

		new fakeclient3 = CreateFakeClient("FakeClient");
		ChangeClientTeam(fakeclient3, 2); 
		DispatchKeyValue(fakeclient3,"classname","fakeclient"); 
		DispatchSpawn(fakeclient3);

		CS_RespawnPlayer(fakeclient3);
			
		TeleportEntity(fakeclient3, pOrigin, pAngle, NULL_VECTOR);
			
		SetEntPropFloat(fakeclient3, Prop_Data, "m_flLaggedMovementValue", 0.0);

		decl String:CrowdCheerSND[128];
		Format(CrowdCheerSND, 128, "%s/battle-royale/br_crowd_cheer.mp3", RELATIVE_SOUND_PATH);
		EmitSoundToAll(CrowdCheerSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
	}
	else if(numCount == 2)
	{
		new rank1 = 0, rank2 = 0, rank3 = 0, rank4 = 0, rank5 = 0;
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(g_info[i][BRPoints] > 0.0)
			{
				if(g_info[i][BRPoints] > g_info[rank1][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = rank2;
					rank2 = rank1;
					rank1 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank2][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = rank2;
					rank2 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank3][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank4][BRPoints])
				{
					rank5 = rank4;
					rank4 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank5][BRPoints])
				{
					rank5 = i;
				}
			}
		}
		
		PrintToChatAll("");
		PrintToChatAll("");
		PrintToChatAll(" \x01\x08Second Place Goes To..\x01 %N \x01\x08with \x01 %f \x01\x08Points!", rank2, g_info[rank2][BRPoints]);
			
		decl Float:pOrigin[3], Float:pAngle[3];

		pOrigin[0] = 3203.708008;
		pOrigin[1] = 2238.520264;
		pOrigin[2] = 422.349823;
			
		pAngle[0] = 2.715898;
		pAngle[1] = -178.216812;
		pAngle[2] = 0.000000;
			
		new fakeclient2 = CreateFakeClient("FakeClient");
		ChangeClientTeam(fakeclient2, 2); 
		DispatchKeyValue(fakeclient2,"classname","fakeclient"); 
		DispatchSpawn(fakeclient2);

		CS_RespawnPlayer(fakeclient2);
			
		TeleportEntity(fakeclient2, pOrigin, pAngle, NULL_VECTOR);
			
		SetEntPropFloat(fakeclient2, Prop_Data, "m_flLaggedMovementValue", 0.0);

		decl String:CrowdCheerSND[128];
		Format(CrowdCheerSND, 128, "%s/battle-royale/br_crowd_cheer.mp3", RELATIVE_SOUND_PATH);
		EmitSoundToAll(CrowdCheerSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
	}
	else if(numCount == 1)
	{
		PrintToChatAll("");
		PrintToChatAll("");
		PrintToChatAll(" \x01\x09The Winner Of The Summer 2016 Bunnyhop Battle Royale Is... ");
		
		decl String:DrumRollSND[128];
		Format(DrumRollSND, 128, "%s/battle-royale/br_drum_roll.mp3", RELATIVE_SOUND_PATH);
		EmitSoundToAll(DrumRollSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
	}
	else if(numCount == 0)
	{
		new rank1 = 0, rank2 = 0, rank3 = 0, rank4 = 0, rank5 = 0;
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(g_info[i][BRPoints] > 0.0)
			{
				if(g_info[i][BRPoints] > g_info[rank1][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = rank2;
					rank2 = rank1;
					rank1 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank2][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = rank2;
					rank2 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank3][BRPoints])
				{
					rank5 = rank4;
					rank4 = rank3;
					rank3 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank4][BRPoints])
				{
					rank5 = rank4;
					rank4 = i;
				}
				else if(g_info[i][BRPoints] > g_info[rank5][BRPoints])
				{
					rank5 = i;
				}
			}
		}
		
		PrintToChatAll(" \x01\x09★ ★ ★ \x01 %N\x01\x09 WITH \x01%f \x01\x09 POINTS! ★ ★ ★", rank1, g_info[rank1][BRPoints]);

		decl Float:pOrigin[3], Float:pAngle[3];
		
		pOrigin[0] = 3205.136475;
		pOrigin[1] = 2308.897461;
		pOrigin[2] = 456.093811;

		pAngle[0] = 3.144897;
		pAngle[1] = -0.552479;
		pAngle[2] = 0.000000;

		new fakeclient1 = CreateFakeClient("FakeClient");
		ChangeClientTeam(fakeclient1, 2); 
		DispatchKeyValue(fakeclient1,"classname","fakeclient"); 
		DispatchSpawn(fakeclient1);

		CS_RespawnPlayer(fakeclient1);
			
		TeleportEntity(fakeclient1, pOrigin, pAngle, NULL_VECTOR);
			
		SetEntPropFloat(fakeclient1, Prop_Data, "m_flLaggedMovementValue", 0.0);


		decl String:CrowdCheer2SND[128];
		Format(CrowdCheer2SND, 128, "%s/battle-royale/br_crowd_cheer_2.mp3", RELATIVE_SOUND_PATH);
		EmitSoundToAll(CrowdCheer2SND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);

		ServerCommand("sm_scall Dj kool - Let Me Clear My Throat");
	}
	else if(numCount == -1)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i, false) && !IsFakeClient(i))
			{
				GivePlayerXP(i, 10000);
			}
		}
		
		PrintToChatAll("  ");
		PrintToChatAll("  ");
		PrintToChatAll(" \x01\x06THANK YOU ALL FOR BEING A PART OF THE SUMMER 2016 BUNNYHOP BATTLE ROYALE!");
		PrintToChatAll("  ");
		PrintToChatAll(" \x01\x03Everyone has received +10,000 XP \x01For Playing In The Event!");
		PrintToChatAll("  ");
		PrintToChatAll(" \x01\x03Now It's Time To.. ");
		
		BR_RoundStart = true;
	}
	else if(numCount == -2)
	{
		for (new i = 1; i <= 12; i++)
		{
			PrintToChatAll(" \x01\x07*** \x01\x09CE\x01\x05LE\x01\x06BR\x01\x0BAT\x01\x0EE!\x01\x03***");
		}
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i, false) && !IsFakeClient(i))
			{
				new iRed, iBlue;
				for(new j = 1; j <= MaxClients; j++)
				{
					if(!IsClientInGame(j))
						continue;

					new iTeam = GetClientTeam(j);
					if(iTeam == CS_TEAM_T)
						iRed++;
					else if(iTeam == CS_TEAM_CT)
						iBlue++;
				}

				if(iRed < iBlue)
					ChangeClientTeam(i, 2);
				else
					ChangeClientTeam(i, 3);	
				
				ServerCommand("sv_party_mode 1");
				
				SetClientOverlay(i, "none");
				
				FakeClientCommand(i, "br_showhud");
				
				FakeClientCommand(i, "sm_l5rwQnYf");
				
				CS_RespawnPlayer(i);
				
				GivePlayerItem(i, "weapon_taser");
				
				FakeClientCommand(i, "use weapon_taser");
				
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			}
		}
		
		CreateTimer(7.0, Event_Credits, _, TIMER_REPEAT);
		
		numCount = 3;
		
		return Plugin_Stop;
	}
	
	
	numCount--;
	
	return Plugin_Continue;
}


//------------------
// Player Has Died |
//------------------

public event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!IsFakeClient(client) && BR_RoundStart && BR_Round >= 1)
	{
		CS_RespawnPlayer(client);
	}
}


//------------------------
// Player Using Commands |
//------------------------

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	if(!IsValidClient(client,false))
		return Plugin_Continue;
		
	if(IsPlayerAlive(client))
	{
		//Show Keys
		g_iButtonsPressed[client] = buttons;
		
		//Auto Bhop
		AutoBhop(client, buttons);
		
		//Strafe Sync
		CheckSync(client, buttons, vel, angles);
		
		//Angle Style Check
		if(g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
		{
			AngleMoves(client, buttons, impulse, vel, angles, weapon, subtype, cmdnum, tickcount, seed, mouse);
		}
		else
		{
			CountStrafes(client, buttons);
		}
		
		switch(g_info[client][Style])
		{
			//Legit
			case 2:
			{
				ScriptCheck(client, buttons, impulse, vel, angles, weapon);
				//SetEntityFlags(client, GetEntityFlags(client) | FL_ONGROUND);
			}
			//Parkour
			case 4:
			{
				ParkourMoves(client, buttons, impulse, vel, angles, weapon);
			}
		}
		
		if(IsPlayerInZone[0][client] || IsPlayerInZone[2][client])
		{
			if(g_info[client][Style] < 3 || g_info[client][Style] > 4)
			{
				buttons &= ~IN_JUMP;
			}
		}
	}
	
	return Plugin_Continue;
}


//----------------------
// Player Jumps In Air |
//----------------------

public Action:event_PlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	PB_JumpCheck(client);
	
	if(g_timers[client][Enabled])
	{
		g_info[client][Jumps]++;
	}
	
	if(IsPlayerInZone[0][client] || IsPlayerInZone[2][client])
	{
		if(g_info[client][Style] == 1 || g_info[client][Style] == 2 || g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
		{
			CreateTimer(0.01, DelayedSlowDown, client);
		}
	}

	return Plugin_Continue;
}

public Action:DelayedSlowDown(Handle:timer, any:client)
{
	LimitVelocity(client, 300.0);
}

//----------------------------
// Player Sends Chat Message |
//----------------------------

public Action:HookPlayerChat(client, const String:command[], args)
{

	decl String:szText[256];
	GetCmdArg(1, szText, sizeof(szText));
	
	if ( szText[0] == EOS)
	{
		return Plugin_Handled;
	}
	else if((szText[0] == '!') || (szText[0] == '/'))
	{
		if(IsCharUpper(szText[1]))
		{
			for(new i = 0; i <= strlen(szText); ++i)
			{
				szText[i] = CharToLower(szText[i]);
			}

			FakeClientCommand(client, "say %s", szText);
			return Plugin_Handled;
		}
	}
	else if(StrEqual(szText, "rtv", false))
	{
		FakeClientCommand(client, "say !rtv", szText);
	}
	else
	{
		if(IsValidClient(client, false))
		{
			if(bType:SourceComms_GetClientGagType(client) == bNot)
			{
				if(CheckCommandAccess(client, "sm_flag", ADMFLAG_GENERIC, true))
				{
					PrintToChatAll(" \x01\x06[Event Staff] \x01%N: %s", client, szText);
				}
				else
				{
					PrintToChatAll(" \x01\x09[★] \x01%N: %s", client, szText);
				}
			}
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}


//-----------------------
// Player HUD Interface |
//-----------------------

public Action:HUD(Handle:timer)
{
	decl Float:fVelocity[3];
	decl String:PlayerTime[10], String:TimeColor[15];
	new Float:currentspeed, Float:currenttime;
	
	if(IsValidClient(BR_Caster1, false) && IsClientObserver(BR_Caster1) && (BR_RoundStart || BR_Round < 1))
	{
		new iSpecMode = GetEntProp(BR_Caster1, Prop_Send, "m_iObserverMode");
		new iTarget = GetEntPropEnt(BR_Caster1, Prop_Send, "m_hObserverTarget");
		
		if(IsValidClient(BR_Caster2, false))
		{
			SetEntProp(BR_Caster2, Prop_Send, "m_iObserverMode", iSpecMode);
			SetEntPropEnt(BR_Caster2, Prop_Send, "m_hObserverTarget", iTarget);
		}
		
		if(IsValidClient(BR_Stream, false))
		{
			SetEntProp(BR_Stream, Prop_Send, "m_iObserverMode", iSpecMode);
			SetEntPropEnt(BR_Stream, Prop_Send, "m_hObserverTarget", iTarget);
		}
	}
	
	for(new i = 1; i <= MaxClients; i++)
    { 
        if(IsClientInGame(i))
        {
			if(IsPlayerAlive(i))
			{
				decl String:Line1[255], String:Line2[255], String:Line3[255], String:StyleMode[32], String:PB[10];
				
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", fVelocity);
				currentspeed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
				currenttime = GetEngineTime() - g_timers[i][StartTime];
				
				Format(StyleMode, 32, "None");
				Format(TimeColor, 32, "#8847ff'>");
				
				switch(g_info[i][Style])
				{
					case 1:
					{
						Format(StyleMode, 32, "Auto"); 
						FormatPlayerTime(g_info[i][Auto], PB, 10, false, 1);
						
						if(currenttime > Auto_WR[Time] && Auto_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 2:
					{
						Format(StyleMode, 32, "Legit"); 
						FormatPlayerTime(g_info[i][Legit], PB, 10, false, 1);
						
						if(currenttime > Legit_WR[Time] && Legit_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 3:
					{
						Format(StyleMode, 32, "Freestyle"); 
						FormatPlayerTime(g_info[i][Freestyle], PB, 10, false, 1);
						
						if(currenttime > Freestyle_WR[Time] && Freestyle_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 4:
					{
						Format(StyleMode, 32, "Parkour"); 
						FormatPlayerTime(g_info[i][Parkour], PB, 10, false, 1);
						
						if(currenttime > Parkour_WR[Time] && Parkour_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 5:
					{
						Format(StyleMode, 32, "HSW"); 
						FormatPlayerTime(g_info[i][HalfSideways], PB, 10, false, 1);
						
						if(currenttime > HalfSideways_WR[Time] && HalfSideways_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 6:
					{
						Format(StyleMode, 32, "SW"); 
						FormatPlayerTime(g_info[i][Sideways], PB, 10, false, 1);
						
						if(currenttime > Sideways_WR[Time] && Sideways_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
					case 7:
					{
						Format(StyleMode, 32, "WO"); 
						FormatPlayerTime(g_info[i][WOnly], PB, 10, false, 1);
						
						if(currenttime > WOnly_WR[Time] && WOnly_WR[Time] > 0.0)
						{	
							if(BotMimic_IsPlayerRecording(i))
							{
								BotMimic_StopRecording(i, false);
							}
							
							Format(TimeColor, 32, "#10bf9c'>");
						}
					}
				}
				
				if(!g_timers[i][Enabled])
				{			
					decl String:ClientName[255];
					
					GetClientName(i, ClientName, 255);
					new len = strlen(ClientName);
					
					if(len > 9)
					{
						ClientName[8] = '\0';

						Format(ClientName, sizeof(ClientName), "%s..", ClientName);
					}

					PrintHintText(i, "<font size='19'><font color='#8847ff'> [Lv. %d]</font> %s   \n XP: <font color='#FF1D8E'>%d/%d</font> \n Style: <font color='#ff0000'>%s</font> | Speed: <font color='#10bf9c'>%.0f</font></font>", g_info[i][Level], ClientName, g_info[i][XP], g_info[i][XP_Needed], StyleMode, currentspeed); 
				}
				else
				{
					decl Float:Sync, iButtons, String:W[10], String:A[10], String:S[10], String:D[10];
					
					iButtons = g_iButtonsPressed[i];
				
					if(iButtons & IN_FORWARD)
						Format(W, 10, "  W    ");
					else
						Format(W, 10, "            ");
					
					if(iButtons & IN_MOVELEFT)
						Format(A, 10, "A");
					else
						Format(A, 10, "   ");
						
					if(iButtons & IN_BACK)
						Format(S, 10, "S");
					else
						Format(S, 10, "   ");
						
					if(iButtons & IN_MOVERIGHT)
						Format(D, 10, "D");
					else
						Format(D, 10, "   ");
						
					FormatPlayerTime(currenttime, PlayerTime, 10, false, 2);
					
					Sync = 0.0;
					
					Sync = GetClientSync(i);
					Spectators[i] = 0;
					
					for(new j = 1; j <= MaxClients; j++) 
					{
						if (!IsClientInGame(j) || !IsClientObserver(j))
							continue;
							
						new iSpecMode = GetEntProp(j, Prop_Send, "m_iObserverMode");
						
						// The client isn't spectating any one person, so ignore them.
						if (iSpecMode != 4 && iSpecMode != 5)
							continue;
						
						// Find out who the client is spectating.
						new iTarget = GetEntPropEnt(j, Prop_Send, "m_hObserverTarget");
						
						// Are they spectating our player?
						if (iTarget == i)
						{
							Spectators[i]++;
						}
					}
					
					Format(Line1, sizeof(Line1), "Time: <font color='%s%s</font> \n", TimeColor, PlayerTime);
					
					if(g_info[i][Style] == 7)
					{
						Format(Line2, sizeof(Line2), "%s--<b>/</b> %.0f u/s  \n", W, currentspeed);
					}
					else
					{
						Format(Line2, sizeof(Line2), "%s%.0f%% <b>/</b> %.0f u/s  \n", W, Sync, currentspeed);
					}
					
					Format(Line3, sizeof(Line3), "%s%s%s       Style: <font color='#FF1D8E'>%s</font>", A, S, D, StyleMode);
					
					PrintHintText(i, "<font size='19'>%s %s %s</font>", Line1, Line2, Line3);
				}
			}
			else if(IsClientObserver(i))
			{
				new iSpecModeUser = GetEntProp(i, Prop_Send, "m_iObserverMode");
				
				if(iSpecModeUser == 4 || iSpecModeUser == 5)
				{
					new iTargetUser = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
					
					decl String:Line1[255], String:Line2[255], String:Line3[255], String:StyleMode[64];
				
					if(iTargetUser >= 0 || iTargetUser <= (MAXPLAYERS+1))
					{
						if(IsValidClient(iTargetUser, false))
						{
							if(IsFakeClient(iTargetUser))
							{
								
							}
							else
							{
								GetEntPropVector(iTargetUser, Prop_Data, "m_vecVelocity", fVelocity);
								
								currentspeed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
								currenttime = GetEngineTime() - g_timers[iTargetUser][StartTime];
								
								Format(StyleMode, 64, "None");
								
								switch(g_info[iTargetUser][Style])
								{
									case 1:
									{
										Format(StyleMode, 64, "Auto");
										
										if(currenttime > Auto_WR[Time] && Auto_WR[Time] > 0.0)
										{
											Format(TimeColor, 32, "#10bf9c'>");
										}
									}
									case 2:
									{
										Format(StyleMode, 64, "Legit");
															
										if(currenttime > Legit_WR[Time] && Legit_WR[Time] > 0.0)
										{
											Format(TimeColor, 32, "#10bf9c'>");
										}
									}
									case 3:
									{
										Format(StyleMode, 64, "Freestyle");
																			
										if(currenttime > Freestyle_WR[Time] && Freestyle_WR[Time] > 0.0)
										{
											Format(TimeColor, 32, "#10bf9c'>");
										}
									}
									case 4:
									{
										Format(StyleMode, 64, "Parkour");
																				
										if(currenttime > Parkour_WR[Time] && Parkour_WR[Time] > 0.0)
										{
											Format(TimeColor, 32, "#10bf9c'>");
										}
									}
									case 5:
									{
										Format(StyleMode, 64, "HSW");
																
										if(currenttime > HalfSideways_WR[Time] && HalfSideways_WR[Time] > 0.0)
										{
											Format(TimeColor, 32, "#10bf9c'>");
										}
									}
									case 6:
									{
										Format(StyleMode, 64, "SW");
										
										if(currenttime > Sideways_WR[Time] && Sideways_WR[Time] > 0.0)
										{
											Format(TimeColor, 32, "#10bf9c'>");
										}
									}
									case 7:
									{
										Format(StyleMode, 64, "WO");
										
										if(currenttime > WOnly_WR[Time] && WOnly_WR[Time] > 0.0)
										{
											Format(TimeColor, 32, "#10bf9c'>");
										}
									}
								}
								
								if(!g_timers[iTargetUser][Enabled] && IsValidClient(i, false))
								{			
									PrintHintText(i, "<font size='19'><font color='#8847ff'> [Lv. %d]</font> %N   \n Speed: <font color='#10bf9c'>%.0f u/s</font> \n Style: <font color='#FF1D8E'>%s</font></font>", g_info[iTargetUser][Level], iTargetUser, currentspeed, StyleMode); 
								}
								else
								{
									decl Float:Sync, iButtons, String:W[10], String:A[10], String:S[10], String:D[10];
									
									iButtons = g_iButtonsPressed[iTargetUser];
								
									if(iButtons & IN_FORWARD)
										Format(W, 10, "  W    ");
									else
										Format(W, 10, "            ");
									
									if(iButtons & IN_MOVELEFT)
										Format(A, 10, "A");
									else
										Format(A, 10, "   ");
										
									if(iButtons & IN_BACK)
										Format(S, 10, "S");
									else
										Format(S, 10, "   ");
										
									if(iButtons & IN_MOVERIGHT)
										Format(D, 10, "D");
									else
										Format(D, 10, "   ");
										
									FormatPlayerTime(currenttime, PlayerTime, 10, false, 2);
									
									Sync = 0.0;
									
									Sync = GetClientSync(iTargetUser);
									Spectators[iTargetUser] = 0;
									
									Format(Line1, sizeof(Line1), "Time: <font color='%s%s</font> \n", TimeColor, PlayerTime);
									
									if(g_info[iTargetUser][Style] >= 5)
									{
										Format(Line2, sizeof(Line2), "%s--<b>/</b> %.0f u/s  \n", W, currentspeed);
									}
									else
									{
										Format(Line2, sizeof(Line2), "%s%.0f%% <b>/</b> %.0f u/s  \n", W, Sync, currentspeed);
									}
								
									Format(Line3, sizeof(Line3), "%s%s%s       Style: <font color='#FF1D8E'>%s</font>", A, S, D, StyleMode);
									
									PrintHintText(i, "<font size='19'>%s %s %s</font>", Line1, Line2, Line3);
								}
							}
						}
					}
				}
			}
        }
    } 
}


//-----------------------
// Player On Game Frame |
//-----------------------

public OnGameFrame()
{
	SecurityFrameCheck();
	
	CreateZones();
	
	if(ZoneFrameRepeat == 1)
	{
		if(ZoneFrame < 3)
		{
			ZoneFrame++;
			ZoneFrameRepeat--;
		}
		else if(ZoneFrame == 3)
		{
			ZoneFrame = 0;
			ZoneFrameRepeat--;
		}
	}
	else
	{
		ZoneFrameRepeat++;
	}
	
	if(!GetEntProp(g_iGameRulesEnt, Prop_Send, "m_bWarmupPeriod"))
	{
		EngineTime = GetEngineTime();
		
		new MapTimeLeft;
		
		//Get The Current Time Remaining (In Seconds)
		GetMapTimeLeft(MapTimeLeft);
		
		if(BR_RoundStart)
		{
			MapTimeLeft = MapTimeLeft + BR_MOTime;
		}
		
		//Map Ending
		if(MapTimeLeft == 0 && !MapEnding)
		{
			EndMap();
			//PrintToChatAll("Map Should Fucking End Now");
			MapEnding = true;
		}
		
		//EVE Timeleft System
		if(EngineTime >= (SavedTime + 60.0))
		{
			TimeLeft = TimeLeft - 1;
			SavedTime = EngineTime;
			
			MinutePassed();
			
			if(TimeLeft == 0)
			{
				if(EngineTime >= (InitTime + (float(5) * 60.0)))
				{
					if(!MapEnding && MapTimeLeft <= -1)
					{
						MapEnding = true;
						m_Extend = false;
						EndMap();
					}
				}
			}
			
			if(TimeLeft == -1 && !MapEnding)
			{
				MapEnding = true;
				m_Extend = false;
				EndMap();
			}
		}
	}
}



/* Paradise Timer Functions
**
** Functions: Start | Stop | Finish | MapComplete | WRCelebration
** -------------------------------------------------------------------------- */

// Start Timer
public StartTimer(client)
{	
	if(ClientDataLoaded[client])
	{
		g_timers[client][Enabled] = true;
		g_timers[client][StartTime] = GetEngineTime();
		g_timers[client][EndTime] = -1.0;
		TotalSync[client] = 0;
		GoodSync[client] = 0;
		
		ResetCounters(client);
		
		//Save PreSpeed Value for Freestyle & Parkour
		if(g_info[client][Style] == 3 || g_info[client][Style] == 4)
		{
			decl Float:fVelocity[3];
			
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
			g_info[client][PreSpeed] = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
		}
	}
	else
	{
		PrintToChat(client, "Please Wait.. Loading Player Data");
		
		if(StrEqual(g_info[client][Status], "INVALID"))
		{
			LoadPlayerData(client);
		}
	}
}

//Stop Timer
public StopTimer(client)
{
	g_timers[client][Enabled] = false;
	g_timers[client][StartTime] = 0.0;
	g_timers[client][Bonus] = false;
	TotalSync[client] = 0;
	GoodSync[client] = 0;
	
	ResetCounters(client);
}

//Finish Timer
public FinishTimer(client)
{
	g_timers[client][EndTime] = GetEngineTime() - g_timers[client][StartTime];
	StopTimer(client);
}

//Map Completed
public MapComplete(client, style, Float:time, jumps, strafes, Float:sync, Float:prespeed, wallruns, walljumps)
{
	decl String:StyleName[32], String:ImproveTime[32];
	decl Float:improve;
	new calcXP;
	
	calcXP = Map[XPValue];
	improve = 0.0;
	
	decl String:replaypath[50];
	Format(replaypath, 50, "World Records/%s/%sWR-%i.rec", Map[MapName], Map[MapName], g_info[client][Style]);

	switch(style)
	{
		//Finished Map On Auto
		case 1:
		{
			Format(StyleName, 32, "Auto");
			
			if(time < g_info[client][Auto] || g_info[client][Auto] == 0.0) //Right Now 0.0..?
			{	
				//Save Player Record
				if(g_info[client][Auto] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = (g_info[client][Auto] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Auto] = time;

				if(time <= Auto_WR[Time] || Auto_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					Auto_WR[Time] = time;
					GetClientName(client, Auto_WR[PlayerName], MAX_NAME_LENGTH);
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
			
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Legit
		case 2:
		{
			Format(StyleName, 32, "Legit");
			
			if(time < g_info[client][Legit] || g_info[client][Legit] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][Legit] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = (g_info[client][Legit] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Legit] = time;

				if(time <= Legit_WR[Time] || Legit_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					Legit_WR[Time] = time;
					GetClientName(client, Legit_WR[PlayerName], MAX_NAME_LENGTH);
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for Legit Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Freestyle
		case 3:
		{
			Format(StyleName, 32, "Freestyle");
			
			if(time < g_info[client][Freestyle] || g_info[client][Freestyle] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				BotMimic_DeleteRecord(replaypath);
				if(g_info[client][Freestyle] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = (g_info[client][Freestyle] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Freestyle] = time;

				if(time <= Freestyle_WR[Time] || Freestyle_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					Freestyle_WR[Time] = time;
					GetClientName(client, Freestyle_WR[PlayerName], MAX_NAME_LENGTH);
					
					calcXP *= 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Parkour
		case 4:
		{
			calcXP = (calcXP / 2);
			
			Format(StyleName, 32, "Parkour");
			
			if(time < g_info[client][Parkour] || g_info[client][Parkour] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][Parkour] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = (g_info[client][Parkour] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Parkour] = time;

				if(time <= Parkour_WR[Time] || Parkour_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					Parkour_WR[Time] = time;
					GetClientName(client, Parkour_WR[PlayerName], MAX_NAME_LENGTH);
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Half-Sideways
		case 5:
		{
			Format(StyleName, 32, "Half-Sideways");
			
			if(time < g_info[client][HalfSideways] || g_info[client][HalfSideways] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][HalfSideways] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = (g_info[client][HalfSideways] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][HalfSideways] = time;

				if(time <= HalfSideways_WR[Time] || HalfSideways_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					HalfSideways_WR[Time] = time;
					GetClientName(client, HalfSideways_WR[PlayerName], MAX_NAME_LENGTH);
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for HSW Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On Sideways
		case 6:
		{	
			Format(StyleName, 32, "Sideways");
			
			if(time < g_info[client][Sideways] || g_info[client][Sideways] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][Sideways] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = (g_info[client][Sideways] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][Sideways] = time;

				if(time <= Sideways_WR[Time] || Sideways_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					Sideways_WR[Time] = time;
					GetClientName(client, Sideways_WR[PlayerName], MAX_NAME_LENGTH);
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for Sideways Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
		//Finished Map On W-Only
		case 7:
		{
			calcXP = (calcXP / 2);
			
			Format(StyleName, 32, "W-Only");
			
			if(time < g_info[client][WOnly] || g_info[client][WOnly] == 0.0) //Right Now 0.0..?
			{
				//Save Player Record
				if(g_info[client][WOnly] == 0.0)
				{
					CreateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = 0.0;
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				else
				{
					UpdateRecord(client, Map[MapName], StyleName, time, jumps, strafes, sync, prespeed, wallruns, walljumps);
					improve = (g_info[client][WOnly] - time);
					FormatPlayerTime(improve, ImproveTime, 32, false, 2);
				}
				
				g_info[client][WOnly] = time;

				if(time <= WOnly_WR[Time] || WOnly_WR[Time] == 0.0)
				{
					//Save Replay File
					BotMimic_DeleteRecord(replaypath);
					BotMimic_StopRecording(client, true);
					
					//Celebrate!
					WRCelebration(client, StyleName);

					//Update Records
					WOnly_WR[Time] = time;
					GetClientName(client, WOnly_WR[PlayerName], MAX_NAME_LENGTH);
					
					calcXP = calcXP * 5;
					PrintToChat(client, " \x01\x04x5 EXP for World Record Breaker!");
				}
				else
				{
					PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
					PrintToChat(client, " \x01Time Improved by\x01\x0C -%ss! ", ImproveTime);
					PrintToChat(client, " \x01\x04+50 EXP for New Personal Best!");
					if(BotMimic_IsPlayerRecording(client))
					{
						BotMimic_StopRecording(client, false);
					}
					calcXP = calcXP + 50;
				}

			}
			else
			{
				PrintToChat(client, " \x01\x0B\x03[Lv. %d] \x01%N \x05has finished the map in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], StyleName);
			}
	
			PrintToChat(client, " \x01\x04+25 EXP for W-Only Style!");
			calcXP = calcXP + 25;
			GivePlayerXP(client, calcXP);
		}
	}
}

public WRCelebration(client, const String:userstyle[])
{
	decl String:WRSND[128];
	Format(WRSND, 128, "%s/battle-royale/br_wr_ding.mp3", RELATIVE_SOUND_PATH);
	EmitSoundToAll(WRSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
		
	PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x05has SET A NEW WORLD RECORD in \x01\x07%ss \x01on \x01\x04[%s]", g_info[client][Level], client, g_timers[client][MapTime], userstyle);
}


public BonusComplete(client, style, Float:time)
{
	new calcXP;
	
	calcXP = 25;
	
	switch(style)
	{
		//Auto
		case 1:
		{
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Auto]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Legit
		case 2:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for Legit Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Legit]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Freestyle
		case 3:
		{
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Freestyle]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Parkour
		case 4:
		{
			calcXP = calcXP / 2;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Parkour]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Half-Sideways
		case 5:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for Half-Sideways Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Half-Sideways]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//Sideways
		case 6:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for Sideways Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[Sideways]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
		//W-Only
		case 7:
		{
			calcXP = calcXP + 25;
			PrintToChat(client, " \x01\x04+%i EXP for Finishing Bonus Stage!", calcXP);
			PrintToChat(client, " \x01\x04+25 EXP for W-Only Style!");
			PrintToChatAll(" \x01\x0B\x03[Lv. %d] \x01%N \x01\x0Chas finished the Bonus Stage in \x01\x0B%ss \x01\x0Con \x01\x04[W-Only]", g_info[client][Level], client, g_timers[client][MapTime]);
		}
	}
	
	GivePlayerXP(client, calcXP);
}



/* Paradise Map Zones
**
** Types: Start Zone | End Zone | Cheat Zone | Bonus Start | Bonus End
** -------------------------------------------------------------------------- */

//------------------------
// Player Entering Zones |
//------------------------

public Zone_OnClientEntry(client, type)
{	
	switch(type)
	{
		//Start Zone
		case 0:
		{				
			StopTimer(client);
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
			
			new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);
			
			if(!onground)
			{
				if(g_info[client][Style] == 1 || g_info[client][Style] == 2 || g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
				{
					LimitVelocity(client, 300.0);
				}
			}
			
		}
		//End Zone
		case 1:
		{			
			if(g_timers[client][Enabled] && (!g_timers[client][Bonus]))
			{
				decl g_Jumps, g_Strafes, Float:g_Sync, Float:g_PreSpeed, g_WallRuns, g_WallJumps;
				
				g_Jumps = g_info[client][Jumps];
				g_Strafes = g_info[client][Strafes];
				g_Sync = GetClientSync(client);
				g_PreSpeed = g_info[client][PreSpeed];
				g_WallRuns = g_info[client][WallRuns];
				g_WallJumps = g_info[client][WallJumps];
				
				FinishTimer(client);

				FormatPlayerTime(g_timers[client][EndTime], g_timers[client][MapTime], 64, false, 0);
				
				MapComplete(client, g_info[client][Style], g_timers[client][EndTime], g_Jumps, g_Strafes, g_Sync, g_PreSpeed, g_WallRuns, g_WallJumps);
				
			}
		}
		//Bonus Start
		case 2:
		{	
			StopTimer(client);
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
			
			new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);
			
			if(!onground)
			{
				if(g_info[client][Style] == 1 || g_info[client][Style] == 2 || g_info[client][Style] == 5 || g_info[client][Style] == 6 || g_info[client][Style] == 7)
				{
					LimitVelocity(client, 300.0);
				}
			}
		}
		//Bonus End
		case 3:
		{
			if(g_timers[client][Enabled] && (g_timers[client][Bonus]))
			{
				g_timers[client][Bonus] = false;
				
				FinishTimer(client);

				FormatPlayerTime(g_timers[client][EndTime], g_timers[client][MapTime], 64, false, 0);
				
				BonusComplete(client, g_info[client][Style], g_timers[client][EndTime]);
				
			}
		}
		//Cheat Zone
		case 4:
		{
			StopTimer(client);
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
			
			ClientCommand(client, "sm_r");
			PrintToChat(client, " \x01\x07[Paradise] You have been respawned for entering a restricted zone.");
		}
	}
}

//-----------------------
// Player Exiting Zones |
//-----------------------

public Zone_OnClientLeave(client, type)
{
	switch(type)
	{
		//Start Zone
		case 0:
		{
			g_timers[client][Bonus] = false;
			
			if(g_info[client][Style] > 0)
			{
				if(!IsFakeClient(client))
				{
					if(!IsPlayerInZone[4][client])
					{
						decl String:replayName[255];
						
						StartTimer(client);
						
						Format(replayName, 255, "%sWR-%i", Map[MapName], g_info[client][Style]);
					
						BotMimic_StartRecording(client, replayName, "World Records", Map[MapName]);
					}
				}
			}
		}
		//Bonus Start
		case 2:
		{
			if(g_info[client][Style] > 0)
			{
				if(!IsFakeClient(client))
				{
					StartTimer(client);
					
					g_timers[client][Bonus] = true;
				}
			}
		}
		//Cheat Zone
		case 4:
		{
			StopTimer(client);
			
			if(BotMimic_IsPlayerRecording(client))
			{
				BotMimic_StopRecording(client, false);
			}
		}
	}
}


/* Paradise Level/XP Functions
**
** Functions: GivePlayerXP | SetLevel | SetLevelTag 
** -------------------------------------------------- */

// Give Player XP
public GivePlayerXP(client, xp)
{	
	new xp_needed = g_info[client][XP_Needed];
	
	new old_xp = g_info[client][XP];
	new new_xp = old_xp + xp;
	
	if(g_info[client][Level] > 0)
	{
		//+EXP
		if(xp > 0)
		{
			PrintToChat(client, "You have gained \x01\x04+%d EXP!", xp);
		}
		
		//+Level Up
		if (new_xp >= xp_needed)
		{
			new L = g_info[client][Level];
			
			g_info[client][Level] = g_info[client][Level] + 1;
			g_info[client][XP] = new_xp - xp_needed;
			g_info[client][XP_Needed] = ((L * L + L + 3) * 4);
			
			PrintToChat(client, "Level Up! You are now \x01\x04Level %d", g_info[client][Level]);
			SetLevelTag(client);
			
			
			if(g_info[client][XP] >= g_info[client][XP_Needed])
			{
				GivePlayerXP(client, 0);
			}
		}
		else
		{
			g_info[client][XP] = new_xp;
		}
	}
	else
	{
		LoadPlayerData(client);
	}
}

// Set Clients Level
public Action:SetLevel(client, args) 
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setlevel <#userid|name> [level]");
		return Plugin_Handled;
	}
	
	decl String:arg1[64], String:arg2[20]; 
	new target = -1;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	if(StringToInt(arg2) <= 0 )
	{
		ReplyToCommand(client, "[SM] Invalid Level. Must be greater than zero.");
		return Plugin_Handled;
	}
	 
	for (new i=1; i<=MaxClients; i++)
	{
		if (!IsClientConnected(i))
		{
			continue;
		}
		decl String:other[MAX_NAME_LENGTH];
		GetClientName(i, other, sizeof(other));
		if (StrEqual(arg1, other))
		{
			target = i;
		}
	}
 
	if (target == -1)
	{
		PrintToConsole(client, "Could not find any player with the target in server!");
		return Plugin_Handled;
	}
	
	g_info[target][Level] = StringToInt(arg2);
	g_info[target][XP] = 0;
	
	UpdatePlayer(target);
	SetLevelTag(target);
	
	return Plugin_Handled;
}

//Set Client's Clantag
public SetLevelTag(client)
{
	decl String:name[MAX_NAME_LENGTH];
	decl String:tag[15];
	
	if(IsValidClient(client, false))
	{
		CS_GetClientClanTag(client, name, sizeof(name));
	}
	
	//Admin
	if(CheckCommandAccess(client, "sm_flag", ADMFLAG_GENERIC, true))
	{
		Format(tag, sizeof(tag), "[Event Staff]");
	}
	//EVE
	else if(IsFakeClient(client))
	{
		Format(tag, sizeof(tag), "EVE");
	}
	//Member
	else
	{
		Format(tag, sizeof(tag), "[★]");
	}
	
	if(StrContains(name, tag) == -1)
	{
		if(IsValidClient(client, false))
		{
			CS_SetClientClanTag(client, tag);
		}
	}
}