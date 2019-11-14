
enum MapInfo
{
	String:MapName[64],
	Tier,
	String:Stages[64],
	XPValue,
	Float:Average,
	Time,
	RecordCount
}

new Map[MapInfo];

new bool:BR_Warmup;
new BR_Round;
new BR_CheckIn;
new bool:BR_RoundStart;
new bool:BR_MOStart;
new bool:BR_MOLoaded;
new BR_MOTime;
new bool:BR_RoundEnd;
new resultType;
new bool:BR_Results;

new BR_PlayerCount;
new BR_TotalPlayerCount;
new BR_CameraMan;

new bool:MapEnding;
new bool:CountdownPlayed;

new bool:StartMSG;
new g_iGameRulesEnt;

new const String:RELATIVE_SOUND_PATH[] = "*/sourcemod/paradise";

new const String:BR_MapT1[] = "tier1_nightwolf";
new const String:BR_MapT2[] = "tier2_tonymontana";
new const String:BR_MapT3[] = "tier3_biql";
new const String:BR_MapT4[] = "tier4_saspatoon";
new const String:BR_MapT5[] = "tier5_roger";

enum AuthToken
{
	String:AuthName[64],
	String:AuthSID[64],
	EventGroup,
	bool:CheckedIn,
	bool:PlayerReady,
	Float:BRScore
}

new BR_Staff;
new BR_Caster1;
new BR_Caster2;
new BR_Stream;

new AuthPlayer[29][AuthToken] =
{
	{"eskay", "STEAM_1:1:86276002", 1, false, false, 0.0},
	{"Aqua", "STEAM_1:0:123699510", 1, false, false, 0.0},
	{"SomebodyEpic", "STEAM_1:0:53620757", 1, false, false, 0.0},
	{"W-Only", "STEAM_1:0:76990244", 1, false, false, 0.0},
	{"nishi", "STEAM_1:0:40405278", 1, false, false, 0.0},
	{"SneaKZ", "STEAM_1:1:46996013", 1, false, false, 0.0},
	{"lemin", "STEAM_1:0:83329442", 1, false, false, 0.0},
	{"Trevor", "STEAM_1:0:42675965", 1, false, false, 0.0},
	{"OLD_MONEY_BOWLING$$$_$$", "STEAM_1:1:18080476", 1, false, false, 0.0},
	{"F^Proz", "STEAM_1:0:48560794", 1, false, false, 0.0},
	{"ZOOM", "STEAM_1:0:128604324", 1, false, false, 0.0},
	{"Legacy", "STEAM_1:0:93521844", 1, false, false, 0.0},
	{"bobby", "STEAM_1:0:8663477", 1, false, false, 0.0},
	{"Blackout", "STEAM_1:0:143645778", 1, false, false, 0.0},
	{"Winter", "STEAM_1:0:65503679", 1, false, false, 0.0},
	{"lily", "STEAM_1:1:482948", 1, false, false, 0.0},
	{"wind", "STEAM_1:0:147027562", 1, false, false, 0.0},
	{"PEz", "STEAM_1:1:73194443", 1, false, false, 0.0},
	{"CookiEs", "STEAM_1:0:89837224", 1, false, false, 0.0},
	{"fewRy", "STEAM_1:0:29174668", 1, false, false, 0.0},
	{"Revolution", "STEAM_1:1:35864722", 1, false, false, 0.0},
	{"Euria^^", "STEAM_1:0:19133744", 1, false, false, 0.0},
	{"Name", "STEAM_1:0:28065001", 1, false, false, 0.0},
	{"Name", "STEAM_1:1:9606430", 1, false, false, 0.0},
	{"Name", "STEAM_1:1:169544935", 1, false, false, 0.0},
	{"HunnyBop", "STEAM_1:0:98064868", 2, false, false, 0.0}, 	//Hunny Bop
	{"Jydus", "STEAM_1:1:49762667", 3, false, false, 0.0}, 	//Caster #1
	{"tonic", "STEAM_1:0:40029651", 3, false, false, 0.0}, 	//Caster #2
	{"h3adsh0t", "STEAM_1:1:31047127", 4, false, false, 0.0}  //Streamer
}


new Float:PlayerPoints[30] = {0.0, ...};


new TimeLeft;
new Float:SavedTime;
new Float:InitTime;
new Float:EngineTime;
new bool:m_Extend;

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | MAPS <3",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
	url = ""
}

public MapStarted()
{	
	AddFileToDownloadsTable("sound/sourcemod/paradise/countdown.mp3");
	AddFileToDownloadsTable("sound/sourcemod/paradise/battle-royale/br_round_start.mp3");
	AddFileToDownloadsTable("sound/sourcemod/paradise/battle-royale/br_wr_ding.mp3");
	AddFileToDownloadsTable("sound/sourcemod/paradise/battle-royale/br_crowd_cheer.mp3");
	AddFileToDownloadsTable("sound/sourcemod/paradise/battle-royale/br_crowd_cheer2.mp3");
	AddFileToDownloadsTable("sound/sourcemod/paradise/battle-royale/br_drum_roll.mp3");
	
	AddFileToDownloadsTable("materials/effects/hsv.vmt");
	AddFileToDownloadsTable("materials/effects/evehud.vtf");
	AddFileToDownloadsTable("materials/effects/evehud.vmt");
	AddFileToDownloadsTable("materials/pp/tv2.vmt");
	AddFileToDownloadsTable("materials/pp/tv.vtf");
	AddFileToDownloadsTable("materials/effects/loading2.vtf");
	AddFileToDownloadsTable("materials/effects/loading2.vmt");
	
	FakePrecacheSound("*/sourcemod/paradise/countdown.mp3");
	FakePrecacheSound("*/sourcemod/paradise/battle-royale/br_round_start.mp3");
	FakePrecacheSound("*/sourcemod/paradise/battle-royale/br_wr_ding.mp3");
	FakePrecacheSound("*/sourcemod/paradise/battle-royale/br_crowd_cheer.mp3");
	FakePrecacheSound("*/sourcemod/paradise/battle-royale/br_crowd_cheer2.mp3");
	FakePrecacheSound("*/sourcemod/paradise/battle-royale/br_drum_roll.mp3");
	
	PrecacheDecal("effects/hsv.vmt", true);
	PrecacheDecal("effects/evehud.vmt", true);
	PrecacheDecal("pp/tv2.vmt", true);
	PrecacheDecal("effects/loading2.vmt", true);

	GetCurrentMap(Map[MapName], sizeof(Map[MapName]));
	
	decl String:LoadingText[150];
	
	Format(LoadingText, sizeof(LoadingText), "maps/%s.txt", Map[MapName]);
	AddFileToDownloadsTable(LoadingText);
	
	Format(LoadingText, sizeof(LoadingText), "maps/%s.jpg", Map[MapName]);
	AddFileToDownloadsTable(LoadingText);
	
	resultType = 0;
	BR_MOLoaded = false;
	
	//Warm-up Round
	if(StrEqual(Map[MapName], "paradise_lobby", true))
	{
		BR_Warmup = true;
		BR_Round = 0;
		
		decl String:Value[10];
		
		Map[Time] = 5;
		TimeLeft = Map[Time];
		
		IntToString(Map[Time], Value, 10);
		SetCvar("mp_roundtime", Value);
		SetCvar("mp_timelimit", Value);
		
		CS_TerminateRound(1.0, CSRoundEnd_GameStart, true)
		
		SetCvar("sv_voiceenable", "1");
		ServerCommand("sm_cvar sm_sc_volume 4");
		
		BR_CreateTable();
	}
	else if(StrEqual(Map[MapName], BR_MapT1, true))
	{
		BR_Warmup = false;
		BR_RoundStart = false;
		BR_MOStart = false;
		BR_MOLoaded = false;
		BR_MOTime = 0;
		BR_RoundEnd = false;
		BR_Results = false;
		BR_CheckIn = false;
		
		BR_Round = 1;
		BR_PlayerCount = 0;
		
		SetCvar("sv_voiceenable", "0");
		ServerCommand("sm_cvar sm_sc_volume 10");
		
		//LoadMap(Map[MapName]);
	}
	else if(StrEqual(Map[MapName], BR_MapT2, true))
	{
		BR_Warmup = false;
		BR_RoundStart = false;
		BR_MOStart = false;
		BR_MOLoaded = false;
		BR_MOTime = 0;
		BR_RoundEnd = false;
		BR_Results = false;
		BR_CheckIn = false;
		
		BR_Round = 2;
		BR_PlayerCount = 0;
		
		ServerCommand("sm_cvar sm_sc_volume 10");
		
		//LoadMap(Map[MapName]);
	}
	else if(StrEqual(Map[MapName], BR_MapT3, true))
	{
		BR_Warmup = false;
		BR_RoundStart = false;
		BR_MOStart = false;
		BR_MOLoaded = false;
		BR_MOTime = 0;
		BR_RoundEnd = false;
		BR_Results = false;
		BR_CheckIn = false;
		
		BR_Round = 3;
		BR_PlayerCount = 0;
		
		ServerCommand("sm_cvar sm_sc_volume 10");
		
		//LoadMap(Map[MapName]);
	}
	else if(StrEqual(Map[MapName], BR_MapT4, true))
	{
		BR_Warmup = false;
		BR_RoundStart = false;
		BR_MOStart = false;
		BR_MOLoaded = false;
		BR_MOTime = 0;
		BR_RoundEnd = false;
		BR_Results = false;
		BR_CheckIn = false;
		
		BR_Round = 4;
		BR_PlayerCount = 0;
		
		ServerCommand("sm_cvar sm_sc_volume 10");
		
		//LoadMap(Map[MapName]);
	}
	else if(StrEqual(Map[MapName], BR_MapT5, true))
	{
		BR_Warmup = false;
		BR_RoundStart = false;
		BR_MOStart = false;
		BR_MOLoaded = false;
		BR_MOTime = 0;
		BR_RoundEnd = false;
		BR_Results = false;
		BR_CheckIn = false;
		
		BR_Round = 5;
		BR_PlayerCount = 0;
		
		ServerCommand("sm_cvar sm_sc_volume 10");
		
		//LoadMap(Map[MapName]);
	}
	else if(StrEqual(Map[MapName], "paradise_winners", true))
	{
		BR_Results = true;
		
		BR_Warmup = false;
		BR_RoundStart = false;
		BR_MOStart = false;
		BR_MOLoaded = false;
		BR_MOTime = 0;
		BR_RoundEnd = false;
		BR_CheckIn = false;
		
		BR_Round = 6;
		BR_PlayerCount = 0;
		
		SetCvar("sv_voiceenable", "0");
		ServerCommand("sm_cvar sm_sc_volume 5");
	}
	else
	{
		BR_Warmup = false;
		BR_RoundStart = false;
		BR_MOStart = false;
		BR_Results = false;
		
		BR_Round = -1;
		
		BR_PlayerCount = 0;
		
		LoadMap(Map[MapName]);
		
		SetCvar("sv_voiceenable", "1");
	}
	
	StartMSG = true;
	
	SavedTime = GetEngineTime();
	InitTime = GetEngineTime();
	EngineTime = GetEngineTime();
	
	MapEnding = false;
	CountdownPlayed = false;
	
	m_Extend = false;
	
	CreateTimer(30.0, MapMessage);
	CreateTimer(300.0, MapMessage, _, TIMER_FLAG_NO_MAPCHANGE);
}

stock ClientShake(client, Float:Amp=1.0)
{
	new Handle:message = StartMessageOne("Shake", client, 1);
	PbSetInt(message, "command", 0);
	PbSetFloat(message, "local_amplitude", Amp);
	PbSetFloat(message, "frequency", 255.0);
	PbSetFloat(message, "duration", 8.0);
	EndMessage();
}

public OnEntityCreated(entity, const String:classname[])
{
    if(StrEqual(classname, "cs_gamerules"))
	{
		g_iGameRulesEnt = entity;
	}
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	if (GetEntProp(g_iGameRulesEnt, Prop_Send, "m_bWarmupPeriod"))
        return Plugin_Continue;
		
	if (reason == CSRoundEnd_GameStart)
        return Plugin_Handled;
		
	return Plugin_Continue;
}

public PlayCountdown()
{
		decl String:CountdownSND[128];
		Format(CountdownSND, 128, "%s.mp3", RELATIVE_SOUND_PATH);
		EmitSoundToAll(CountdownSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
}


public EndMap()
{
	//If Battle Royale Is Not In Warm-Up
	if(!BR_Warmup && BR_MOStart && BR_RoundStart)
	{
		BR_RoundEnd = true;
		
		PrintToChatAll(" \x01\x03[EVE]: \x01\x06Round Complete!");
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i, false))
			{
				new clientteam = GetClientTeam(i);
				
				if(clientteam == 1)
				{
					ChangeClientTeam(i, 2);
				}
				
				CS_RespawnPlayer(i);
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
			}
		}
		
		PrintToChatAll(" \x01\x03[EVE]: \x01\x06Loading World Record Replays..");
		
		CreateTimer(5.0, StartResults);
	}
	else
	{
		MapEnding = true;
		
		if(BR_Warmup)
		{
			
			ServerCommand("sm_scall Jock Jams - Lets Get Ready To Rumble");
			
			CreateTimer(25.0, ScreenShake);
			
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i, true))
				{
					CS_RespawnPlayer(i);
					
					SetClientOverlay(i, "effects/hsv.vmt");
					
					SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
				}
			}
			
			
		}
	}
}
public Action:StartResults(Handle:timer)
{
		PrintToChatAll("  ");
		PrintToChatAll("  ");
		PrintToChatAll("  ");
		PrintToChatAll("  ");
		PrintToChatAll("  ");
		PrintToChatAll(" \x01\x05▄█__█__█___ Round Results ___█__█__█▄");
		resultType = 0;
		Round_Results(resultType);
		
		return Plugin_Stop;
}

public Round_Results(replayType)
{
	if(replayType >= 8)
	{		

	}
	else
	{
		new g_EVEBot = -1;

		for(new j = 1; j <= MaxClients; j++)
		{
			if(IsClientInGame(j) && IsFakeClient(j) && GetClientTeam(j) >= CS_TEAM_T)
			{
				g_EVEBot = j;
				
				if(!IsPlayerAlive(g_EVEBot))
				{
					CS_RespawnPlayer(g_EVEBot);
				}
			}
		}

		decl String:sPath[PLATFORM_MAX_PATH];
		
		switch(replayType)
		{
			case 0:
			{
				for(new h = 1; h <= MaxClients; h++)
				{
					if(IsValidClient(h) && !IsFakeClient(h))
					{
						ChangeClientTeam(h, 1);
						Client_SetObserverMode(h, OBS_MODE_IN_EYE, true);
					}
				}
				
				PrintResults("Auto");
				
				Format(sPath, sizeof(sPath), "%sWR-1", Map[MapName]);
				if(BotMimic_PlayRecordByName(g_EVEBot, sPath) == BM_NoError)
				{
					
				}
				else
				{
					Round_Results(1);
				}
			}	
			case 1:
			{
				PrintResults("Legit");
				
				Format(sPath, sizeof(sPath), "%sWR-2", Map[MapName]);
				if(BotMimic_PlayRecordByName(g_EVEBot, sPath) == BM_NoError)
				{
				}
				else
				{
					Round_Results(2);
				}
			}
			case 2:
			{
				PrintResults("Freestyle");
				
				Format(sPath, sizeof(sPath), "%sWR-3", Map[MapName]);
				if(BotMimic_PlayRecordByName(g_EVEBot, sPath) == BM_NoError)
				{
				}
				else
				{
					Round_Results(3);
				}
			}
			case 3:
			{
				PrintResults("Parkour");
				
				Format(sPath, sizeof(sPath), "%sWR-4", Map[MapName]);
				if(BotMimic_PlayRecordByName(g_EVEBot, sPath) == BM_NoError)
				{
				}
				else
				{
					Round_Results(4);
				}
			}
			case 4:
			{
				PrintResults("Half-Sideways");
				
				Format(sPath, sizeof(sPath), "%sWR-5", Map[MapName]);
				if(BotMimic_PlayRecordByName(g_EVEBot, sPath) == BM_NoError)
				{
				}
				else
				{
					Round_Results(5);
				}
			}
			case 5:
			{
				PrintResults("Sideways");
				
				Format(sPath, sizeof(sPath), "%sWR-6", Map[MapName]);
				if(BotMimic_PlayRecordByName(g_EVEBot, sPath) == BM_NoError)
				{
				}
				else
				{
					Round_Results(6);
				}
			}
			case 6:
			{
				PrintResults("W-Only");
				
				Format(sPath, sizeof(sPath), "%sWR-7", Map[MapName]);
				
				if(BotMimic_PlayRecordByName(g_EVEBot, sPath) == BM_NoError)
				{
				}
				else
				{
					Round_Results(7);
				}
			}
			case 7:
			{
				BR_SaveData(BR_Round);
				
				PrintResults("Leaderboard");
			}
		}
	}
}

public Action:ScreenShake(Handle:timer)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i, true))
		{
			ClientShake(i, 3.0);
		}
	}
	
	return Plugin_Stop;
}

public Action:Round_Countdown(Handle:timer)
{
	static numCount = 5;
	
	if(numCount <= 0)
	{		
		decl String:Value[10], NewMapTime;
		
		GetMapTimeLeft(NewMapTime);
		GetMapTimeLimit(BR_MOTime);
		
		BR_MOTime = BR_MOTime * 60;
		
		BR_MOTime = BR_MOTime - NewMapTime;
		
		switch(BR_Round)
		{
			case 1:{TimeLeft = 20;}
			case 2:{TimeLeft = 30;}
			case 3:{TimeLeft = 40;}
			case 4:{TimeLeft = 50;}
			case 5:{TimeLeft = 60;}
		}
		
		IntToString(TimeLeft, Value, 10);
		SetCvar("mp_roundtime", Value);
		SetCvar("mp_timelimit", Value);
	
		CS_TerminateRound(0.1, CSRoundEnd_GameStart, true);
		
		for(new i = 1; i <= MaxClients; i++)
		{
			SetClientOverlay(i, "none");
		}
		
		PrintToChatAll(" \x01\x03[EVE]: \x01\x06Round Started!");
		BR_RoundStart = true;
		
		numCount = 5;
		
		CreateTimer(1.0, Start_Bell);
		
		return Plugin_Stop;
	}
	
	PrintToChatAll(" \x01\x03[EVE]: \x01\x06%i..", numCount);
	numCount--;
	
	return Plugin_Continue;
}

public Action:Start_Bell(Handle:timer)
{
	decl String:RoundStartSND[128];
	Format(RoundStartSND, 128, "%s/battle-royale/br_round_start.mp3", RELATIVE_SOUND_PATH);
	EmitSoundToAll(RoundStartSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
	
	return Plugin_Stop;
}

public Action:Next_Round(Handle:timer)
{
	switch(BR_Round)
	{
		case 1:{PrintToChatAll(" \x01\x06[Paradise] \x01Round Two: bhop_serenity by Tony Montana");}
		case 2:{PrintToChatAll(" \x01\x06[Paradise] \x01Round Three: bhop_tier2 by Biql");}
		case 3:{PrintToChatAll(" \x01\x06[Paradise] \x01Round Four: bhop_nebula by Saspatoon");}
		case 4:{PrintToChatAll(" \x01\x06[Paradise] \x01Round Five: bhop_alba by Roger");}
	}
	
	CreateTimer(1.0, End_Round, _, TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Stop;
}

public Action:End_Round(Handle:timer)
{
	new Handle:WinCondition = FindConVar("mp_ignore_round_win_conditions");
	new CVResult = GetConVarInt(WinCondition);
	
	if(CVResult == 1 && !m_Extend)
	{
		SetConVarInt(WinCondition, 0, false, false);
	}
	
	CloseHandle(WinCondition);
	
	if(!m_Extend)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i, true))
			{
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
				ForcePlayerSuicide(i);
			}
		}
				
		//CS_TerminateRound(4.0, CSRoundEnd_Draw, true);
	}
	
	timer = INVALID_HANDLE;
}

public Action:MapMessage(Handle:timer)
{
	if(BR_Warmup)
	{
		if(StartMSG)
		{
		
			PrintToChatAll(" \x01\x06[Paradise] \x01Welcome to Bunnyhop Paradise's Battle Royale Event!");
			PrintToChatAll(" \x01\x06[Paradise] \x01You may begin warming up, the event will start in 60 minutes.");
			
			StartMSG = false;
			
			return Plugin_Stop;
		}
		else
		{
			//PrintToChatAll("  \x01\x06Mionix \x01is a proud sponsor of this event. Check out  \x01\x06Mionix.net's \x01selection of \x01\x03Custom Gaming Peripherals");
			
			return Plugin_Continue;
		}
	}
	
	return Plugin_Continue;
}

public Action:Event_Credits(Handle:timer)
{
	static numCount = 1;
	
	if(numCount == 1)
	{
		PrintToChatAll(" \x01\x06Summer 2016 Bunnyhop Battle Royale Credits");
		PrintToChatAll("   ");
	}
	
	switch(numCount)
	{
		case 1:{ PrintToChatAll(" \x01\x06Hunny Bop \x01- Owner of Bunnyhop Paradise, Event Management, and Stream");}
		case 2:{ PrintToChatAll(" \x01\x06Saspatoon \x01- Map Designer of bhop_nebula and paradise_lobby");}
		case 3:{ PrintToChatAll(" \x01\x06A.NightWolf \x01- Map Designer of bhop_khonsu");}
		case 4:{ PrintToChatAll(" \x01\x06Tony Montana \x01- Map Designer of bhop_serenity");}
		case 5:{ PrintToChatAll(" \x01\x06Jydus \x01- Event Casting and Map Testing");}
		case 6:{ PrintToChatAll(" \x01\x06Tonic \x01- Event Casting and Map Testing");}
		case 7:{ PrintToChatAll(" \x01\x06Concept \x01- Event Casting and Map Testing");}
		case 8:{ PrintToChatAll(" \x01\x06UnderUrBedz \x01- Map/Plugin Testing");}
		case 9:{ PrintToChatAll(" \x01\x06NoCopyrightSounds \x01- Stream Music/Intermission Songs");}
		case 10:{ PrintToChatAll(" \x01\x06h3adsh0t - Stream / Broadcast + Testing");}
		case 11:{ PrintToChatAll(" \x01\x06Aexi0n \x01- Graphics, Plugin Development and Website");}
		case 12:{ PrintToChatAll(" \x01\x06Bunnyhop Paradise \x01- Official Event Sponsorship");}
		case 13:{ PrintToChatAll(" \x01\x06ici/blacky - Anti-Cheat Plugin Ideas");}
		case 14:{ PrintToChatAll(" \x01\x06Micheal Buffer \x01- Battle Royale Intro Announcer SFX");}
		case 15:{ PrintToChatAll(" \x01\x06E-SoundTrax \x01- Cinematic Overview Music For Maps 1-3");}
		case 16:{ PrintToChatAll(" \x01\x06Sirius Beats \x01- Cinematic Overview Music For Maps 4-5");}
		case 17:{ PrintToChatAll(" \x01\x06DJ Kool \x01- Final Celebration Song");}
		case 18:{ PrintToChatAll(" \x01\x06Valve \x01- STILL Fucking Us Over Every Day");}
		case 19:{ PrintToChatAll(" \x01\x06Sadly No Sponsors to thank, BUT remember FadeCase.com are fucking scammers.");}
		case 20:
		{ 
			PrintToChatAll(" \x01\x06THANK YOU EVERYONE! EACH EVENT IS ALWAYS AN AMAZING EXPERIENCE FOR US ALL!");
			PrintToChatAll("   ");
			PrintToChatAll(" \x01\x03SO... WINTER BATTLE ROYALE ANYONE..? *WINKS* - Hunny Bop");
			
			numCount = 1;
			
			return Plugin_Stop;
		}
	}
	
	numCount++;
	
	return Plugin_Continue;
}

public MinutePassed()
{		
	new g_EVEBot = -1;

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
			LoadEVE(g_EVEBot);
		}
	}
}