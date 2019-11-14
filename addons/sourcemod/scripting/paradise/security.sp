
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | SECURITY",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

	
//Bhop Script Protection - Credits: Inami(Macrodox)
new aiJumps[MAXPLAYERS+1] = {0, ...};
new Float:afAvgJumps[MAXPLAYERS+1] = {1.0, ...};
new Float:afAvgSpeed[MAXPLAYERS+1] = {250.0, ...};
new Float:avVEL[MAXPLAYERS+1][3];
new aiPattern[MAXPLAYERS+1] = {0, ...};
new aiPatternhits[MAXPLAYERS+1] = {0, ...};
new Float:avLastPos[MAXPLAYERS+1][3];
new aiAutojumps[MAXPLAYERS+1] = {0, ...};
new aaiLastJumps[MAXPLAYERS+1][30];
new Float:afAvgPerfJumps[MAXPLAYERS+1] = {0.3333, ...};
new iTickCount = 1;
new aiIgnoreCount[MAXPLAYERS+1];
new String:path[PLATFORM_MAX_PATH];
new String:pathdat[PLATFORM_MAX_PATH];
new bool:bBanFlagged[MAXPLAYERS+1];
new bool:bSurfCheck[MAXPLAYERS+1];
new aiLastPos[MAXPLAYERS+1] = {0, ...};

//Command Spam Protection - Credits: Forlix(FloodCheck)
new Float:p_time_lasthardfld[MAXPLAYERS+1];
new p_cmdcnt_hard[MAXPLAYERS+1];
new bool:p_hard_banned[MAXPLAYERS+1];
new Float:hard_interval = 2.0;
new hard_num = 15;


public LoadSecurity()
{   
	//Load Security Config
	BuildPath(Path_SM, path, sizeof(path), "logs/Paradise_Security/threats.log");
	BuildPath(Path_SM, pathdat, sizeof(pathdat), "data/Paradise_Security/threats.dat"); 
	
	//Admin Commands
	RegAdminCmd("pb_check", Command_Stats, ADMFLAG_ROOT, "pb_check <userid/name>");
	
	//Blocked Commands
	RegConsoleCmd("status", Command_Block);
	RegConsoleCmd("ping", Command_Block);
	RegConsoleCmd("+forward", Command_Block);
	RegConsoleCmd("-forward", Command_Block);
	RegConsoleCmd("+backward", Command_Block);
	RegConsoleCmd("-backward", Command_Block);
	RegConsoleCmd("+klook", Command_Block);
	RegConsoleCmd("-klook", Command_Block);
}

// --- Command Spam Detection ---

public Action:Command_Block(client, args)
{
    return Plugin_Stop;
}

public Action:OnClientCommand(client, args)
{
	decl String:cmd[64];
	GetCmdArg(0, cmd, sizeof(cmd));
	
	if(StrContains(cmd, "+", false) == 0)
	{
		if(StrEqual(cmd, "+forward", false))
			return Plugin_Stop;
		else if(StrEqual(cmd, "+backward", false))
			return Plugin_Stop;
		else if(StrEqual(cmd, "+klook", false))
			return Plugin_Stop;
		else
			return(Plugin_Continue);
	}
	if(StrContains(cmd, "-", false) == 0)
	{
		if(StrEqual(cmd, "-forward", false))
			return Plugin_Stop;
		else if(StrEqual(cmd, "-backward", false))
			return Plugin_Stop;
		else if(StrEqual(cmd, "-klook", false))
			return Plugin_Stop;
		else
			return(Plugin_Continue);
	}
	if(StrContains(cmd, "ssspectate", false) == 0)
	{
		if(BR_RoundStart && BR_Round >= 1)
		{
			if(CheckCommandAccess(client, "sm_flag", ADMFLAG_ROOT, true))
			{
				return Plugin_Stop;
			}
		}
	}
	if(StrContains(cmd, "drop", false) == 0)
	{
		return(Plugin_Continue);
	}
	else
	{
		PB_SpamCheck(client);
		return(Plugin_Continue);
	}
}

public PB_SpamCheck(client)
{
	if(!client || !hard_interval || ++p_cmdcnt_hard[client] <= hard_num)
		return;

	new Float:time_c = GetTickedTime();

	if(time_c >= p_time_lasthardfld[client] + hard_interval || IsFakeClient(client) || IsClientInKickQueue(client)) // If Client is NOT Command Spamming..
	{
		p_time_lasthardfld[client] = time_c;
		p_cmdcnt_hard[client] = 0;
		return;
	}
	else //Client IS Command Spamming..
	{
		decl String:authid[64];

		if (GetClientAuthString(client, authid, sizeof(authid)))
		{
			decl String:nme[MAX_NAME_LENGTH];
			GetClientName(client, nme, MAX_NAME_LENGTH);
			
			KickClient(client, "[Paradise-Security]: Command Spam");
			PrintToChatAll(" \x01\x07[Paradise-Security] \x01Player:\x01\x07%s has been kicked for command spam!", nme);
		}
	}
	
	return;
}
// ----------------------------------------------------------------------------------



// --- Bhop Script Detection ---

public PB_JumpCheck(client)
{
	afAvgJumps[client] = ( afAvgJumps[client] * 9.0 + float(aiJumps[client]) ) / 10.0;
	
	
	decl Float:vec_vel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec_vel);
	vec_vel[2] = 0.0;
	new Float:speed = GetVectorLength(vec_vel);
	afAvgSpeed[client] = (afAvgSpeed[client] * 9.0 + speed) / 10.0;
	
	aaiLastJumps[client][aiLastPos[client]] = aiJumps[client];
	aiLastPos[client]++;
	
	if (aiLastPos[client] == 30)
	{
		aiLastPos[client] = 0;
	}
				
	/*if(afAvgJumps[client] > 14.0)
	{
		//HYPERSCROLLING:  http://hmxgaming.com/index.php?/topic/1459-cheating-isnt-cool-hyperscrolling-for-bhop-is-an-example/
		//disabled because it does not give you more speed than usual scrolling
		//check if more than 8 of the last 30 jumps were above 12
		g_NumberJumpsAbove[client] = 0;
			
		for (new i = 0; i < 29; i++)	//count
		{
			if((g_aaiLastJumps[client][i]) > (14 - 1))	//threshhold for # jump commands
			{
				g_NumberJumpsAbove[client]++;
			}
		}
		if((g_NumberJumpsAbove[client] > (14 - 1)) && (g_fafAvgPerfJumps[client] >= 0.4))	//if more than #
		{
			if (g_bAntiCheat && !g_bHyperscroll[client])
			{
				g_bHyperscroll[client] = true;
				new String:banstats[256];
				GetClientStatsLog(client, banstats, sizeof(banstats));		
				decl String:sPath[512];
				BuildPath(Path_SM, sPath, sizeof(sPath), "%s", ANTICHEAT_LOG_PATH);
				LogToFile(sPath, "%s reason: hyperscrolling" banstats);
			}
		}
	}*/
	
	if(aiJumps[client] > 1)
	{
		aiAutojumps[client] = 0;
	}

	aiJumps[client] = 0;
	new Float:tempvec[3];
	tempvec = avLastPos[client];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", avLastPos[client]);
		
	new Float:len = GetVectorDistance(avLastPos[client], tempvec, true);
	if (len < 30.0)
	{   
		aiIgnoreCount[client] = 2;
	}
		
	if (afAvgPerfJumps[client] >= 0.9)
	{
		if(g_info[client][Style] == 2)
		{

			new String:banstats[255];
			GetClientStats(client, banstats, sizeof(banstats));
			LogToFile(path, "%s, *ALERT* Paradise Security has detected a cheater!", banstats);
					
			decl String:nme[MAX_NAME_LENGTH];
					
			GetClientName(client, nme, MAX_NAME_LENGTH);
			
			Format(g_info[client][Status], 15, "BANNED");
			UpdatePlayer(client);
				
			PrintToChatAll(" \x01\x07**ALERT** Paradise Security has detected a cheater!");
			PrintToChatAll(" \x01\x07[Paradise-Security] \x01Identifying Player ID.");
			PrintToChatAll(" \x01\x07[Paradise-Security] \x01Identifying Player ID..");
			PrintToChatAll(" \x01\x07[Paradise-Security] \x01Identifying Player ID...");
			PrintToChatAll(" \x01\x07[Paradise-Security] \x01Player Identified! Name: \x01\x07%s", nme);
					
			PerformBan(client);
		}
	}
}

public SecurityFrameCheck()
{
    if (iTickCount > 1*MaxClients)
    {
        iTickCount = 1;
    }
    else
    {
        if (iTickCount % 1 == 0)
        {
            new index = iTickCount / 1;
            if (bSurfCheck[index] && IsClientInGame(index) && IsPlayerAlive(index))
            {	
                GetEntPropVector(index, Prop_Data, "m_vecVelocity", avVEL[index]);
                if (avVEL[index][2] < -290)
                {
                    aiIgnoreCount[index] = 2;
                }
                
            }
        }
        iTickCount++;
    }
}


public PerformBan(client)
{	
	new String:banreason[255], String:authid[50], String:kickmsg[50];
	GetClientAuthString(client, authid, sizeof(authid));
	Format(banreason, sizeof(banreason), "[Paradise Security]: Script Detected", client);
	Format(kickmsg, sizeof(kickmsg), "[Paradise Security]: Script Detected - BANNED", client);

	
	if (GetFeatureStatus(FeatureType_Native, "SBBanPlayer") == FeatureStatus_Available) {
		SBBanPlayer(0, client, 0, banreason);
	}
	else {
		BanClient(client, 0, BANFLAG_AUTO, banreason, kickmsg, "Paradise Security" );
	}
	
	KickClient(client, kickmsg);
	RemoveRecords(client, authid);
	PrintToChatAll(" \x01\x07[Paradise-Security] \x01Threat has been eliminated successfully!");
}


public Action:Command_Stats(client, args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: pb_check <#userid|name|@all>");
        return Plugin_Handled;
    }
    
    decl String:arg[65];
    GetCmdArg(1, arg, sizeof(arg));
    
    decl String:target_name[MAX_TARGET_LENGTH];
    decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
    
    if ((target_count = ProcessTargetString(
                    arg,
                    client,
                    target_list,
                    MAXPLAYERS,
                    COMMAND_FILTER_NO_IMMUNITY,
                    target_name,
                    sizeof(target_name),
                    tn_is_ml)) <= 0)
    {
        PrintToConsole(client, "Not found or invalid parameter.");
        return Plugin_Handled;
    }
    
    for (new i = 0; i < target_count; i++)
    {
        PerformStats(client, target_list[i]);
    }
    
    
    return Plugin_Handled;
}


PerformStats(client, target)
{
    	new String:banstats[256];
    	GetClientStats(target, banstats, sizeof(banstats));

    	PrintToConsole(client, "%s", banstats);
}

public GetClientStats(client, String:string[], length)
{
	new Float:perf = afAvgPerfJumps[client] * 100;
	
	Format(string, length, "%L Scroll pattern: %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i %i, Avg scroll pattern: %f, Avg speed: %f, Perfect jump ratio: %.2f",
    client,
    aaiLastJumps[client][0],
    aaiLastJumps[client][1],
    aaiLastJumps[client][2],
    aaiLastJumps[client][3],
    aaiLastJumps[client][4],
    aaiLastJumps[client][5],
    aaiLastJumps[client][6],
    aaiLastJumps[client][7],
    aaiLastJumps[client][8],
    aaiLastJumps[client][9],
    aaiLastJumps[client][10],
    aaiLastJumps[client][11],
    aaiLastJumps[client][12],
    aaiLastJumps[client][13],
    aaiLastJumps[client][14],
    aaiLastJumps[client][15],
    aaiLastJumps[client][16],
    aaiLastJumps[client][17],
    aaiLastJumps[client][18],
    aaiLastJumps[client][19],
    aaiLastJumps[client][20],
    aaiLastJumps[client][21],
    aaiLastJumps[client][22],
    aaiLastJumps[client][23],
    aaiLastJumps[client][24],
    aaiLastJumps[client][25],
    aaiLastJumps[client][26],
    aaiLastJumps[client][27],
    aaiLastJumps[client][28],
    aaiLastJumps[client][29],
	afAvgJumps[client],
	afAvgSpeed[client],
	perf);
}

public ScriptCheck(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(!IsFakeClient(client))
	{	

		if(g_info[client][Style] == 2)
		{
			if(IsPlayerAlive(client))
			{
				static bool:bHoldingJump[MAXPLAYERS + 1];
				static bLastOnGround[MAXPLAYERS + 1];

				if(buttons & IN_JUMP)
				{
						if(!bHoldingJump[client])
						{
							bHoldingJump[client] = true;//started pressing +jump
							aiJumps[client]++;
							
							if (bLastOnGround[client] && (GetEntityFlags(client) & FL_ONGROUND))
							{
									afAvgPerfJumps[client] = ( afAvgPerfJumps[client] * 9.0 + 0 ) / 10.0;
					   
							}
							else if (!bLastOnGround[client] && (GetEntityFlags(client) & FL_ONGROUND))
							{
									afAvgPerfJumps[client] = ( afAvgPerfJumps[client] * 9.0 + 1 ) / 10.0;
							}
						}
				}
				else if(bHoldingJump[client]) 
				{
					bHoldingJump[client] = false;//released (-jump)
				}

				bLastOnGround[client] = GetEntityFlags(client) & FL_ONGROUND;
			}
		}
	}
}