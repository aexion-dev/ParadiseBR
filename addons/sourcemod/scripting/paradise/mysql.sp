
enum Player
{
	Level,
	XP,
	XP_Needed,
	Style,
	Score,
	String:Status[15],
	Float:Auto,
	Float:Legit,
	Float:Freestyle,
	Float:Parkour,
	Float:HalfSideways,
	Float:Sideways,
	Float:WOnly,
	Jumps,
	Strafes,
	Float:PreSpeed,
	WallRuns,
	WallJumps,
	Float:BRPoints
}

new g_info[MAXPLAYERS+1][Player];

new g_mapchange[MAXPLAYERS+1][Player];
new Handle:MapChangeData;

new g_oldLevel[MAXPLAYERS+1];
new g_oldXP[MAXPLAYERS+1];

enum WorldRecord
{
	String:PlayerName[MAX_NAME_LENGTH],
	Float:Time,
}

new Auto_WR[WorldRecord];
new Legit_WR[WorldRecord];
new Freestyle_WR[WorldRecord];
new Parkour_WR[WorldRecord];
new HalfSideways_WR[WorldRecord];
new Sideways_WR[WorldRecord];
new WOnly_WR[WorldRecord];

new Handle:db = INVALID_HANDLE;
new Handle:trans = INVALID_HANDLE;
new String:Error[200];
new bool:ClientDataLoaded[MAXPLAYERS+1];
new bool:ClientRecordsLoaded[MAXPLAYERS+1];
new bool:WorldRecordsLoaded;

new String:g_curSSID[MAXPLAYERS+1][64];
new String:g_curMap[MAXPLAYERS+1][128];
new String:LastMenu[MAXPLAYERS+1][64];
new MapCounter;

new QueryCounter;

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Timer | MYSQL",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

//---------------------
//Connect To Database |
//---------------------

CreateDB(&Handle:DbHNDL)
{
	SQL_TConnect(SQL_OnConnect, "default");	
}
//Connection Callback
public SQL_OnConnect(Handle:owner, Handle:hndl, const String:error[], any:data) 
{ 
	if (hndl == INVALID_HANDLE) 
	{ 
		//It didn't work, so we log the error 
		PrintToServer("SQL ERROR: %s", error);
	} 
	else 
	{ 
		db = hndl;
		PrintToServer("[SQL] Connection Successful!");
		
		SQL_CreateTables();
	} 
}

//-------------------------------------------
//Create Tables (Records + Players + Zones) |
//-------------------------------------------

SQL_CreateTables()
{
	//Create Players Table (NAME, STEAMID, LEVEL, XP, JOINED, STATUS, & IP)

	decl String:Query[400];
	Format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS players (name TEXT, steamid VARCHAR(64), level SMALLINT, XP INT, score INT, joined VARCHAR(25), status VARCHAR(10), IP VARCHAR(64), UNIQUE (steamid));");
	SQL_TQuery(db, SQL_OnCreatedTable, Query);

	//Create Records Table (NAME, STEAMID, MAP, STYLE, RECORD, & RANK)

	Format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS records (name TEXT, steamid VARCHAR(64), map VARCHAR(64), style VARCHAR(20), record FLOAT, date VARCHAR(10), jumps SMALLINT, strafes SMALLINT, sync FLOAT, prespeed SMALLINT, wallruns SMALLINT, walljumps SMALLINT, UNIQUE (steamid,map,style));");
	SQL_TQuery(db, SQL_OnCreatedTable, Query);

	// Create Maps Table  (MAP, TIER, XP, STAGES, BONUS);
	Format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS maps (map TEXT, tier TINYINT, stages TEXT, XP INT);");
	SQL_TQuery(db, SQL_OnCreatedTable, Query);
	
	// Create Zones Table (MAP, TYPE, VERTS, HEIGHT, A1/A2/A3, B1/B2/B3, C1/C2/C3, D1/D2/D3, E1/E2/E3, F1/F2/F3)

	Format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS zones (map text, type TINYINT, verts TINYINT, height FLOAT, A1 FLOAT, A2 FLOAT, A3 FLOAT, B1 FLOAT, B2 FLOAT, B3 FLOAT, C1 FLOAT, C2 FLOAT, C3 FLOAT, D1 FLOAT, D2 FLOAT, D3 FLOAT, E1 FLOAT, E2 FLOAT, E3 FLOAT, F1 FLOAT, F2 FLOAT, F3 FLOAT)");
	SQL_TQuery(db, SQL_OnCreatedTable, Query);

	// Create VIP Table (MAP, STEAMID, STARS, TIER, XP);
	Format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS vip (steamid VARCHAR(64), amount FLOAT, model TEXT);");
	SQL_TQuery(db, SQL_OnCreatedTable, Query);
	
	// Create BR Table (MAP, STEAMID, STARS, TIER, XP);
	Format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS br (steamid VARCHAR(64), name TEXT, R1 FLOAT, R2 FLOAT, R3 FLOAT, R4 FLOAT, R5 FLOAT, points FLOAT);");
	SQL_TQuery(db, SQL_OnCreatedTable, Query);
}


//Create Tables CallBack
public SQL_OnCreatedTable(Handle:owner, Handle:hndl, const String:error[], any:data) 
{ 
	if (hndl == INVALID_HANDLE) 
	{ 
		PrintToServer("SQL ERROR: %s", error); 
	}
}


public BR_CreateTable()
{
	decl String:Query[500];
	
	trans = SQL_CreateTransaction();
	
	for(new f = 0; f <= 28; f++)
	{
		Format(Query, sizeof(Query), "INSERT INTO br (name, steamid, R1, R2, R3, R4, R5, points) VALUES ('%s', '%s', '0.0', '0.0', '0.0', '0.0', '0.0', '0.0')", AuthPlayer[f][AuthName], AuthPlayer[f][AuthSID]);
		SQL_AddQuery(trans, Query, 0);
	}
	
	SQL_ExecuteTransaction(db, trans, _, SQL_TransFailed, _, DBPrio_High);
}

public BR_SaveData(RNum)
{
	decl String:Query[500];
	
	trans = SQL_CreateTransaction();
	
	for(new i = 0; i <= 28; i++)
	{
		switch(RNum)
		{
			case 1:
			{
				Format(Query, sizeof(Query), "UPDATE br SET name='%s', R1='%f', points='%f' WHERE (steamid='%s')", AuthPlayer[i][AuthName], AuthPlayer[i][BRScore], AuthPlayer[i][BRScore], AuthPlayer[i][AuthSID]);
			}
			case 2:
			{
				Format(Query, sizeof(Query), "UPDATE br SET name='%s', R2='%f', points='%f' WHERE (steamid='%s')", AuthPlayer[i][AuthName], AuthPlayer[i][BRScore], AuthPlayer[i][BRScore], AuthPlayer[i][AuthSID]);
			}
			case 3:
			{
				Format(Query, sizeof(Query), "UPDATE br SET name='%s', R3='%f', points='%f' WHERE (steamid='%s')", AuthPlayer[i][AuthName], AuthPlayer[i][BRScore], AuthPlayer[i][BRScore], AuthPlayer[i][AuthSID]);
			}
			case 4:
			{
				Format(Query, sizeof(Query), "UPDATE br SET name='%s', R4='%f', points='%f' WHERE (steamid='%s')", AuthPlayer[i][AuthName], AuthPlayer[i][BRScore], AuthPlayer[i][BRScore], AuthPlayer[i][AuthSID]);
			}
			case 5:
			{
				Format(Query, sizeof(Query), "UPDATE br SET name='%s', R5='%f', points='%f' WHERE (steamid='%s')", AuthPlayer[i][AuthName], AuthPlayer[i][BRScore], AuthPlayer[i][BRScore], AuthPlayer[i][AuthSID]);
			}
		}
		
		SQL_AddQuery(trans, Query, 0);
	}
	/*
	for(new i = 1; i <= MaxClients; i++)
    {
		decl String:steamid[64],
		String:name[(MAX_NAME_LENGTH + 1) * 2],
		String:nameBuffer[MAX_NAME_LENGTH + 1];
		
		if(g_info[i][Level] > 0 && !IsFakeClient(i))
		{
			if(ClientDataLoaded[i] && GetClientAuthString(i, steamid, sizeof(steamid)))
			{
				if(IsValidClient(i, false))
				{
					GetClientName(i, nameBuffer, sizeof(nameBuffer));
					SQL_EscapeString(db, nameBuffer, name, sizeof(name));
					
					//Client Steam ID
					GetClientAuthString(i, steamid, sizeof(steamid));
					
					RPoints = g_info[i][BRPoints];
					
					switch(RNum)
					{
						case 1:
						{
							Format(Query, sizeof(Query), "UPDATE br SET name='%s', R1='%f', points='%f' WHERE (steamid='%s')", name, RPoints, RPoints, steamid);
						}
						case 2:
						{
							Format(Query, sizeof(Query), "UPDATE br SET name='%s', R2='%f', points='%f' WHERE (steamid='%s')", name, RPoints, RPoints, steamid);
						}
						case 3:
						{
							Format(Query, sizeof(Query), "UPDATE br SET name='%s', R3='%f', points='%f' WHERE (steamid='%s')", name, RPoints, RPoints, steamid);
						}
						case 4:
						{
							Format(Query, sizeof(Query), "UPDATE br SET name='%s', R4='%f', points='%f' WHERE (steamid='%s')", name, RPoints, RPoints, steamid);
						}
						case 5:
						{
							Format(Query, sizeof(Query), "UPDATE br SET name='%s', R5='%f', points='%f' WHERE (steamid='%s')", name, RPoints, RPoints, steamid);
						}
					}
					
					SQL_AddQuery(trans, Query, 0);
				}
			}
		}
	}*/
	
	SQL_ExecuteTransaction(db, trans, _, SQL_TransFailed, _, DBPrio_High);
}

public BR_LoadPlayerPoints(client)
{
	new userid = GetClientUserId(client);
	
	decl String:steamid[64],
	String:Query[255],
	bool:DataCheck;
	
	DataCheck = false;
	
	if(GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false))
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));

			//SQL Query
			Format(Query, sizeof(Query), "SELECT points FROM br WHERE (steamid='%s') LIMIT 1", steamid);
			SQL_TQuery(db, SQL_LoadBRData, Query, userid);
			QueryCounter++;
			
			DataCheck = true;
		}
	}
	
	if (!DataCheck)
	{
		PrintToServer("SQL ERROR: Failed to retrieve player BR data for %N", client);
		LogError("SQL ERROR: Failed to retrieve player data BR for %N - INVALID STEAMID", client);
	}
}
public SQL_LoadBRData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
		LogError("SQL ERROR: OnLoadBRData(%N) - %s", client, error);
	}
	
	if (client == 0)
	{
		return;
	}

	if(!SQL_FetchRow(hndl))
	{
		
	}
	else
	{
		g_info[client][BRPoints] = SQL_FetchFloat(hndl, 0);
	}	
}




//------------------------
//Player Table Functions |
//------------------------

//[ Create Player - New Player Has Joined The Server ]

public CreatePlayer(client)
{
	new userid = GetClientUserId(client);
	
	decl String:steamid[32], 
	String:name[(MAX_NAME_LENGTH + 1) * 2], 
	String:nameBuffer[MAX_NAME_LENGTH],
	String:date[20],
	String:status[15],
	String:ip[17],
	String:Query[255];

	GetClientName(client, nameBuffer, sizeof(nameBuffer));
	SQL_EscapeString(db, nameBuffer, name, sizeof(name));

	if(!ClientDataLoaded[client] && GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false))
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));

			//Current Date
			FormatTime(date, sizeof(date), "%Y-%m-%d", GetTime());

			//Client Status
			if(CheckCommandAccess(client, "sm_flag", ADMFLAG_GENERIC, true))
			{
				Format(status, sizeof(status), "ADMIN");
			}
			else if(CheckCommandAccess(client, "sm_flag", ADMFLAG_CUSTOM2, true))
			{
				Format(status, sizeof(status), "VIP");
			}
			else
			{
				Format(status, sizeof(status), "MEMBER");
			}
			
			//Client IP Address
			GetClientIP(client, ip, 17, true);

			//SQL Query
			Format(Query, sizeof(Query), "INSERT INTO players (name, steamid, level, XP, score, joined, status, IP) VALUES ('%s', '%s', '1', '0', '0', '%s', '%s', '%s')", name, steamid, date, status, ip);
			SQL_TQuery(db, SQL_CreatePlayer, Query, userid);
			QueryCounter++;
		}
	}
}
public SQL_CreatePlayer(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);
	
	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
		LogError("SQL ERROR: CreatePlayer(%N) - %s", client, error);
	}
	else
	{
		LoadPlayerData(client);
	}
}


//[ Update Player - Modify Existing Player's Data ]

public UpdatePlayer(client)
{
	new userid = GetClientUserId(client);
	
	decl String:steamid[64],
	String:name[(MAX_NAME_LENGTH + 1) * 2],
	String:nameBuffer[MAX_NAME_LENGTH + 1],
	String:Query[255];
	
	GetClientName(client, nameBuffer, sizeof(nameBuffer));
	SQL_EscapeString(db, nameBuffer, name, sizeof(name));
	
	if(g_info[client][Level] > 0)
	{
		if(ClientDataLoaded[client] && GetClientAuthString(client, steamid, sizeof(steamid)))
		{
			if(IsValidClient(client, false))
			{				
				//Client Steam ID
				GetClientAuthString(client, steamid, sizeof(steamid));
				
				//SQL Query
				Format(Query, sizeof(Query), "UPDATE players SET name='%s', level='%i', XP='%i', score='%i', status='%s' WHERE (steamid='%s')", name, g_info[client][Level], g_info[client][XP], g_info[client][Score], g_info[client][Status], steamid);
				SQL_TQuery(db, SQL_ErrorCallback, Query, userid);
				QueryCounter++;
				
				g_info[client][Level] = 0;
				g_info[client][XP] = 0;
				g_info[client][XP_Needed] = 0;
				g_info[client][Score] = 0;
				Format(g_info[client][Status], 15, "INVALID");
			}
		}
	}
	else
	{
		if(ClientDataLoaded[client] && GetClientAuthString(client, steamid, sizeof(steamid)))
		{
			if(IsValidClient(client, false))
			{		
				PrintToChat(client, " \x01\x06[Paradise SQL] \x01Unable to save your data, your level is incorrect!");
			}
		}
	}
}


public UpdateCurrentPlayers()
{
	decl String:Query[500];
	
	trans = SQL_CreateTransaction();
	
	for(new i = 1; i <= MaxClients; i++)
    {
		decl String:steamid[64],
		String:name[(MAX_NAME_LENGTH + 1) * 2],
		String:nameBuffer[MAX_NAME_LENGTH + 1];
		
		if(g_info[i][Level] > 0)
		{
			if(ClientDataLoaded[i] && GetClientAuthString(i, steamid, sizeof(steamid)))
			{
				if(IsValidClient(i, false))
				{
					GetClientName(i, nameBuffer, sizeof(nameBuffer));
					SQL_EscapeString(db, nameBuffer, name, sizeof(name));
					
					//Client Steam ID
					GetClientAuthString(i, steamid, sizeof(steamid));
					
					if((g_oldLevel[i] != g_info[i][Level] && g_info[i][Level] > 0) || (g_oldXP[i] != g_info[i][XP] && g_info[i][Level] > 0))
					{
						Format(Query, 500, "UPDATE players SET name='%s', level='%i', XP='%i', score='%i', status='%s' WHERE (steamid='%s')", name, g_info[i][Level], g_info[i][XP], g_info[i][Score], g_info[i][Status], steamid); 
						SQL_AddQuery(trans, Query, 0);
						
						g_oldLevel[i] = -1;
						g_oldXP[i] = -1;
						
						QueryCounter++;
					}
					
					g_mapchange[i][Level] = g_info[i][Level];
					g_mapchange[i][XP] = g_info[i][XP];
					g_mapchange[i][XP_Needed] = g_info[i][XP_Needed];
					g_mapchange[i][Score] = g_info[i][Score];
					//g_mapchange[i][BRPoints] = g_info[i][BRPoints];
					
					strcopy(g_mapchange[i][Status], 15, g_info[i][Status]);
					
					SetTrieValue(MapChangeData, steamid, i, true);
				}
				else if(!IsClientInGame(i))
				{
					LogMessage("[%s]: %N is not in the game! Unable to save player data.", Map[MapName], i)
				}
			}
		}
	}
	
	SQL_ExecuteTransaction(db, trans, _, SQL_TransFailed, _, DBPrio_Low);
}

//[ Load Player Data - Load/Refresh Existing Player's Data ]

public LoadPlayerData(client)
{
	new userid = GetClientUserId(client);
	
	decl String:steamid[64],
	String:Query[255],
	bool:DataCheck;
	
	DataCheck = false;
	
	if(GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false))
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));

			//SQL Query
			Format(Query, sizeof(Query), "SELECT level, XP, score FROM players WHERE (steamid='%s') LIMIT 1", steamid);
			SQL_TQuery(db, SQL_LoadPlayerData, Query, userid);
			QueryCounter++;
			
			DataCheck = true;
		}
	}
	
	if (!DataCheck)
	{
		PrintToServer("SQL ERROR: Failed to retrieve player data for %N", client);
		LogError("SQL ERROR: Failed to retrieve player data for %N - INVALID STEAMID", client);
	}
}
public SQL_LoadPlayerData(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
		LogError("SQL ERROR: OnLoadPlayerData(%N) - %s", client, error);
	}
	
	if (client == 0)
	{
		return;
	}

	if(!SQL_FetchRow(hndl))
	{
		CreatePlayer(client);
	}
	else
	{
		g_info[client][Level] = SQL_FetchInt(hndl, 0);
		g_info[client][XP] = SQL_FetchInt(hndl, 1);
		new L = g_info[client][Level];
		g_info[client][XP_Needed] = ((L * L + L + 3) * 4);
		g_info[client][Score] = SQL_FetchInt(hndl, 2);
		
		g_oldLevel[client] = g_info[client][Level];
		g_oldXP[client] = g_info[client][XP];
		
		if(g_info[client][Score] <= 0 && g_info[client][Level] >= 2)
		{
			//Calculate Clients Score
			CalculateScore(client);
		}
		
		ClientDataLoaded[client] = true;
		SetLevelTag(client);
	}	
}

//[ Lookup Player - Convert Player Name to Steam ID ]

public LookupPlayer(client, const String:PlayerSearch[])
{
	new userid = GetClientUserId(client);
	
	decl String:name[(MAX_NAME_LENGTH + 1) * 2];
	decl String:nameBuffer[MAX_NAME_LENGTH + 1];
	decl String:percentBuffer[120];
	decl String:Query[255];
	
	Format(nameBuffer, sizeof(nameBuffer), "%s", PlayerSearch);
	
	SQL_EscapeString(db, nameBuffer, name, sizeof(name));
	Format(percentBuffer, sizeof(percentBuffer), "_%s_", name);
	ReplaceString(percentBuffer, sizeof(percentBuffer), "_", "%%");
	
	Format(Query, sizeof(Query), "SELECT steamid, name, level FROM players WHERE name LIKE '%s'", percentBuffer);
	SQL_TQuery(db, SQL_PlayerSearch, Query, userid);
	QueryCounter++;
}

public SQL_PlayerSearch(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	new rowCount;
	
	if(SQL_HasResultSet(hndl))
	{
		rowCount = SQL_GetRowCount(hndl);
	}
	else
	{
		PrintToChat(client, " \x01\x06[Paradise]: \x01No Players Found Matching That Name!");
	}
	
	if(rowCount <= 0)
	{
		if(SQL_HasResultSet(hndl))
		{
			PrintToChat(client, " \x01\x06[Paradise]: \x01No Players Found Matching That Name!");
		}
	}
	else if(rowCount == 1)
	{
		if(SQL_HasResultSet(hndl))
		{
			decl String:S_SID[64];
			
			if(SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, S_SID, 64);
			}
			
			LoadProfile(client, S_SID);
			
			PrintToChat(client, " \x01\x06[Paradise]: \x01Player Found! Loading Profile..");
		}
	}
	else if(rowCount > 1)
	{
		decl String:sql_name[64], String:sql_sid[64], String:sql_item[128];
		
		new sql_level;
		
		new Handle:menu = CreateMenu(PlayerSearchHandler);
		SetMenuTitle(menu, "Paradise Player Search");
		
		if(SQL_HasResultSet(hndl))
		{
			while(SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, sql_sid, 64);
				SQL_FetchString(hndl, 1, sql_name, 64);
				sql_level = SQL_FetchInt(hndl, 2);
				
				Format(sql_item, 128, "[Lv.%i] %s", sql_level, sql_name);
				
				AddMenuItem(menu, sql_sid, sql_item, ITEMDRAW_DEFAULT);
			}
			
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
	}
}

public PlayerSearchHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		LoadProfile(param1, info);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

//[ Load Player Profile - Load Profile via SteamID ]

public LoadProfile(client, const String:PlayerSID[])
{
	new userid = GetClientUserId(client);
	
	decl String:Query[500];
	
	trans = SQL_CreateTransaction();
	
	Format(Query, 500, "SELECT name AS PlayerInfo, level, steamid, score FROM players WHERE steamid = '%s' LIMIT 1", PlayerSID); 
	SQL_AddQuery(trans, Query, 0);

	
	SQL_AddQuery(trans, "SELECT COUNT(*) AS RankTotal FROM players WHERE level >= '1' AND score IS NOT NULL AND status != 'BANNED'", 0);
	
	Format(Query, 500, "SELECT rank AS RankUser FROM (SELECT uo.*, (SELECT COUNT(*) FROM players ui WHERE (ui.score, ui.level) >= (uo.score, uo.level)) AS rank FROM players uo WHERE steamid = '%s') AS temp2", PlayerSID);
	SQL_AddQuery(trans, Query, 0);

	Format(Query, 500, "SELECT COUNT(*) AS WRCount FROM (SELECT f.steamid, f.style, f.map, f.record FROM (SELECT style, map, min(record) as minrecord FROM records GROUP BY map, style) as x INNER JOIN records AS f ON f.map = x.map AND f.style = x.style AND f.record = x.minrecord AND f.steamid = '%s') AS temp1", PlayerSID);
	SQL_AddQuery(trans, Query, 0);
	
	Format(Query, 500, "SELECT COUNT(*) AS MapComp FROM (SELECT * FROM (SELECT `record`,`map`,`steamid` FROM `records` WHERE record > 0 GROUP BY `records`.`map`, `records`.`steamid`) AS temp WHERE `steamid` = '%s') AS temp1", PlayerSID);
	SQL_AddQuery(trans, Query, 0);
	
	Format(Query, 500, "SELECT name AS PBRecords, steamid, record, style FROM records WHERE `steamid` = '%s' AND `map` = '%s' GROUP BY style", PlayerSID, Map[MapName]);
	SQL_AddQuery(trans, Query, 0);
	
	SQL_ExecuteTransaction(db, trans, SQL_LoadProfileSuccess, SQL_LoadProfileFailed, userid);
	QueryCounter++;
}

public SQL_LoadProfileSuccess(Handle:owner, any:data, numQueries, Handle:results[], any:queryData[])
{
	decl String:sFieldName[64];
	decl String:pSSID[64];
	decl String:profileName[MAX_NAME_LENGTH], profileLevel, profileScore, userRank, totalRank, WRCount, MapComp;
	decl String:TimeString[7][32];
	decl Float:RecordTime;
	
	new client = GetClientOfUserId(data);
	
	Format(TimeString[0], 32, "None");
	Format(TimeString[1], 32, "None");
	Format(TimeString[2], 32, "None");
	Format(TimeString[3], 32, "None");
	Format(TimeString[4], 32, "None");
	Format(TimeString[5], 32, "None");
	Format(TimeString[6], 32, "None");
	
	for(new i = 0; i < numQueries; i++)
	{				
		if(SQL_FetchRow(results[i]) == false)
			continue;
		
		SQL_FieldNumToName(results[i], 0, sFieldName, sizeof(sFieldName));
		
		if(StrEqual(sFieldName, "PlayerInfo"))
		{
			SQL_FetchString(results[i], 0, profileName, MAX_NAME_LENGTH);
			profileLevel = SQL_FetchInt(results[i], 1);
			SQL_FetchString(results[i], 2, pSSID, 64);
			profileScore = SQL_FetchInt(results[i], 3);
		}
		else if(StrEqual(sFieldName, "RankTotal"))
		{
			totalRank = SQL_FetchInt(results[i], 0);
		}
		else if(StrEqual(sFieldName, "RankUser"))
		{
			userRank = SQL_FetchInt(results[i], 0);
		}
		else if(StrEqual(sFieldName, "WRCount"))
		{
			WRCount = SQL_FetchInt(results[i], 0);
		}
		else if(StrEqual(sFieldName, "MapComp"))
		{
			MapComp = SQL_FetchInt(results[i], 0);
		}
		else if(StrEqual(sFieldName, "PBRecords"))
		{
			decl String:StyleResult[32];
			
			SQL_FetchString(results[i], 3, StyleResult, 32);
			
			if(StrEqual(StyleResult, "Auto"))
			{
				RecordTime = SQL_FetchFloat(results[i], 2);
				FormatPlayerTime(RecordTime, TimeString[0], 32, false, 0);
				Format(TimeString[0], 32, "%ss", TimeString[0]);
			}
			
			while(SQL_FetchRow(results[i]))
			{
				SQL_FetchString(results[i], 3, StyleResult, 32);
				
				if(StrEqual(StyleResult, "Legit"))
				{
					RecordTime = SQL_FetchFloat(results[i], 2);
					FormatPlayerTime(RecordTime, TimeString[1], 32, false, 0);
					Format(TimeString[1], 32, "%ss", TimeString[1]);
				}
				else if(StrEqual(StyleResult, "Freestyle"))
				{
					RecordTime = SQL_FetchFloat(results[i], 2);
					FormatPlayerTime(RecordTime, TimeString[2], 32, false, 0);
					Format(TimeString[2], 32, "%ss", TimeString[2]);
				}
				else if(StrEqual(StyleResult, "Parkour"))
				{
					RecordTime = SQL_FetchFloat(results[i], 2);
					FormatPlayerTime(RecordTime, TimeString[3], 32, false, 0);
					Format(TimeString[3], 32, "%ss", TimeString[3]);
				}
				else if(StrEqual(StyleResult, "Half-Sideways"))
				{
					RecordTime = SQL_FetchFloat(results[i], 2);
					FormatPlayerTime(RecordTime, TimeString[4], 32, false, 0);
					Format(TimeString[4], 32, "%ss", TimeString[4]);
				}
				else if(StrEqual(StyleResult, "Sideways"))
				{
					RecordTime = SQL_FetchFloat(results[i], 2);
					FormatPlayerTime(RecordTime, TimeString[5], 32, false, 0);
					Format(TimeString[5], 32, "%ss", TimeString[5]);
				}
				else if(StrEqual(StyleResult, "W-Only"))
				{
					RecordTime = SQL_FetchFloat(results[i], 2);
					FormatPlayerTime(RecordTime, TimeString[6], 32, false, 0);
					Format(TimeString[6], 32, "%ss", TimeString[6]);
				}
			}
		}
	}

	ShowProfile(client, pSSID, profileName, profileLevel, profileScore, userRank, totalRank, WRCount, MapComp, TimeString);
}

public SQL_LoadProfileFailed(Handle:owner, any:data, numQueries, const String:error[], failIndex, any:queryData[])
{	
	LogError(error[failIndex]);
}

public LoadInfo(client, const String:PlayerSID[])
{
	new userid = GetClientUserId(client);
	
	decl String:Query[500];
	
	trans = SQL_CreateTransaction();
	
	Format(Query, 500, "SELECT name AS PlayerInfo, steamid, joined, status FROM players WHERE steamid = '%s' LIMIT 1", PlayerSID);
	SQL_AddQuery(trans, Query, 0);
	
	Format(Query, 500, "SELECT `style` AS FavStyle, COUNT(`style`) AS `value_occurrence` FROM (SELECT style, steamid FROM records WHERE steamid = '%s') AS temp1 GROUP BY `style` ORDER BY `value_occurrence` DESC LIMIT 1", PlayerSID);
	SQL_AddQuery(trans, Query, 0);	
	
	SQL_ExecuteTransaction(db, trans, SQL_LoadInfoSuccess, SQL_LoadProfileFailed, userid);
	QueryCounter++;
}

public SQL_LoadInfoSuccess(Handle:owner, any:data, numQueries, Handle:results[], any:queryData[])
{
	decl String:sFieldName[64];
	decl String:profileName[MAX_NAME_LENGTH], String:profileSSID[64], String:profileDate[32], String:profileStatus[32], String:profileStyle[32];
	
	new client = GetClientOfUserId(data);
	
	for(new i = 0; i < numQueries; i++)
	{				
		if(SQL_FetchRow(results[i]) == false)
			continue;
		
		SQL_FieldNumToName(results[i], 0, sFieldName, sizeof(sFieldName));
		
		if(StrEqual(sFieldName, "PlayerInfo"))
		{
			SQL_FetchString(results[i], 0, profileName, MAX_NAME_LENGTH);
			SQL_FetchString(results[i], 1, profileSSID, 64);
			SQL_FetchString(results[i], 2, profileDate, 32);
			SQL_FetchString(results[i], 3, profileStatus, 32);
		}
		else if(StrEqual(sFieldName, "FavStyle"))
		{
			SQL_FetchString(results[i], 0, profileStyle, 32);
		}
	}
	
	ShowPlayerInfo(client, profileSSID, profileName, profileDate, profileStyle, profileStatus);
	
}

//[ Calculate Player's Ranking Score - Level = x10 | Record = x10 | Map = x100 | WR = x.01 ]

public CalculateScore(client)
{
	new userid = GetClientUserId(client);
	
	decl String:Query[500];
	decl String:steamid[64];
	
	GetClientAuthString(client, steamid, sizeof(steamid));
	
	trans = SQL_CreateTransaction();
	
	Format(Query, 500, "SELECT level AS PlayerInfo FROM players WHERE steamid = '%s' LIMIT 1", steamid); 
	SQL_AddQuery(trans, Query, 0);
	
	Format(Query, 500, "SELECT COUNT(*) AS WRCount FROM (SELECT f.steamid, f.style, f.map, f.record FROM (SELECT style, map, min(record) as minrecord FROM records GROUP BY map, style) as x INNER JOIN records AS f ON f.map = x.map AND f.style = x.style AND f.record = x.minrecord AND f.steamid = '%s') AS temp1", steamid);
	SQL_AddQuery(trans, Query, 0);
	
	Format(Query, 500, "SELECT COUNT(*) AS MapComp FROM (SELECT * FROM (SELECT `record`,`map`,`steamid` FROM `records` WHERE record > 0 GROUP BY `records`.`map`, `records`.`steamid`) AS temp WHERE `steamid` = '%s') AS temp1", steamid);
	SQL_AddQuery(trans, Query, 0);
	
	Format(Query, 500, "SELECT COUNT(*) AS RecordCount FROM records WHERE steamid = '%s'", steamid);
	SQL_AddQuery(trans, Query, 0);
	
	SQL_ExecuteTransaction(db, trans, SQL_CalcScoreSuccess, SQL_LoadProfileFailed, userid);
	QueryCounter++;
}

public SQL_CalcScoreSuccess(Handle:owner, any:data, numQueries, Handle:results[], any:queryData[])
{
	decl String:sFieldName[64];
	decl sql_level, sql_score, sql_wrcount, sql_mapcount, sql_recordcount;
	
	new client = GetClientOfUserId(data);
	
	for(new i = 0; i < numQueries; i++)
	{				
		if(SQL_FetchRow(results[i]) == false)
			continue;
		
		SQL_FieldNumToName(results[i], 0, sFieldName, sizeof(sFieldName));
		
		if(StrEqual(sFieldName, "PlayerInfo"))
		{
			sql_level = SQL_FetchInt(results[i], 0);
		}
		else if(StrEqual(sFieldName, "WRCount"))
		{
			sql_wrcount = SQL_FetchInt(results[i], 0);
		}
		else if(StrEqual(sFieldName, "MapComp"))
		{
			sql_mapcount = SQL_FetchInt(results[i], 0);
		}
		else if(StrEqual(sFieldName, "RecordCount"))
		{
			sql_recordcount = SQL_FetchInt(results[i], 0);
		}
	}
	
	decl MapAvg, MapTotal;
	
	MapTotal = MapCounter;
	MapAvg = RoundToFloor(((float(sql_mapcount))/(float(MapTotal))) * 100.0);
	
	sql_score = RoundToFloor((((sql_level * 10) - 10) + (sql_recordcount * 10) + (MapAvg * 100)) * (1 + (sql_wrcount * 0.01)));
	
	g_info[client][Score] = sql_score;
	
	//PrintToChatAll("Score Calculated: %i", g_info[client][Score]);
}





//------------------------
//Record Table Functions |
//------------------------

//[ Create Record - Create A Record In The Database ]

public CreateRecord(client, const String:map[], const String:style[], Float:record, jumps, strafes, Float:sync, Float:prespeed, wallruns, walljumps)
{
	new userid = GetClientUserId(client);

	decl String:steamid[32],
	String:name[(MAX_NAME_LENGTH + 1) * 2],
	String:nameBuffer[MAX_NAME_LENGTH],
	String:date[20],
	String:Query[500];
	
	GetClientName(client, nameBuffer, sizeof(nameBuffer));
	SQL_EscapeString(db, nameBuffer, name, sizeof(name));
	

	if(ClientDataLoaded[client] && GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false)) //true?
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));

			//Current Date
			FormatTime(date, sizeof(date), "%Y-%m-%d", GetTime());
			
			if((StrEqual(style, "Auto")) || (StrEqual(style, "Legit")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "INSERT INTO records (name, steamid, map, style, record, date, jumps, strafes, sync) VALUES ('%s', '%s', '%s', '%s', '%f', '%s', '%i', '%i', '%f')", name, steamid, map, style, record, date, jumps, strafes, sync);
			}
			else if((StrEqual(style, "Freestyle")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "INSERT INTO records (name, steamid, map, style, record, date, jumps, strafes, sync, prespeed) VALUES ('%s', '%s', '%s', '%s', '%f', '%s', '%i', '%i', '%f', '%f')", name, steamid, map, style, record, date, jumps, strafes, sync, prespeed);
			}
			else if((StrEqual(style, "Parkour")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "INSERT INTO records (name, steamid, map, style, record, date, jumps, strafes, sync, prespeed, wallruns, walljumps) VALUES ('%s', '%s', '%s', '%s', '%f', '%s', '%i', '%i', '%f', '%f', '%i', '%i')", name, steamid, map, style, record, date, jumps, strafes, sync, prespeed, wallruns, walljumps);
			}
			else if((StrEqual(style, "Half-Sideways")) || (StrEqual(style, "Sideways")) || (StrEqual(style, "W-Only")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "INSERT INTO records (name, steamid, map, style, record, date, jumps) VALUES ('%s', '%s', '%s', '%s', '%f', '%s', '%i')", name, steamid, map, style, record, date, jumps);
			}
			
			SQL_TQuery(db, SQL_ErrorCallback, Query, userid);
			QueryCounter++;
		}
	}	
}

//[ Update Record - Modify Existing Player Record ]

public UpdateRecord(client, const String:map[], const String:style[], Float:record, jumps, strafes, Float:sync, Float:prespeed, wallruns, walljumps)
{
	new userid = GetClientUserId(client);

	decl String:steamid[32],
	String:name[(MAX_NAME_LENGTH + 1) * 2],
	String:nameBuffer[MAX_NAME_LENGTH],
	String:date[20],
	String:Query[700];

	GetClientName(client, nameBuffer, sizeof(nameBuffer));
	SQL_EscapeString(db, nameBuffer, name, sizeof(name));

	if(ClientDataLoaded[client] && GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false)) //true?
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));

			//Current Date
			FormatTime(date, sizeof(date), "%Y-%m-%d", GetTime());
			
			if((StrEqual(style, "Auto")) || (StrEqual(style, "Legit")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "UPDATE records SET name='%s', record='%f', date='%s', jumps='%i', strafes='%i', sync='%f' WHERE (steamid='%s') AND (map='%s') AND (style='%s') AND (record>'%f' OR record IS NULL)", name, record, date, jumps, strafes, sync, steamid, map, style, record);
			}
			else if((StrEqual(style, "Freestyle")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "UPDATE records SET name='%s', record='%f', date='%s', jumps='%i', strafes='%i', sync='%f', prespeed='%f' WHERE (steamid='%s') AND (map='%s') AND (style='%s') AND (record>'%f' OR record IS NULL)", name, record, date, jumps, strafes, sync, prespeed, steamid, map, style, record);
			}
			else if((StrEqual(style, "Parkour")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "UPDATE records SET name='%s', record='%f', date='%s', jumps='%i', strafes='%i', sync='%f', prespeed='%f', wallruns='%i', walljumps='%i' WHERE (steamid='%s') AND (map='%s') AND (style='%s') AND (record>'%f' OR record IS NULL)", name, record, date, jumps, strafes, sync, prespeed, wallruns, walljumps, steamid, map, style, record);
			}
			else if((StrEqual(style, "Half-Sideways")) || (StrEqual(style, "Sideways")) || (StrEqual(style, "W-Only")))
			{
				//SQL Query
				Format(Query, sizeof(Query), "UPDATE records SET name='%s', record='%f', date='%s', jumps='%i' WHERE (steamid='%s') AND (map='%s') AND (style='%s') AND (record>'%f' OR record IS NULL)", name, record, date, jumps, steamid, map, style, record);
			}
			
			SQL_TQuery(db, SQL_ErrorCallback, Query, userid);
			QueryCounter++;			
		}
	}
}

//[ Remove Records - Erases All Client Records For A Given Steam ID ]

public RemoveRecords(client, const String:steamid[])
{
	new userid = GetClientUserId(client);

	decl String:Query[255];
	
	//SQL Query
	Format(Query, sizeof(Query), "DELETE FROM records WHERE (steamid='%s')", steamid);
	SQL_TQuery(db, SQL_ErrorCallback, Query, userid);
	QueryCounter++;
}

//[ Load Player Records - Load/Cache Client's Records For All Styles ]

public LoadPlayerRecords(client, const String:map[])
{
	new userid = GetClientUserId(client);
	
	decl String:steamid[64],
	String:Query[500],
	bool:DataCheck;
	
	DataCheck = false;
	
	if(GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false))
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));
			
			trans = SQL_CreateTransaction();
			
			Format(Query, 500, "SELECT record AS PBRecords, style FROM records WHERE `steamid` = '%s' AND `map` = '%s' GROUP BY style LIMIT 7", steamid, Map[MapName]);
			SQL_AddQuery(trans, Query, 0);
	
			SQL_ExecuteTransaction(db, trans, SQL_LoadPlayerRecords, SQL_TransFailed, userid);
			QueryCounter++;
			
			DataCheck = true;
		}
	}
	
	if (!DataCheck)
	{
		LogError("SQL ERROR: Failed to retrieve player records for %N", client);
		PrintToServer("SQL ERROR: Failed to retrieve player records for %N", client);
	}
}

public SQL_LoadPlayerRecords(Handle:owner, any:data, numQueries, Handle:results[], any:queryData[])
{
	decl String:sFieldName[64];
	
	new client = GetClientOfUserId(data);
	
	g_info[client][Auto] = 0.0;
	g_info[client][Legit] = 0.0;
	g_info[client][Freestyle] = 0.0;
	g_info[client][Parkour] = 0.0;
	g_info[client][HalfSideways] = 0.0;
	g_info[client][Sideways] = 0.0;
	g_info[client][WOnly] = 0.0;
	
	for(new i = 0; i < numQueries; i++)
	{				
		if(SQL_FetchRow(results[i]) == false)
			continue;
		
		SQL_FieldNumToName(results[i], 0, sFieldName, sizeof(sFieldName));
		
		if(StrEqual(sFieldName, "PBRecords"))
		{
			decl String:StyleResult[32];
			
			SQL_FetchString(results[i], 1, StyleResult, 32);
			
			if(StrEqual(StyleResult, "Auto"))
			{
				g_info[client][Auto] = SQL_FetchFloat(results[i], 0);
			}
			else if(StrEqual(StyleResult, "Legit"))
			{
				g_info[client][Legit] = SQL_FetchFloat(results[i], 0);
			}
			else if(StrEqual(StyleResult, "Freestyle"))
			{
				g_info[client][Freestyle] = SQL_FetchFloat(results[i], 0);
			}
			else if(StrEqual(StyleResult, "Parkour"))
			{
				g_info[client][Parkour] = SQL_FetchFloat(results[i], 0);
			}
			else if(StrEqual(StyleResult, "Half-Sideways"))
			{
				g_info[client][HalfSideways] = SQL_FetchFloat(results[i], 0);
			}
			else if(StrEqual(StyleResult, "Sideways"))
			{
				g_info[client][Sideways] = SQL_FetchFloat(results[i], 0);
			}
			else if(StrEqual(StyleResult, "W-Only"))
			{
				g_info[client][WOnly] = SQL_FetchFloat(results[i], 0);
			}
			
			while(SQL_FetchRow(results[i]))
			{
				SQL_FetchString(results[i], 1, StyleResult, 32);
				
				if(StrEqual(StyleResult, "Legit"))
				{
					g_info[client][Legit] = SQL_FetchFloat(results[i], 0);
				}
				else if(StrEqual(StyleResult, "Freestyle"))
				{
					g_info[client][Freestyle] = SQL_FetchFloat(results[i], 0);
				}
				else if(StrEqual(StyleResult, "Parkour"))
				{
					g_info[client][Parkour] = SQL_FetchFloat(results[i], 0);
				}
				else if(StrEqual(StyleResult, "Half-Sideways"))
				{
					g_info[client][HalfSideways] = SQL_FetchFloat(results[i], 0);
				}
				else if(StrEqual(StyleResult, "Sideways"))
				{
					g_info[client][Sideways] = SQL_FetchFloat(results[i], 0);
				}
				else if(StrEqual(StyleResult, "W-Only"))
				{
					g_info[client][WOnly] = SQL_FetchFloat(results[i], 0);
				}
			}
		}
	}
	
	ClientRecordsLoaded[client] = true;
}

//[ Load World Records - Load/Cache World Records For The Current Map ]

public LoadWorldRecords(const String:map[])
{
	decl String:Query[500];
	
	trans = SQL_CreateTransaction();
	
	Format(Query, 500, "SELECT name AS WorldRecords, record, style FROM (SELECT f.name, f.style, f.map, f.record FROM (SELECT style, map, min(record) as minrecord FROM records GROUP BY map, style) as x INNER JOIN records AS f ON f.map = x.map AND f.style = x.style AND f.record = x.minrecord AND f.record > 0) as temp1 WHERE temp1.map = '%s' ORDER BY style ASC", map);
	SQL_AddQuery(trans, Query, 0);

	SQL_ExecuteTransaction(db, trans, SQL_LoadWorldRecords, SQL_TransFailed, _, DBPrio_High);
	QueryCounter++;
}

public SQL_LoadWorldRecords(Handle:owner, any:data, numQueries, Handle:results[], any:queryData[])
{
	decl String:sFieldName[64];
	decl String:TimeString[7][32];
	
	
	for(new i = 0; i < numQueries; i++)
	{				
		if(SQL_FetchRow(results[i]) == false)
			continue;
		
		SQL_FieldNumToName(results[i], 0, sFieldName, sizeof(sFieldName));
		
		if(StrEqual(sFieldName, "WorldRecords"))
		{
			decl String:StyleResult[32];
			
			SQL_FetchString(results[i], 2, StyleResult, 32);
			
			if(StrEqual(StyleResult, "Auto"))
			{
				Auto_WR[Time] = SQL_FetchFloat(results[i], 1);
				SQL_FetchString(results[i], 0, Auto_WR[PlayerName], MAX_NAME_LENGTH);
			}
			
			while(SQL_FetchRow(results[i]))
			{
				SQL_FetchString(results[i], 2, StyleResult, 32);
				
				if(StrEqual(StyleResult, "Legit"))
				{
					Legit_WR[Time] = SQL_FetchFloat(results[i], 1);
					SQL_FetchString(results[i], 0, Legit_WR[PlayerName], MAX_NAME_LENGTH);
				}
				else if(StrEqual(StyleResult, "Freestyle"))
				{
					Freestyle_WR[Time] = SQL_FetchFloat(results[i], 1);
					SQL_FetchString(results[i], 0, Freestyle_WR[PlayerName], MAX_NAME_LENGTH);
				}
				else if(StrEqual(StyleResult, "Parkour"))
				{
					Parkour_WR[Time] = SQL_FetchFloat(results[i], 1);
					SQL_FetchString(results[i], 0, Parkour_WR[PlayerName], MAX_NAME_LENGTH);
				}
				else if(StrEqual(StyleResult, "Half-Sideways"))
				{
					HalfSideways_WR[Time] = SQL_FetchFloat(results[i], 1);
					SQL_FetchString(results[i], 0, HalfSideways_WR[PlayerName], MAX_NAME_LENGTH);
				}
				else if(StrEqual(StyleResult, "Sideways"))
				{
					Sideways_WR[Time] = SQL_FetchFloat(results[i], 1);
					SQL_FetchString(results[i], 0, Sideways_WR[PlayerName], MAX_NAME_LENGTH);
				}
				else if(StrEqual(StyleResult, "W-Only"))
				{
					WOnly_WR[Time] = SQL_FetchFloat(results[i], 1);
					SQL_FetchString(results[i], 0, WOnly_WR[PlayerName], MAX_NAME_LENGTH);
				}
			}

		}
	}
	
	WorldRecordsLoaded = true;
}

public WRLookup(client, const String:WR_Map[], const String:WR_Style[])
{
	new userid = GetClientUserId(client);
	
	decl String:Query[500];
	
	Format(Query, 500, "SELECT steamid, map, style FROM (SELECT f.steamid, f.style, f.map, f.record FROM (SELECT style, map, min(record) as minrecord FROM records GROUP BY map, style) as x INNER JOIN records AS f ON f.map = x.map AND f.style = x.style AND f.record = x.minrecord AND f.record > 0) as temp1 WHERE temp1.map = '%s' AND temp1.style = '%s' LIMIT 1", WR_Map, WR_Style);

	SQL_TQuery(db, SQL_WRLookup, Query, userid);
	QueryCounter++;
}

public SQL_WRLookup(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sql_ssid[64], String:sql_map[128], String:sql_style[64];


	if(SQL_HasResultSet(hndl))
	{		
		while(SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, sql_ssid, sizeof(sql_ssid));
			SQL_FetchString(hndl, 1, sql_map, sizeof(sql_map));
			SQL_FetchString(hndl, 2, sql_style, sizeof(sql_style));
		}
		
		ViewRecord(client, sql_ssid, sql_map, sql_style);
	}
	else
	{
		PrintToChat(client, " \x01\x06[Paradise]: \x01Map Not Found! Make Sure To Include '_csgo'");
	}
}

public ViewRecord(client, const String:PlayerSID[], const String:PlayerMap[], const String:PlayerStyle[])
{
	new userid = GetClientUserId(client);
	
	decl String:Query[500];
	
	Format(Query, 500, "SELECT * FROM records WHERE steamid = '%s' AND map = '%s' AND style = '%s'", PlayerSID, PlayerMap, PlayerStyle);

	SQL_TQuery(db, SQL_ViewRecord, Query, userid);
	QueryCounter++;
}

public SQL_ViewRecord(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sql_map[128], String:sql_ssid[64], String:sql_style[64], String:sql_name[MAX_NAME_LENGTH], String:sql_date[64], sql_jumps, sql_strafes, Float:sql_sync, Float:sql_prespeed, sql_wallruns, sql_walljumps;
	decl Float:RecordTime, String:TimeString[32];
	
	sql_jumps = 0;
	sql_strafes = 0;
	sql_sync = 0.0;
	sql_prespeed = 0.0;
	sql_wallruns = 0;
	sql_walljumps = 0;

	if(SQL_HasResultSet(hndl))
	{		
		while(SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, sql_name, sizeof(sql_name));
			SQL_FetchString(hndl, 1, sql_ssid, sizeof(sql_ssid));
			SQL_FetchString(hndl, 2, sql_map, sizeof(sql_map));
			SQL_FetchString(hndl, 3, sql_style, sizeof(sql_style));
			RecordTime = SQL_FetchFloat(hndl, 4);
			SQL_FetchString(hndl, 5, sql_date, sizeof(sql_date));
			sql_jumps = SQL_FetchInt(hndl, 6);
			
			if(!StrEqual(sql_style, "Half-Sideways") || !StrEqual(sql_style, "Sideways") || !StrEqual(sql_style, "W-Only"))
			{
				sql_strafes = SQL_FetchInt(hndl, 7);
				sql_sync = SQL_FetchFloat(hndl, 8);
				
				if(StrEqual(sql_style, "Freestyle") || StrEqual(sql_style, "Parkour"))
				{
					sql_prespeed = SQL_FetchFloat(hndl, 9);
					
					if(StrEqual(sql_style, "Parkour"))
					{
						sql_wallruns = SQL_FetchInt(hndl, 10);
						sql_walljumps = SQL_FetchInt(hndl, 11);
					}
				}
			}	
		}
		
		ReplaceString(sql_map, sizeof(sql_map), "_csgo", "");
		
		FormatPlayerTime(RecordTime, TimeString, 32, false, 1);
		
		ShowRecord(client, sql_ssid, sql_name, sql_map, sql_style, TimeString, sql_date, sql_jumps, sql_strafes, sql_sync, sql_prespeed, sql_wallruns, sql_walljumps);
	}	
}




//-----------------------
// Maps Table Functions |
//-----------------------

public LoadMap(const String:map[])
{
	decl String:Query[500];
	
	trans = SQL_CreateTransaction();
	
	Format(Query, 500, "SELECT map AS MapInfo, tier, stages, XP FROM maps WHERE (map='%s') LIMIT 1", map);
	SQL_AddQuery(trans, Query, 0);
	QueryCounter++;
	
	Format(Query, 500, "SELECT AVG(record) AS Average, COUNT(record), map, style FROM records WHERE (map='%s') AND (style='AUTO')", map);
	SQL_AddQuery(trans, Query, 0);
	QueryCounter++;
	
	Format(Query, sizeof(Query), "SELECT COUNT(map) AS MapCount FROM maps");
	SQL_AddQuery(trans, Query, 0);
	QueryCounter++;
	
	SQL_ExecuteTransaction(db, trans, SQL_LoadMapData, SQL_TransFailed, _, DBPrio_High);

}

public SQL_LoadMapData(Handle:owner, any:data, numQueries, Handle:results[], any:queryData[])
{
	decl String:sFieldName[64];
	
	for(new i = 0; i < numQueries; i++)
	{				
		if(SQL_FetchRow(results[i]) == false)
			continue;
		
		SQL_FieldNumToName(results[i], 0, sFieldName, sizeof(sFieldName));
		
		if(StrEqual(sFieldName, "MapInfo"))
		{
			Map[Tier] = SQL_FetchInt(results[i], 1);
			SQL_FetchString(results[i], 2, Map[Stages], 64);
			Map[XPValue] = SQL_FetchInt(results[i], 3);
		}
		else if(StrEqual(sFieldName, "Average"))
		{
			Map[Average] = SQL_FetchFloat(results[i], 0);
			Map[RecordCount] = SQL_FetchInt(results[i], 1);
			
			new roundedavg;
			
			if(Map[Average] <= 60.0)
			{
				roundedavg = 1;
			}
			else
			{
				roundedavg = (RoundToFloor(Map[Average]) / 60);
			}
			
			Map[Time] = roundedavg + (Map[Tier] * 5) + 10;
			
			if(Map[Time] <= 20)
				Map[Time] = 20;
			else if(Map[Time] <= 25)
				Map[Time] = 25;
			else if(Map[Time] <= 30)
				Map[Time] = 30;
			else if(Map[Time] <= 35)
				Map[Time] = 30;
			else if(Map[Time] <= 40)
				Map[Time] = 40;
			else if(Map[Time] <= 45)
				Map[Time] = 45;
			else if(Map[Time] <= 50)
				Map[Time] = 50;
			else if(Map[Time] <= 55)
				Map[Time] = 55;
			else if(Map[Time] <= 60 || Map[Time] > 60)
				Map[Time] = 60;


			decl String:Value[10];
			
			//Map[Time] = 5;
			
			IntToString(Map[Time], Value, 10);
		
			SetCvar("mp_roundtime", Value);
			SetCvar("mp_timelimit", Value);
			
			TimeLeft = Map[Time];
			
			CS_TerminateRound(1.0, CSRoundEnd_GameStart, true)
		}
		else if(StrEqual(sFieldName, "MapCount"))
		{
			MapCounter = SQL_FetchInt(results[i], 0);
		}
		
	}	
}

public AddMap(const String:map[], mTier, String:mStages[], mXP)
{
	decl String:Query[300];
	
	Format(Query, sizeof(Query), "INSERT INTO maps (map, tier, stages, XP) VALUES ('%s', '%i', '%s', '%i')", map, mTier, mStages, mXP);

	SQL_TQuery(db, SQL_ErrorCallback, Query);
	QueryCounter++;
	
	//LoadMap(map);
}

public DeleteMap(const String:map[])
{
	decl String:Query[300];
	
	Format(Query, sizeof(Query), "DELETE FROM maps WHERE (map='%s')", map);

	SQL_TQuery(db, SQL_ErrorCallback, Query);
	QueryCounter++;
	
	//LoadMap(map);
}






//-----------------------
// Zone Table Functions |
//-----------------------

//[ Create Zone - New Zone Created ]

public CreateZone(type, verts, Float:height, Float:A[3], Float:B[3], Float:C[3], Float:D[3], Float:E[3], Float:F[3])
{
	decl String:Query[500];

	switch(verts)
	{
		case 3:
		{
			Format(Query, sizeof(Query), "INSERT INTO zones (map, type, verts, height, A1, A2, A3, B1, B2, B3, C1, C2, C3, D1, D2, D3, E1, E2, E3, F1, F2, F3) VALUES ('%s', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '-0.0', '-0.0', '-0.0', '-0.0', '-0.0', '-0.0', '-0.0', '-0.0', '-0.0')", Map[MapName], type, verts, height, A[0], A[1], A[2], B[0], B[1], B[2], C[0], C[1], C[2]);
		}
		case 4:
		{
			Format(Query, sizeof(Query), "INSERT INTO zones (map, type, verts, height, A1, A2, A3, B1, B2, B3, C1, C2, C3, D1, D2, D3, E1, E2, E3, F1, F2, F3) VALUES ('%s', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '-0.0', '-0.0', '-0.0', '-0.0', '-0.0', '-0.0')", Map[MapName], type, verts, height, A[0], A[1], A[2], B[0], B[1], B[2], C[0], C[1], C[2], D[0], D[1], D[2]);
		}
		case 5:
		{
			Format(Query, sizeof(Query), "INSERT INTO zones (map, type, verts, height, A1, A2, A3, B1, B2, B3, C1, C2, C3, D1, D2, D3, E1, E2, E3, F1, F2, F3) VALUES ('%s', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '-0.0', '-0.0', '-0.0')", Map[MapName], type, verts, height, A[0], A[1], A[2], B[0], B[1], B[2], C[0], C[1], C[2], D[0], D[1], D[2], E[0], E[1], E[2]);
		}
		case 6:
		{
			Format(Query, sizeof(Query), "INSERT INTO zones (map, type, verts, height, A1, A2, A3, B1, B2, B3, C1, C2, C3, D1, D2, D3, E1, E2, E3, F1, F2, F3) VALUES ('%s', '%i', '%i', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%f')", Map[MapName], type, verts, height, A[0], A[1], A[2], B[0], B[1], B[2], C[0], C[1], C[2], D[0], D[1], D[2], E[0], E[1], E[2], F[0], F[1], F[2]);
		}
	}

	SQL_TQuery(db, SQL_ErrorCallback, Query);
	QueryCounter++;
}



//[ Update Zone - Update Existing Zone ]

public UpdateZone(type, verts, Float:height, Float:A[3], Float:B[3], Float:C[3], Float:D[3], Float:E[3], Float:F[3])
{
	decl String:Query[255];

	switch(verts)
	{
		case 3:
		{
			Format(Query, sizeof(Query), "UPDATE zones SET verts='%i', height='%f', A1='%f', A2='%f', A3='%f', B1='%f', B2='%f', B3='%f', C1='%f', C2='%f', C3='%f', D1='-0.0', D2='-0.0', D3='-0.0', E1='-0.0', E2='-0.0', E3='-0.0', F1='-0.0', F2='-0.0', F3='-0.0' WHERE map='%s' AND type='%i')", verts, height, A[0],A[1],A[2], B[0],B[1],B[2], C[0],C[1],C[2], Map[MapName], type);
		}
		case 4:
		{
			Format(Query, sizeof(Query), "UPDATE zones SET verts='%i', height='%f', A1='%f', A2='%f', A3='%f', B1='%f', B2='%f', B3='%f', C1='%f', C2='%f', C3='%f', D1='%f', D2='%f', D3='%f', E1='-0.0', E2='-0.0', E3='-0.0', F1='-0.0', F2='-0.0', F3='-0.0', WHERE map='%s' AND type='%i')", verts, height, A[0],A[1],A[2], B[0],B[1],B[2], C[0],C[1],C[2], D[0],D[1],D[2], Map[MapName], type);
		}
		case 5:
		{
			Format(Query, sizeof(Query), "UPDATE zones SET verts='%i', height='%f', A1='%f', A2='%f', A3='%f', B1='%f', B2='%f', B3='%f', C1='%f', C2='%f', C3='%f', D1='%f', D2='%f', D3='%f', E1='%f', E2='%f', E3='%f', F1='-0.0', F2='-0.0', F3='-0.0', WHERE map='%s' AND type='%i')", verts, height, A[0],A[1],A[2], B[0],B[1],B[2], C[0],C[1],C[2], D[0],D[1],D[2], E[0],E[1],E[2], Map[MapName], type);
		}
		case 6:
		{
			Format(Query, sizeof(Query), "UPDATE zones SET verts='%i', height='%f', A1='%f', A2='%f', A3='%f', B1='%f', B2='%f', B3='%f', C1='%f', C2='%f', C3='%f', D1='%f', D2='%f', D3='%f', E1='%f', E2='%f', E3='%f', F1='%f', F2='%f', F3='%f', WHERE map='%s' AND type='%i')", verts, height, A[0],A[1],A[2], B[0],B[1],B[2], C[0],C[1],C[2], D[0],D[1],D[2], E[0],E[1],E[2], F[0],F[1],F[2], Map[MapName], type);
		}
	}

	SQL_TQuery(db, SQL_ErrorCallback, Query);
	QueryCounter++;
}

//[ Delete Zone - Delete Existing Zone ]

public DeleteZone(type)
{
	decl String:Query[255];

	Format(Query, sizeof(Query), "DELETE FROM zones WHERE map='%s' AND type='%i'", Map[MapName], type);
	SQL_TQuery(db, SQL_ErrorCallback, Query);
	QueryCounter++;
}


//[ Load Zones - Load Zones For The Current Map ]

public LoadZones(const String:map[])
{
	decl String:Query[300];
	
	Format(Query, sizeof(Query), "SELECT * FROM zones WHERE map='%s' AND (verts > 2) ORDER BY type ASC", map);

	SQL_TQuery(db, SQL_LoadZones, Query, _, DBPrio_High);
	QueryCounter++;

}
public SQL_LoadZones(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(SQL_HasResultSet(hndl))
	{
		while(SQL_FetchRow(hndl))
		{	
			new type = SQL_FetchInt(hndl, 1);
			
			g_Zone[type][PointCount] = SQL_FetchInt(hndl, 2);
			g_Zone[type][zHeight] = SQL_FetchFloat(hndl, 3);
		
			
			for(new j = 0; j < 3; j++)
			{
				g_Zone[type][PointA][j] = SQL_FetchFloat(hndl, (j + 4));
				g_Zone[type][PointB][j] = SQL_FetchFloat(hndl, (j + 7));
				g_Zone[type][PointC][j] = SQL_FetchFloat(hndl, (j + 10));
				g_Zone[type][PointD][j] = SQL_FetchFloat(hndl, (j + 13));
				g_Zone[type][PointE][j] = SQL_FetchFloat(hndl, (j + 16));
				g_Zone[type][PointF][j] = SQL_FetchFloat(hndl, (j + 19));
			}
			
			PrintToServer("[Zones]: Zone #%i | Verts: %i | Height: %f | *LOADED*", type, g_Zone[type][PointCount], g_Zone[type][zHeight]);
			
			
			g_ZoneExists[type] = true;
		}
		

		if(hndl == INVALID_HANDLE)
		{
			SQL_GetError(db, Error, sizeof(Error));
			PrintToServer("SQL ERROR: %s", Error);
		}
		
		g_ZonesLoaded = true;
	}	
}


//----------------------
// VIP Table Functions |
//----------------------

//[ LoadVIPSettings ]

public LoadVIPSettings(client)
{
	new userid = GetClientUserId(client);
	
	decl String:steamid[64],
	String:Query[255],
	bool:DataCheck;
	
	DataCheck = false;
	
	if(GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false))
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));

			//SQL Query
			Format(Query, sizeof(Query), "SELECT model FROM vip WHERE (steamid='%s') LIMIT 1", steamid);
			SQL_TQuery(db, SQL_LoadVIPSettings, Query, userid, DBPrio_Low);
			QueryCounter++;
			
			DataCheck = true;
		}
	}
	
	if (!DataCheck)
	{
		PrintToServer("SQL ERROR: Failed to retrieve vip data for %N", client);
	}

}

public SQL_LoadVIPSettings(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", Error);
	}
	
	if (client == 0)
	{
		return;
	}

	if(SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, g_vip[client][Model], 100);
	}
}

public AddVIP(String:SID[64], Float:amount)
{
	decl String:Query[255];
	
	//SQL Query
	Format(Query, sizeof(Query), "INSERT INTO vip (steamid, amount, model) VALUES ('%s', '%f', 'models/player/pokemon_trainer/pokemon_trainer.mdl')", SID, amount);
	SQL_TQuery(db, SQL_ErrorCallback, Query);
	QueryCounter++;
}

public SaveVIPSettings(client)
{
	new userid = GetClientUserId(client);
	
	decl String:steamid[64],
	String:Query[255];

	if(GetClientAuthString(client, steamid, sizeof(steamid)))
	{
		if(IsValidClient(client, false))
		{
			//Client Steam ID
			GetClientAuthString(client, steamid, sizeof(steamid));

			//SQL Query
			Format(Query, sizeof(Query), "UPDATE vip SET model='%s' WHERE (steamid='%s')", g_vip[client][Model], steamid);
			SQL_TQuery(db, SQL_ErrorCallback, Query, userid);
			QueryCounter++;
		}
	}	
}




//-------------------------
// Default Error CallBack |
//-------------------------

public SQL_ErrorCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
		LogError("SQL ERROR: %s", error);
	}

	if (client == 0)
	{
		return;
	}
}



//-----------------------------------
// Print Results (Top 5 Per Style)  |
//-----------------------------------
public PrintResults(const String:type[])
{
	decl String:Query[255];
	
	if(StrEqual("Leaderboard", type, true))
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
		
		if(BR_Round != 5)
		{
			PrintToChatAll("    ");
			PrintToChatAll(" \x01\x05★___★__ Battle Royale Leaderboard __★___★");
			PrintToChatAll(" \x01\x061. %N | \x01\x0B\x03%i Points", rank1, RoundToFloor(g_info[rank1][BRPoints]));
			PrintToChatAll(" \x01\x062. %N | \x01\x0B\x03%i Points", rank2, RoundToFloor(g_info[rank2][BRPoints]));
			PrintToChatAll(" \x01\x063. %N | \x01\x0B\x03%i Points", rank3, RoundToFloor(g_info[rank3][BRPoints]));
			PrintToChatAll(" \x01\x064. %N | \x01\x0B\x03%i Points", rank4, RoundToFloor(g_info[rank4][BRPoints]));
			PrintToChatAll(" \x01\x065. %N | \x01\x0B\x03%i Points", rank5, RoundToFloor(g_info[rank5][BRPoints]));
			
			PrintToChatAll(" \x01\x03[EVE]: \x01\x06Next Round Will Begin In 10 seconds..");
		}
		
		switch(BR_Round)
		{
			case 1:{ SetNextMap(BR_MapT2);}
			case 2:{ SetNextMap(BR_MapT3);}
			case 3:{ SetNextMap(BR_MapT4);}
			case 4:{ SetNextMap(BR_MapT5);}
			case 5:{ SetNextMap("paradise_lobby");}
		}
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i, true))
			{
				CS_RespawnPlayer(i);
				
				SetClientOverlay(i, "effects/hsv.vmt");
				
				SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
			}
		}
		
		if(BR_Round == 5)
		{
			CreateTimer(1.0, End_Round, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			CreateTimer(10.0, Next_Round, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		Format(Query, sizeof(Query), "SELECT name, record, style, steamid FROM records WHERE (map='%s') AND (style='%s') AND (record > 0) ORDER BY record ASC LIMIT 5", Map[MapName], type);
		
		SQL_TQuery(db, SQL_PrintResults, Query);
		QueryCounter++;
	}
}

public SQL_PrintResults(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	decl String:sql_name[64], String:sql_time[64], String:sql_style[64], String:sql_steamid[64], String:player_steamid[64];
	new Float:recordtime;
	
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		new Float:PointsCount = 0.0;
		while(SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, sql_name, 64);
			recordtime = SQL_FetchFloat(hndl, 1);
			SQL_FetchString(hndl, 2, sql_style, 64);
			SQL_FetchString(hndl, 3, sql_steamid, 64);

			FormatPlayerTime(recordtime, sql_time, 64, false, 0);
			
			if(i == 1)
			{
				PrintToChatAll("    ");
				PrintToChatAll("  \x01\x05 ||\x01\x0B - \x01\x05|\x01\x0B★\x01\x05|\x01\x0B - \x01\x05|| %s ||\x01\x0B - \x01\x05|\x01\x0B★\x01\x05|\x01\x0B - \x01\x05||", sql_style);
			}
			
			if(StrEqual(sql_style, "Parkour", true))
			{
				switch(i)
				{
				
					case 1:{PointsCount = 2.5;}
					case 2:{PointsCount = 2.0;}
					case 3:{PointsCount = 1.5;}
					case 4:{PointsCount = 1.0;}
					case 5:{PointsCount = 0.5;}
				}
			}
			else
			{
				switch(i)
				{
					case 1:{PointsCount = 5.0;}
					case 2:{PointsCount = 4.0;}
					case 3:{PointsCount = 3.0;}
					case 4:{PointsCount = 2.0;}
					case 5:{PointsCount = 1.0;}
				}
			}
			
			PrintToChatAll(" \x01\x06#%i | \x01%s \x01\x06- \x01\x07%ss  \x01\x0B\x03(+%i Points)", i, sql_name, sql_time, RoundToFloor(PointsCount));
			
			for(new j = 0; j <= 28; j++)
			{
				if(StrEqual(sql_steamid, AuthPlayer[j][AuthSID]))
				{
					AuthPlayer[j][BRScore] = AuthPlayer[j][BRScore] + PointsCount;
				}
			}
			
			for(new j = 1; j <= MaxClients; j++)
			{
				if(IsValidClient(j) && !IsFakeClient(j))
				{
					GetClientAuthString(j, player_steamid, 64);
					
					if(StrEqual(sql_steamid, player_steamid))
					{
						g_info[j][BRPoints] = g_info[j][BRPoints] + PointsCount;
						
						CS_SetClientContributionScore(j, RoundToFloor(g_info[j][BRPoints]));
						
					}
				}
			}
			
			i++;
		}
		
		if(i == 1)
		{
			//PrintToChatAll(" \x01\x06[Paradise] No Records Exist Set On This Style!");
		}
		else
		{
		
		}
	}	
}



//---------------------------
// Top Map Records by Style |
//---------------------------

public MapTopRecords(client, const String:selected_map[], const String:type[])
{
	new userid = GetClientUserId(client);
	decl String:Query[255];
	
	Format(Query, sizeof(Query), "SELECT name, record, map, style, steamid FROM records WHERE (map='%s') AND (style='%s') AND (record > 0) ORDER BY record ASC LIMIT 100", selected_map, type);
	
	SQL_TQuery(db, SQL_MapTopRecords, Query, userid);
	QueryCounter++;
}

public SQL_MapTopRecords(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sql_name[64], String:sql_time[64], String:sql_rank[16], String:sql_item[128], String:sql_map[128], String:sql_ssid[64], String:sql_RVS[128], String:sql_style[64];
	new Float:recordtime;

	new Handle:menu = CreateMenu(MapTopHandler);
	
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while(SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, sql_name, 64);
			recordtime = SQL_FetchFloat(hndl, 1);
			
			SQL_FetchString(hndl, 2, sql_map, 128);
			SQL_FetchString(hndl, 3, sql_style, 64);
			SQL_FetchString(hndl, 4, sql_ssid, 64);
			
			Format(sql_item, 128, "[%s] Records - %s", sql_style, sql_map);
			SetMenuTitle(menu, sql_item);
			
			Format(sql_RVS, 128, "%s=%s=%s", sql_map, sql_style, sql_ssid);
			
			FormatPlayerTime(recordtime, sql_time, 64, false, 0);
			
			if (i == 100)
				Format(sql_rank, 16, "#%i", i);
			else if (i < 10)
				Format(sql_rank, 16, "#%i", i);
			else
				Format(sql_rank, 16, "#%i", i);
			
			Format(sql_item, 128, "%s %s | %ss", sql_rank, sql_name, sql_time);
			
			AddMenuItem(menu, sql_RVS, sql_item, ITEMDRAW_DEFAULT);
			
			i++;
		}
		
		if(i == 1)
		{
			PrintToChat(client, " \x01\x06[Paradise] No Records Exist For This Map!");
		}
		else
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT|MENUFLAG_BUTTON_EXITBACK);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
			
			Format(LastMenu[client], 64, "MapTop_%s", sql_style);
		}
	}	
}

public MapTopHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[128];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		decl String:bits[3][64];
		
		ExplodeString(info, "=", bits, 3, 64, true);
		
		Format(g_curSSID[param1], 64, "%s", bits[2]);
		
		ViewRecord(param1, bits[2], bits[0], bits[1]);
	}
	else if (action == MenuAction_Cancel && param2== MenuCancel_ExitBack)
	{
		decl String:sMap[128];
		
		GetMenuTitle(menu, sMap, sizeof(sMap));
		
		if(StrContains(sMap, "Auto", false) > -1)
		{
			ReplaceString(sMap, sizeof(sMap), "[Auto] Records - ", "", false);
		}
		else if(StrContains(sMap, "Legit", false) > -1)
		{
			ReplaceString(sMap, sizeof(sMap), "[Legit] Records - ", "", false);
		}
		else if(StrContains(sMap, "Freestyle", false) > -1)
		{
			ReplaceString(sMap, sizeof(sMap), "[Freestyle] Records - ", "", false);
		}
		else if(StrContains(sMap, "Parkour", false) > -1)
		{
			ReplaceString(sMap, sizeof(sMap), "[Parkour] Records - ", "", false);
		}
		else if(StrContains(sMap, "Half-Sideways", false) > -1)
		{
			ReplaceString(sMap, sizeof(sMap), "[Half-Sideways] Records - ", "", false);
		}
		else if(StrContains(sMap, "Sideways", false) > -1)
		{
			ReplaceString(sMap, sizeof(sMap), "[Sideways] Records - ", "", false);
		}
		else if(StrContains(sMap, "W-Only-", false) > -1)
		{
			ReplaceString(sMap, sizeof(sMap), "[W-Only] Records - ", "", false);
		}
		
		MapTop_Main(param1, sMap);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


//-----------------------
// Top Players by Style |
//-----------------------

public TopPlayers(client, const String:type[])
{
	new userid = GetClientUserId(client);
	decl String:Query[500];
	
	Format(Query, sizeof(Query), "SELECT COUNT(*) AS count, f.name, f.style, f.steamid FROM (SELECT steamid, style, map, min(record) as minrecord FROM records GROUP BY map, style) as x INNER JOIN records AS f ON f.map = x.map AND f.style = '%s' AND f.record = x.minrecord GROUP BY f.steamid HAVING COUNT(*) > 0 ORDER BY `count` DESC", type);
	
	SQL_TQuery(db, SQL_TopPlayers, Query, userid);
	QueryCounter++;
}

public SQL_TopPlayers(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
		LogError(error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sql_name[64], sql_wrs, String:sql_style[64], String:sql_item[128], String:sql_ssid[64], String:sql_rank[16];
	new Handle:menu = CreateMenu(TopPlayersHandler);
	
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while(SQL_FetchRow(hndl))
		{
			sql_wrs = SQL_FetchInt(hndl, 0);
			SQL_FetchString(hndl, 1, sql_name, 64);
			SQL_FetchString(hndl, 2, sql_style, 128);
			SQL_FetchString(hndl, 3, sql_ssid, 64);
			
			Format(sql_item, 128, "Paradise | [%s] Players", sql_style);
			SetMenuTitle(menu, sql_item);
			
			if (i == 100)
				Format(sql_rank, 16, "#%i", i);
			else if (i < 10)
				Format(sql_rank, 16, "#%i", i);
			else
				Format(sql_rank, 16, "#%i", i);
			
			Format(sql_item, 128, "%s  %s | %i WRs", sql_rank, sql_name, sql_wrs);
			
			AddMenuItem(menu, sql_ssid, sql_item, ITEMDRAW_DEFAULT);
			
			i++;
		}
		
		if(i == 1)
		{
			PrintToChat(client, " \x01\x06[Paradise] No Players On This Style!");
		}
		else
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT|MENUFLAG_BUTTON_EXITBACK);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
	}	
}

public TopPlayersHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[128];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		LoadProfile(param1, info);
	}
	else if (action == MenuAction_Cancel && param2== MenuCancel_ExitBack)
	{	
		TopPlayers_Main(param1);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


//-----------------------------
// Current World Records List |
//-----------------------------

public WorldRecordList(client, const String:SSID[])
{
	new userid = GetClientUserId(client);
	decl String:Query[500];
	
	Format(Query, sizeof(Query), "SELECT f.name, f.steamid, f.style, f.map, f.record FROM (SELECT style, map, min(record) as minrecord FROM records GROUP BY map, style) as x INNER JOIN records AS f ON f.map = x.map AND f.style = x.style AND f.record = x.minrecord AND f.steamid = '%s' ORDER BY f.style ASC", SSID);
	
	SQL_TQuery(db, SQL_WorldRecordList, Query, userid);
	QueryCounter++;
}

public SQL_WorldRecordList(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sql_map[128], String:sql_string[128], String:sql_style[64], String:sql_name[MAX_NAME_LENGTH], String:sql_ssid[64], String:sql_iteminfo[255];
	decl Float:RecordTime, String:TimeString[32];

	new Handle:menu = CreateMenu(WorldRecordListHandler);
	
	if(SQL_HasResultSet(hndl))
	{		
		while(SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, sql_name, MAX_NAME_LENGTH);
			
			SQL_FetchString(hndl, 1, sql_ssid, 64);
			
			SetMenuTitle(menu, "♫ %s - World Records ♫", sql_name);
			
			SQL_FetchString(hndl, 2, sql_style, 64);
			
			SQL_FetchString(hndl, 3, sql_map, 128);
			
			RecordTime = SQL_FetchFloat(hndl, 4);
			FormatPlayerTime(RecordTime, TimeString, 32, false, 0);
			
			Format(sql_iteminfo, 128, "%s=%s", sql_map, sql_style);
			
			ReplaceString(sql_map, sizeof(sql_map), "_csgo", "");
			
			Format(sql_string, 128, "[%s] %s | %ss", sql_style, sql_map, TimeString);
			
			AddMenuItem(menu, sql_iteminfo, sql_string, ITEMDRAW_DEFAULT);
		}
		
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT|MENUFLAG_BUTTON_EXITBACK);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		
		Format(LastMenu[client], 64, "PlayerWorldRecords");
	}	
}

public WorldRecordListHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:display[32], style, String:info[64]
		GetMenuItem(menu, param2, info, sizeof(info), style, display, sizeof(display));
		
		decl String:bits[2][64];
		
		ExplodeString(info, "=", bits, 2, 64, false);
		
		ViewRecord(param1, g_curSSID[param1], bits[0], bits[1]);
		
	}
	else if (action == MenuAction_Cancel && param2== MenuCancel_ExitBack)
	{
		LoadProfile(param1, g_curSSID[param1]);
		Format(LastMenu[param1], 64, "");
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


//----------------------
// Map Completion Menu |
//----------------------

public MapCompletionList(client, const String:SSID[], CompType)
{
	new userid = GetClientUserId(client);
	decl String:Query[255];
	
	if(CompType == 1)
	{
		Format(Query, sizeof(Query), "SELECT map AS Complete, tier FROM `maps` WHERE maps.map IN(SELECT map from records WHERE steamid = '%s') ORDER BY tier ASC", SSID);
	}
	else if (CompType == 2)
	{
		Format(Query, sizeof(Query), "SELECT map AS Incomplete, tier FROM `maps` WHERE maps.map NOT IN(SELECT map from records WHERE steamid = '%s') ORDER BY tier ASC", SSID);
	}
	
	SQL_TQuery(db, SQL_MapCompletion, Query, userid);
	QueryCounter++;
}

public SQL_MapCompletion(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sFieldName[64];
	decl String:sql_map[128], String:sql_string[128], sql_tier, sql_count;

	new Handle:menu = CreateMenu(MapCompletionHandler);
	
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		
		while(SQL_FetchRow(hndl))
		{
			if(i == 1)
			{
				SQL_FieldNumToName(hndl, 0, sFieldName, sizeof(sFieldName));
				
				sql_count = SQL_GetRowCount(hndl);
				
				if(StrEqual(sFieldName, "Incomplete"))
				{
					Format(sql_string, 128, "- Map Progress | %i Incomplete Maps", sql_count);
				}
				else if(StrEqual(sFieldName, "Complete"))
				{
					Format(sql_string, 128, "+ Map Progress | %i/%i Maps Finished", sql_count, MapCounter);
				}
				
				SetMenuTitle(menu, sql_string);
			}
			
			SQL_FetchString(hndl, 0, sql_map, 128);
			
			sql_tier = SQL_FetchInt(hndl, 1);
			
			ReplaceString(sql_map, sizeof(sql_map), "_csgo", "");
			
			Format(sql_string, 128, "[Tier %i] %s", sql_tier, sql_map);
			
			AddMenuItem(menu, sql_map, sql_string, ITEMDRAW_DEFAULT);
			
			i++;
		}
		
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT|MENUFLAG_BUTTON_EXITBACK);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}	
}

public MapCompletionHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:display[32], style, String:info[64]
		GetMenuItem(menu, param2, info, sizeof(info), style, display, sizeof(display));
	}
	else if (action == MenuAction_Cancel && param2== MenuCancel_ExitBack)
	{
		MapCompMenu(param1, g_curSSID[param1]);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


//----------------------
// Recent Records Menu |
//----------------------

public RecentRecords(client, const String:SSID[])
{
	new userid = GetClientUserId(client);
	decl String:Query[255];
	
	Format(Query, sizeof(Query), "SELECT name, style, record, map, date, steamid FROM records WHERE steamid = '%s' ORDER BY date DESC LIMIT 12", SSID);
	
	SQL_TQuery(db, SQL_RecentRecords, Query, userid);
	QueryCounter++;
}

public SQL_RecentRecords(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sql_ssid[64], String:sql_name[64], String:sql_time[64], String:sql_style[32], String:sql_map[128], String:sql_date[64], String:sql_string[128], String:sql_RVS[128];
	new Float:recordtime;

	new Handle:menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Radio), RecentRecordsHandler);
	
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while(SQL_FetchRow(hndl))
		{
			if(i == 1)
			{
				SQL_FetchString(hndl, 0, sql_name, 64);
				SQL_FetchString(hndl, 5, sql_ssid, 64);
				Format(sql_string, 128, "►►  %s - Recent Records  ◄◄", sql_name);
				SetMenuTitle(menu, sql_string);
			}
			
			SQL_FetchString(hndl, 1, sql_style, 64);
			
			recordtime = SQL_FetchFloat(hndl, 2);
			FormatPlayerTime(recordtime, sql_time, 64, false, 0);
			
			SQL_FetchString(hndl, 3, sql_map, 128);
			
			Format(sql_RVS, 128, "%s-%s", sql_map, sql_style);
			
			ReplaceString(sql_map, sizeof(sql_map), "_csgo", "");
			
			SQL_FetchString(hndl, 4, sql_date, 64);
			
			Format(sql_string, 128, "[%s] %ss | %s ", sql_style, sql_time, sql_map, sql_date);
			
			AddMenuItem(menu, sql_RVS, sql_string, ITEMDRAW_DEFAULT);
			
			i++;
		}
		
		SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT|MENUFLAG_BUTTON_EXITBACK);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		Format(LastMenu[client], 64, "RecentRecords");
	}	
}

public RecentRecordsHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:display[32], style, String:info[64]
		GetMenuItem(menu, param2, info, sizeof(info), style, display, sizeof(display));
		
		decl String:bits[2][64];
		
		ExplodeString(info, "-", bits, 2, 64, false);
		
		ViewRecord(param1, g_curSSID[param1], bits[0], bits[1]);
	}
	else if (action == MenuAction_Cancel && param2== MenuCancel_ExitBack)
	{
		LoadProfile(param1, g_curSSID[param1]);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


//-----------------------
// Paradise Leaderboard |
//-----------------------

public mLeaderboard_Main(client)
{
	new userid = GetClientUserId(client);
	decl String:Query[255];
	
	Format(Query, sizeof(Query), "SELECT name, level, score, steamid FROM players WHERE (level > 0)  AND (score > 0) ORDER BY score DESC, level DESC LIMIT 100");
	
	SQL_TQuery(db, SQL_Leaderboard, Query, userid);
	QueryCounter++;
}

public SQL_Leaderboard(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = GetClientOfUserId(data);

	if(hndl == INVALID_HANDLE)
	{
		PrintToServer("SQL ERROR: %s", error);
	}
	
	if (client == 0)
	{
		return;
	}
	
	decl String:sql_name[64], String:sql_rank[16], String:sql_item[128], String:sql_sid[64], String:ScoreString[64];
	new sql_score;

	new Handle:menu = CreateMenu(LeaderboardHandler);
	SetMenuTitle(menu, "≡  | Paradise Leaderboard |  ≡");
	
	if(SQL_HasResultSet(hndl))
	{
		new i = 1;
		while(SQL_FetchRow(hndl))
		{
			SQL_FetchString(hndl, 0, sql_name, 64);
			sql_score = SQL_FetchInt(hndl, 2);
			SQL_FetchString(hndl, 3, sql_sid, 64);
			
			if (i == 100)
				Format(sql_rank, 16, "#%i ", i);
			else if (i < 10)
				Format(sql_rank, 16, "#%i ", i);
			else
				Format(sql_rank, 16, "#%i ", i);
			
			FormatNumberInt(sql_score, ScoreString, 64);
			
			new len = strlen(sql_name);
					
			if(len > 10)
			{
				sql_name[9] = '\0';

				Format(sql_name, sizeof(sql_name), "%s..", sql_name);
			}
			
			Format(sql_item, 128, "%s %s | %s", sql_rank, sql_name, ScoreString);
			
			AddMenuItem(menu, sql_sid, sql_item, ITEMDRAW_DEFAULT);
			
			i++;
		}
		
		if(i == 1)
		{
			PrintToChat(client, " \x01\x06[Paradise] No Players In Database!");
		}
		else
		{
			SetMenuOptionFlags(menu, MENUFLAG_BUTTON_EXIT);
			DisplayMenu(menu, client, MENU_TIME_FOREVER);
		}
	}	
}

public LeaderboardHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action ==  MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		LoadProfile(param1, info);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

//-----------------------------------
//Global Transaction Error Callback |
//-----------------------------------

public SQL_TransFailed(Handle:owner, any:data, numQueries, const String:error[], failIndex, any:queryData[])
{	
	LogError(error[failIndex]);
	
	PrintToServer("SQL ERROR: %s", error[failIndex]);
}







