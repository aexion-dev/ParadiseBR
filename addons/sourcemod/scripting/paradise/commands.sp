
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | COMMANDS",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

new bool:g_bViewModel[MAXPLAYERS+1];


/* *** Basic Battle Royale Player Commands *** *\
//----------------------------------------------*/

//[ Style Menu - !style ]
public Action:sm_style(client, args)
{
	if(BR_RoundStart || BR_Round < 1)
		mStyle_Main(client);
	
	return Plugin_Handled;
}

//[ Restart CMD - !r | !restart ]
public Action:sm_r(client, args)
{
	if(IsClientInGame(client) && (BR_RoundStart || BR_Round < 1))
	{
		new team = GetClientTeam(client);
		
		if(1 < team < 4)
		{
			CS_RespawnPlayer(client);
			if((g_ZonesLoaded) && g_ZoneExists[0])
			{
				TeleportToZone(client, 0);
				StopTimer(client);
			}
		}
	}
	
	return Plugin_Handled;
}

//[ Auto CMD - !auto ]
public Action:sm_auto(client, args)
{
	new team = GetClientTeam(client);
	
	if((1 < team < 4 && BR_RoundStart) || BR_Round < 1)
	{
		g_info[client][Style] = 1;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Legit CMD - !legit ]
public Action:sm_legit(client, args)
{
	new team = GetClientTeam(client);
	
	if((1 < team < 4 && BR_RoundStart) || BR_Round < 1)
	{
		g_info[client][Style] = 2;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Freestyle CMD - !freestyle ]
public Action:sm_freestyle(client, args)
{
	new team = GetClientTeam(client);
	
	if((1 < team < 4 && BR_RoundStart) || BR_Round < 1)
	{
		g_info[client][Style] = 3;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Parkour CMD - !parkour ]
public Action:sm_parkour(client, args)
{
	new team = GetClientTeam(client);
	
	if((1 < team < 4 && BR_RoundStart) || BR_Round < 1)
	{
		g_info[client][Style] = 4;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Half-Sideways CMD - !hsw | !half-sideways ]
public Action:sm_hsw(client, args)
{
	new team = GetClientTeam(client);
	
	if((1 < team < 4 && BR_RoundStart) || BR_Round < 1)
	{
		g_info[client][Style] = 5;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ Sideways CMD - !sideways | !sw ]
public Action:sm_sideways(client, args)
{
	new team = GetClientTeam(client);
	
	if((1 < team < 4 && BR_RoundStart) || BR_Round < 1)
	{
		g_info[client][Style] = 6;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ W-Only CMD - !wonly ]
public Action:sm_wonly(client, args)
{
	new team = GetClientTeam(client);
	
	if((1 < team < 4 && BR_RoundStart) || BR_Round < 1)
	{
		g_info[client][Style] = 7;
		CS_RespawnPlayer(client);
		if((g_ZonesLoaded) && g_ZoneExists[0])
		{
			TeleportToZone(client, 0);
			StopTimer(client);
		}
	}
	
	return Plugin_Handled;
}

//[ World Record Menu - !wr | !worldrecord ]
public Action:sm_wr(client, args)
{
	mWorldRecords_Main(client);
	
	return Plugin_Handled;
}

//[ Player Profile Menu - !profile | !me ] - Need To Make This !Pb && Preferrably Non-SQL Based.
public Action:sm_profile(client, args)
{
	if (args == 0)
	{
		decl String:steamid[64];
		GetClientAuthString(client, steamid, sizeof(steamid));
		
		LoadProfile(client, steamid);
	}
	else if (args >= 1)
	{
		new String:arg1[MAX_NAME_LENGTH];
		GetCmdArgString(arg1, sizeof(arg1));
		
		LookupPlayer(client, arg1);
	}

	return Plugin_Handled;
}
/*------------------------------------------*/




/* *** Battle Royale Admin Commands *** *\
//----------------------------------------------*/

//[ Start Battle Royale - !br_start ]
public Action:br_start(client, args)
{
	/* Final PlayerAuth Check-In*/
	for(new f = 0; f <= 28; f++)
	{
		//Check Each Player On Server Was Checked-In
		for(new k = 1; k <= MaxClients; k++)
		{
			if(IsValidClient(k) && !IsFakeClient(k))
			{
				decl String:CLID[64];
				GetClientAuthString(k, CLID, sizeof(CLID));
				
				if(StrEqual(CLID, AuthPlayer[f][AuthSID]))
				{
					if(!AuthPlayer[f][CheckedIn])
					{
						AuthPlayer[f][CheckedIn] = true;
					}
				}
			}
		}
		
		//DQ All Non-Checked In Players (Excludes Staff/Casters/Stream)
		if(!AuthPlayer[f][CheckedIn] && f < 25)
		{
			if(!StrEqual(AuthPlayer[f][AuthName], "Name"))
			{
				PrintToChatAll(" \x01\x06[Paradise] \x01Player \x01\x07%s \x01has been disqualified! \x01\x07(Reason: Failure To Join)", AuthPlayer[f][AuthName]);
				AuthPlayer[f][CheckedIn] = false;
			}
		}
		
		AuthPlayer[f][BRScore] = 0.0;
	}
	
	BR_Warmup = false;
	
	PrintToChatAll(" \x01\x06[Paradise] \x01Battle Royale is starting! ");
	PrintToChatAll(" \x01\x06[Paradise] \x01Round One: bhop_khonsu by A.NightWolf");
	
	SetNextMap("tier1_nightwolf");
	
	SetCvar("mp_ignore_round_win_conditions", "0");
	
	CreateTimer(5.0, End_Round, _, TIMER_FLAG_NO_MAPCHANGE);
}

//[ End Battle Royale - !br_end ]
public Action:br_end(client, args)
{
	PrintToChatAll(" \x01\x06[Paradise] \x01Battle Royale has finished! ");
	
	SetCvar("mp_ignore_round_win_conditions", "0");
	
	CreateTimer(5.0, End_Round, _, TIMER_FLAG_NO_MAPCHANGE);
	
	for(new i = 0; i <= 28; i++)
	{
		AuthPlayer[i][CheckedIn] = false;
		AuthPlayer[i][PlayerReady] = false
		AuthPlayer[i][BRScore] = 0.0;
	}
	
	BR_Round = 0;
}


//[ Staff Command To Join Spectators  ]
public Action:br_spectate(client, args)
{
	if (args == 0)
	{
		if (IsPlayerAlive(client) && IsClientInGame(client) && (BR_RoundStart || BR_Round >= 1))
		{
			FakeClientCommand(client, "spectate");
		}
	}
	else if (args == 1 && (BR_RoundStart || BR_Round >= 1))
	{
		new String:arg1[64];
		GetCmdArgString(arg1, sizeof(arg1));
		
		new target = FindTarget(client, arg1, true, true);
		if (target == -1) 
		{
			return Plugin_Handled;
		}
		if (IsClientInGame(target))
		{
			if (!IsPlayerAlive(target))
			{
				ReplyToCommand(client, "[SM] %t", "Target must be alive");
				return Plugin_Handled;
			}
			ChangeClientTeam(client, 1);
			FakeClientCommand(client, "spec_player_by_name %N", target);
		}
		if (!IsClientInGame(target)) ReplyToCommand(client, "[SM] %t", "Target is not in game");
	}
	return Plugin_Handled;
}

//[ Hide Player's HUD ]
public Action:br_hidehud(client, args)
{
	CreateTimer(0.0, RemoveHUD, client);
}

//[ Show Player's HUD ]
public Action:br_showhud(client, args)
{
	CreateTimer(0.0, ShowHUD, client);
}

//[ Toggle Slowmotion ]
public Action:br_slowmotion(client, args)
{
	new Float:MotionSpeed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
	
	if(MotionSpeed == 1.0)
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.4);
	else
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
}

//[ Test Command ]
public Action:br_test(client, args)
{
	CS_SetClientContributionScore(client, 10);
}
/*------------------------------------------*/




/* *** Misc. Commands *** *\
//----------------------------------------------*/

public Action:sm_querycount(client, args)
{
	PrintToChat(client, "%i Queries Executed This Map", QueryCounter);
	
	return Plugin_Handled;
}

//[ Top Map Records Menu - !mtop | !maptop ]
public Action:sm_maptop(client, args)
{
	if (args == 0)
	{
		MapTop_Main(client, Map[MapName]);
	}
	else if (args >= 1)
	{
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		MapTop_Main(client, arg1);
	}
	
	return Plugin_Handled;
}

//[ Map Info Menu - !mapinfo ]
public Action:sm_mapinfo(client, args)
{
	PrintToChat(client, "\x06%s \x01 is a \x07[Tier %d] Map\x01 with \x03%s Stage(s).\x01 Map Reward:\x01\x0B %d XP", Map[MapName], Map[Tier], Map[Stages], Map[XPValue]);
}

//[ Top Players Menu - !top ]
public Action:sm_top(client, args)
{
	if (args == 0)
	{
		TopPlayers_Main(client);
	}
	
	return Plugin_Handled;
}

//[ Top Players Menu - !topauto ]
public Action:sm_autotop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Auto");
	}
	
	return Plugin_Handled;
}

//[ Top Players Menu - !toplegit ]
public Action:sm_legittop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Legit");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topfreestyle ]
public Action:sm_freestyletop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Freestyle");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topparkour ]
public Action:sm_parkourtop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Parkour");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !tophsw | !tophalfsideways ]
public Action:sm_halfsidewaystop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Half-Sideways");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topsw | !topsideways ]
public Action:sm_sidewaystop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "Sideways");
	}
	
	return Plugin_Handled;
}
//[ Top Players Menu - !topwonly ]
public Action:sm_wonlytop(client, args)
{
	if (args == 0)
	{
		TopPlayers(client, "W-Only");
	}
	
	return Plugin_Handled;
}

/*
//||------------------------------------------------------------------------------------||\\
//|| Look Up World Record On Map Via Command. i.e: !autowr or !autowr bhop_mapname_csgo ||
//||------------------------------------------------------------------------------------||\\
*/

//[ Auto WR Look Up Menu - !autowr | !autowr map_name ]
public Action:sm_autowr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Auto");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Auto");
	}
	
	return Plugin_Handled;
}

//[ Legit WR Look Up Menu - !Legitwr | !Legitwr map_name ]
public Action:sm_legitwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Legit");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Legit");
	}
	
	return Plugin_Handled;
}

//[ Freestyle WR Look Up Menu - !Freestylewr | !Freestylewr map_name ]
public Action:sm_freestylewr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Freestyle");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Freestyle");
	}
	
	return Plugin_Handled;
}

//[ Parkour WR Look Up Menu - !Parkourwr | !Parkourwr map_name ]
public Action:sm_parkourwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Parkour");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Parkour");
	}
	
	return Plugin_Handled;
}

//[ Half-Sideways WR Look Up Menu - !hswwr | !hswwr map_name ]
public Action:sm_hswwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Half-Sideways");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Half-Sideways");
	}
	
	return Plugin_Handled;
}

//[ Sideways WR Look Up Menu - !swwr | !swwr map_name ]
public Action:sm_swwr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "Sideways");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "Sideways");
	}
	
	return Plugin_Handled;
}

//[ W-Only WR Look Up Menu - !wonlywr | !wonlywr map_name ]
public Action:sm_wonlywr(client, args)
{
	if (args == 0)
	{
		Format(LastMenu[client], 64, "");
		WRLookup(client, Map[MapName], "W-Only");
	}
	else if (args >= 1)
	{
		Format(LastMenu[client], 64, "");
		
		new String:arg1[128];
		GetCmdArgString(arg1, sizeof(arg1));
		
		WRLookup(client, arg1, "W-Only");
	}
	
	return Plugin_Handled;
}



//[ Leaderboard Menu - !leaderboard | !ranks ]
public Action:sm_leaderboard(client, args)
{
	mLeaderboard_Main(client);
	
	return Plugin_Handled;
}

//[ Zone Editor Menu - !zones ]
public Action:sm_zones(client, args)
{
	mZones_Main(client);
	
	return Plugin_Handled;
}


public Action:ResetTimer(Handle:timer, any:serial)
{
	new client = GetClientFromSerial(serial); // Validate the client serial
	
	if (client == 0) // The serial is no longer valid, the player must have disconnected
	{
		return Plugin_Stop;
	}
	
	StopTimer(client);
	
	return Plugin_Stop;
}

//[ Spectate CMD - !spec PlayerName | !spectate PlayerName ]
public Action:sm_spectate(client, args)
{
	if (args == 0)
	{
		if (IsPlayerAlive(client) && IsClientInGame(client) && (!BR_RoundStart || BR_Round < 1))
		{
			FakeClientCommand(client, "spectate");
		}
	}
	else if (args == 1 && (!BR_RoundStart || BR_Round < 1))
	{
		new String:arg1[64];
		GetCmdArgString(arg1, sizeof(arg1));
		
		new target = FindTarget(client, arg1, true, true);
		if (target == -1) 
		{
			return Plugin_Handled;
		}
		if (IsClientInGame(target))
		{
			if (!IsPlayerAlive(target))
			{
				ReplyToCommand(client, "[SM] %t", "Target must be alive");
				return Plugin_Handled;
			}
			ChangeClientTeam(client, 1);
			FakeClientCommand(client, "spec_player_by_name %N", target);
		}
		if (!IsClientInGame(target)) ReplyToCommand(client, "[SM] %t", "Target is not in game");
	}
	return Plugin_Handled;
}

//[ Hide Weapons - !hideweapons ]
public Action:sm_hideweapons(client, args)
{
	HideViewModel(client);
	
	if (g_bViewModel[client])
		PrintToChat(client, " \x01\x06[Paradise] \x01Your weapons are now visible!");
	else
		PrintToChat(client, " \x01\x06[Paradise] \x01Your weapons are now hidden!");
		
		
	return Plugin_Handled;
}

public HideViewModel(client)
{
	if (!g_bViewModel[client])
	{
		g_bViewModel[client]=true;
		Client_SetDrawViewModel(client,true);
	}
	else
	{
		g_bViewModel[client]=false;
		Client_SetDrawViewModel(client,false);
	}
}



public Action:sm_vip(client, args)
{
	if(IsValidClient(client, true))
	{
		if(CheckCommandAccess(client, "sm_vip", ADMFLAG_CUSTOM2, true))
		{
			mDonator_Main(client);
		}
	}
	
	return Plugin_Handled;
}

public Action:sm_models(client, args)
{
	if(IsValidClient(client, true))
	{
		if(CheckCommandAccess(client, "sm_models", ADMFLAG_CUSTOM2, true))
		{
			mDonator_Models(client);
		}
	}
	
	return Plugin_Handled;
}

// Give Players XP
public Action:sm_givexp(client, args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] Usage: sm_givexp <#userid|name> [XP]");
		return Plugin_Handled;
	}
	
	decl String:arg1[64], String:arg2[20]; 
	new target = -1;
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	if(StringToInt(arg2) <= 0 )
	{
		ReplyToCommand(client, "[SM] Invalid XP. Must be greater than zero.");
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
	
	GivePlayerXP(target, StringToInt(arg2));
	
	return Plugin_Handled;
}

public Action:sm_addmap(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Paradise] Usage: sm_addmap <mapname>, 'tier', 'stages', 'XP'");
		return Plugin_Handled;
	}

	decl String:arg[255], String:amMap[65], amTier, String:amStages[15], amXP;
	GetCmdArg(1, amMap, sizeof(amMap));
	GetCmdArg(3, amStages, sizeof(amStages));
	
	GetCmdArg(2, arg, sizeof(arg));
	amTier = StringToInt(arg);
	GetCmdArg(4, arg, sizeof(arg));
	amXP = StringToInt(arg);
	
	AddMap(amMap, amTier, amStages, amXP);
	
	PrintToChat(client, " \x01\x06[Paradise] Your Map has been added successfully!");
	
	return Plugin_Handled;
}

public Action:sm_deletemap(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Paradise] Usage: sm_deletemap <mapname>");
		return Plugin_Handled;
	}

	decl String:amMap[65];
	GetCmdArg(1, amMap, sizeof(amMap));
	
	DeleteMap(amMap);
	
	PrintToChat(client, " \x01\x06[Paradise] Your Map has been removed successfully!");
	
	return Plugin_Handled;
}

public Action:sm_addvip(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[Paradise] Usage: sm_addvip <steamid> 'amount'");
		return Plugin_Handled;
	}

	decl String:arg[255], String:amID[64], Float:amAmount;
	GetCmdArg(1, amID, sizeof(amID));
	GetCmdArg(2, arg, sizeof(arg));
	
	amAmount = StringToFloat(arg);
	
	AddVIP(amID, amAmount);
	
	return Plugin_Handled;
}