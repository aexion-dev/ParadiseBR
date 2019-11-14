#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

public Plugin:myinfo =
{
	name = "Fireworks Celebration",
	author = "Aexi0n",
	description = "",
	version = "1.0",
	url = ""
};

new bool:EventOn;
new Float:g_fOrigin[3], Float:g_fDir[3];

new const String:FULL_SOUND_PATH[] = "sound/sourcemod/firework";
new const String:RELATIVE_SOUND_PATH[] = "*/sourcemod/firework";


public OnPluginStart()
{
	RegAdminCmd("sm_firework", sm_firework, ADMFLAG_GENERIC, "Celebrate Current Event!");
	RegAdminCmd("sm_celebrate", sm_celebrate, ADMFLAG_ROOT, "CELEBRATE");
	RegAdminCmd("sm_stopevent", sm_stopevent, ADMFLAG_ROOT, "Stop Event");
}

public OnMapStart()
{
	EventOn = false;
	
	for (new i = 1; i <= 4; i++)
	{
		decl String:DownloadSong[128], String:PrecacheSong[128];
		
		Format(DownloadSong, 128, "sound/sourcemod/firework_%d.mp3", i);
		Format(PrecacheSong, 128, "*/sourcemod/firework_%d.mp3", i);
		
		AddFileToDownloadsTable(DownloadSong);
		FakePrecacheSound(PrecacheSong);
	}
}

stock FakePrecacheSound( const String:szPath[] )
{
	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
}

public Action:sm_firework(client, args)
{	
	CreateTimer(4.0, Celebration_Timer, GetClientSerial(client), TIMER_REPEAT);

	return Plugin_Handled;
}

public Action:sm_stopevent(client, args)
{	
	EventOn = false;

	return Plugin_Handled;
}

public Action:sm_celebrate(client, args)
{	
	EventOn = true;
	
	ServerCommand("sm_mute", "@All");
	ServerCommand("sm_scall", "Katy Perry - Firework");
	
	PrintToChatAll(" \n\n\n");
	PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
	PrintToChatAll(" \n\n\n");
	PrintToChatAll(" \x07★\x01★\x01\x0B★ \x01HAPPY 4TH OF JULY! \x01\x0BITS TIME TO CELEBRATE! \x07★\x01★\x01\x0B★");
	
	CreateTimer(15.0, MessageCeleb_Timer, _, TIMER_REPEAT);
	
	return Plugin_Handled;
}


public Action:MessageCeleb_Timer(Handle:timer, any:serial)
{
	if(EventOn)
	{
		PrintToChatAll(" \n\n\n");
		PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \x0B| * * * * * * * * *  \x01OOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \x0B|* * * * * * * * * * \x07OOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \x01|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \x01\x07|OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|");
		PrintToChatAll(" \n\n\n");
		PrintToChatAll(" \x07★\x01★\x01\x0B★ \x01HAPPY 4TH OF JULY! \x01\x0BITS TIME TO CELEBRATE! \x07★\x01★\x01\x0B★");
		
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Handled;
	}
}

public Action:Celebration_Timer(Handle:timer, any:serial)
{
	if(EventOn)
	{
		new randomint = GetRandomInt(1, 4);
		
		decl String:FireworkSND[128];
		Format(FireworkSND, 128, "%s_%i.mp3", RELATIVE_SOUND_PATH, randomint);

		new client = GetClientFromSerial(serial);
		
		GetClientAbsOrigin(client, g_fOrigin);
		
		new Float:FireworkHeight;
		FireworkHeight = GetRandomFloat(400.0, 500.0);
		g_fOrigin[2] = (g_fOrigin[2] + FireworkHeight);
		
		new FireworkType = GetRandomInt(1, 3);
		
		if(FireworkType == 1)
		{
			EmitSoundToAll(FireworkSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);  
			TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
			TE_SendToAll();
		}
		else if(FireworkType == 2)
		{
			decl Float:g_fAir[3];
			
			EmitSoundToAll(FireworkSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
			TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
			TE_SendToAll();
			
			AddVectors(g_fOrigin, g_fAir, g_fAir);
			g_fAir[2] = (g_fAir[2] - 50.0);
			g_fAir[1] = (g_fAir[1] + 100.0);
			
			TE_SetupSparks(g_fAir, g_fDir, 1000, 1000);
			TE_SendToAll();
		}
		else if(FireworkType == 3)
		{
			decl Float:g_fAir[3];
			
			EmitSoundToAll(FireworkSND, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _);
			TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
			TE_SendToAll();
			
			AddVectors(g_fOrigin, g_fAir, g_fAir);
			g_fAir[2] = (g_fAir[2] - 50.0);
			g_fAir[1] = (g_fAir[1] + 100.0);
			
			TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
			TE_SendToAll();

			g_fAir[2] = (g_fAir[2] + 25.0);
			g_fAir[0] = (g_fAir[0] + 100.0);
			
			TE_SetupSparks(g_fOrigin, g_fDir, 1000, 1000);
			TE_SendToAll();
		}
		
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Handled;
	}
}