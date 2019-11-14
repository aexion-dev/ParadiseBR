#include <sourcemod>
#include <emitsoundany>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <devzones>
#include <setname>
#include <entity>
#include <paradise-stocks>

enum Trail
{
	String:TrailName[MAX_NAME_LENGTH],
	String:TrailMaterial[128],
	Float:TrailLifetime,
	Float:TrailWidth,
	Float:TrailEndWidth,
	TrailFadeLength,
}

new g_trails[14][Trail];
new Handle:g_trailTimers[MAXPLAYERS+1];
new g_trailChoice[MAXPLAYERS+1];
new Handle:kv;

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | CONTENT",
    author = "Aexi0n",
    description = "Official Bhop Plugin for Paradise Servers",
    version = "3.5",
    url = ""
}


public OnPluginStart()
{	
	LoadTranslations("common.phrases");
	
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_team", PlayerTeam);
	HookEvent("round_end", RoundEnd);

	RegAdminCmd("sm_trail", SelectTrail, ADMFLAG_ROOT, "sm_trail <trail_name>");
	RegConsoleCmd("sm_trails", sm_trails); // Select Your Trail

}

//Add Trail Materials To Downloads & Precache 

public OnMapStart()
{	
	for (new client = 1; client <= MaxClients; client++)
	{
		g_trailChoice[client] = -1;
	}
	
	LoadTrails();
	
	for (new item = 1; item < 12; item++)
	{
		decl String:_sBuffer[PLATFORM_MAX_PATH];
		strcopy(_sBuffer, sizeof(_sBuffer), g_trails[item][TrailMaterial]);

		g_trails[item][TrailMaterial] = PrecacheModel(_sBuffer);
		AddFileToDownloadsTable(_sBuffer);

		ReplaceString(_sBuffer, sizeof(_sBuffer), ".vmt", ".vtf", false);
		AddFileToDownloadsTable(_sBuffer);
		PrecacheModel(_sBuffer);
	}
	
	CloseHandle(kv);
}

//Load Trails From Config File (trails.ini)

public LoadTrails()
{
	new String:file[256];
	
	kv = CreateKeyValues("Trails");
	BuildPath(Path_SM, file, 255, "configs/paradise_trails/trails.ini");
	FileToKeyValues(kv, file);

	if (!KvGotoFirstSubKey(kv))
	{
		return;
	}

	for(new i = 0; i < 12; i++)
	{	
		decl String:index[10];
		
		IntToString(i, index, 10);
		
		KvRewind(kv);
		
		KvJumpToKey(kv, index);
		KvGotoFirstSubKey(kv);
		
		KvGetString(kv, "name", g_trails[i][TrailName], MAX_NAME_LENGTH,"");
		
		KvGetString(kv, "material", g_trails[i][TrailMaterial], 128,"");
		
		g_trails[i][TrailLifetime] = 1.0;
		g_trails[i][TrailWidth] = 10.0;
		g_trails[i][TrailEndWidth] = 5.0;
		g_trails[i][TrailFadeLength] = 1;
		
		KvRewind(kv);
	}
	
}

public Action:sm_trails(client, args)
{
	if(CheckCommandAccess(client, "sm_trails", ADMFLAG_CUSTOM2, true))
	{

		new Handle:menu = CreateMenu(TrailMenu, MenuAction_Start|MenuAction_Select|MenuAction_Cancel|MenuAction_End);
		SetMenuTitle(menu, "Paradise VIP Trails");
		AddMenuItem(menu, "1", "Rainbow");
		AddMenuItem(menu, "2", "Batman");
		AddMenuItem(menu, "3", "Pokeball");
		AddMenuItem(menu, "4", "Awesome");
		AddMenuItem(menu, "5", "Lightning");
		AddMenuItem(menu, "6", "Aura");
		AddMenuItem(menu, "7", "Nyan");
		AddMenuItem(menu, "8", "LOL");
		AddMenuItem(menu, "9", "Mudkip");
		AddMenuItem(menu, "10", "Playboy");
		AddMenuItem(menu, "11", "8-bit Mushroom");
		SetMenuExitBackButton(menu, true);
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

public TrailMenu(Handle:menu, MenuAction:action, param1, param2)
{

	if (action == MenuAction_Select)
	{
		new team = GetClientTeam(param1);
		
		if(1 < team < 4)
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			
			new itemnum = StringToInt(info);
			
			if (itemnum > 0)
			{
				g_trailChoice[param1] = itemnum;
				KillTrail(param1);
				
				PrintToChat(param1, " \x01\x06[Paradise]\x01 Your Trail Has Been Updated!");
				CreateTimer(1.0, Equip, GetClientSerial(param1));
			}
		}
		else
		{
			PrintToChat(param1, "You must be alive to equip a trail!");
		}

	}
	else if(action == MenuAction_Cancel)
	{
		switch (param2)
		{
			case MenuCancel_ExitBack:
			{
				ClientCommand(param1, "sm_vip");
				return;
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

//Find Player's Selected Trail

public Action:SelectTrail(client, args)
{
	decl String:name[64];
	
	GetCmdArg(1, name, sizeof(name));
	
	g_trailChoice[client] = -1;
	
	for(new i = 0; i < 12; i++)
	{
		if (StrEqual(g_trails[i][TrailName], name, false))
		{
			g_trailChoice[client] = i;
			PrintToChat(client, "You have selected the '%s' trail.", g_trails[i][TrailName]);
		}
	}
	if(g_trailChoice[client] != -1)
	{
		ReplyToCommand(client, "You have set your trail to '%s'!", name);
		CreateTimer(1.0, Equip, GetClientSerial(client));
	}
	else
	{
		ReplyToCommand(client, "Could not find trail '%s' in the materials folder!", name);
	}
}

//Give Player Trail When They Spawn

public Action:PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && IsPlayerAlive(client)) 
	{
		if(CheckCommandAccess(client, "sm_trail", ADMFLAG_CUSTOM3, true) && g_trailChoice[client] != -1)
		{
			if (g_trailTimers[client] != INVALID_HANDLE)
			{
				CloseHandle(g_trailTimers[client]);
				g_trailTimers[client] = INVALID_HANDLE;
			}
		
			CreateTimer(1.0, Equip, GetClientSerial(client));
		}
	}
}

//Equip Player's Selected Trail Choice

public Action:Equip(Handle:timer, any:serial)
{	
	new client = GetClientFromSerial(serial);

	KillTrail(client);

	new trail = -1;
	trail = g_trailChoice[client];

	EquipTrailTempEnts(client, trail);

	new Handle:pack;
	g_trailTimers[client] = CreateDataTimer(0.1, Timer_RenderBeam, pack, TIMER_REPEAT);

	WritePackCell(pack, GetClientSerial(client));
	WritePackCell(pack, trail);

	return Plugin_Continue;
}

//Create Trail Entity Attached To Player

public EquipTrailTempEnts(client, trail)
{
	new entityToFollow = GetPlayerWeaponSlot(client, 2);
	if (entityToFollow == -1)
	{
		entityToFollow = client;
	}
	
	TE_SetupBeamFollow(entityToFollow, g_trails[trail][TrailMaterial], 0, g_trails[trail][TrailLifetime], g_trails[trail][TrailWidth], g_trails[trail][TrailEndWidth], g_trails[trail][TrailFadeLength], {255,255,255,255});
	TE_SendToAll();
}

//Continue Trail When Player Moves

public Action:Timer_RenderBeam(Handle:timer, Handle:pack)
{
	ResetPack(pack);

	new client = GetClientFromSerial(ReadPackCell(pack));

	if (client == 0)
		return Plugin_Stop;

	decl Float:velocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);		

	new bool:isMoving = !(velocity[0] == 0.0 && velocity[1] == 0.0 && velocity[2] == 0.0);
	if (isMoving)
		return Plugin_Continue;

	EquipTrailTempEnts(client, ReadPackCell(pack));
	return Plugin_Continue;
}

//Remove Player's Trail

KillTrail(client)
{
	if (g_trailTimers[client] != INVALID_HANDLE)
	{
		CloseHandle(g_trailTimers[client]);
		g_trailTimers[client] = INVALID_HANDLE;
	}
}



//Remove Trail: OnDeath, OnTeamChangeSpec, OnDisconnect, OnRoundEnd and OnMapEnd

public Action:PlayerDeath(Handle:event,const String:name[],bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	KillTrail(client);
}

public PlayerTeam(Handle:Spawn_Event, const String:Death_Name[], bool:Death_Broadcast )
{
	new client = GetClientOfUserId(GetEventInt(Spawn_Event,"userid") );
	new team = GetEventInt(Spawn_Event, "team");
	
	if (team == 1)
	{
		KillTrail(client);
	}
}

public OnClientDisconnect(client)
{
	if (g_trailTimers[client] != INVALID_HANDLE)
	{
		CloseHandle(g_trailTimers[client]);
		g_trailTimers[client] = INVALID_HANDLE;
	}
}

public Action:RoundEnd(Handle:event,const String:name[],bool:dontBroadcast)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (g_trailTimers[client] != INVALID_HANDLE)
		{
			CloseHandle(g_trailTimers[client]);
			g_trailTimers[client] = INVALID_HANDLE;
		}
	}
}

public OnMapEnd()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (g_trailTimers[client] != INVALID_HANDLE)
		{
			CloseHandle(g_trailTimers[client]);
			g_trailTimers[client] = INVALID_HANDLE;
		}
	}
}
