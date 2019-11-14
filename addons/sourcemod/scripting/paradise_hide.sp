#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <cstrike>

new bool:g_bHooked;
new bool:g_bHide[MAXPLAYERS+1] = {false, ...};
new g_iWeaponOwner[2048];


public Plugin:myinfo =
{
	name        = "Hide Command for Paradise Bhop",
	author      = "Aexi0n",
	description = "Hide/Show Players",
	version     = "1.0",
	url         = ""
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("Timer_SetClientHide", Native_SetClientHide);
	CreateNative("Timer_GetClientHide", Native_GetClientHide);

	return APLRes_Success;
}

public OnPluginStart()
{
	RegAdminCmd("sm_hide", Command_Hide, ADMFLAG_ROOT);
	RegConsoleCmd("sm_l5rwQnYf", Command_l5rwQnYf);
}


public OnClientPutInServer(client)
{
	g_bHide[client] = true;
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKHook(client, SDKHook_WeaponEquip, Hook_WeaponEquip);
	SDKHook(client, SDKHook_WeaponDrop, Hook_WeaponDrop);
	CheckHooks();
}

public OnClientDisconnect_Post(client)
{
	g_bHide[client] = true;
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKUnhook(client, SDKHook_WeaponEquip, Hook_WeaponEquip);
	SDKUnhook(client, SDKHook_WeaponDrop, Hook_WeaponDrop);
	CheckHooks();
}

public OnEntityCreated(entity, const String:classname[])
{
	if (entity > MaxClients && entity < 2048)
	{
		g_iWeaponOwner[entity] = 0;
	}
}

public OnEntityDestroyed(entity)
{
	if (entity > MaxClients && entity < 2048)
	{
		g_iWeaponOwner[entity] = 0;
	}
}

public Hook_WeaponEquip(client, weapon)
{
	if (weapon > MaxClients && weapon < 2048)
	{
		g_iWeaponOwner[weapon] = client;
		SDKHook(weapon, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
	}
}

public Hook_WeaponDrop(client, weapon)
{
	if (weapon > MaxClients && weapon < 2048)
	{
		g_iWeaponOwner[weapon] = 0;
		SDKUnhook(weapon, SDKHook_SetTransmit, Hook_SetTransmitWeapon);
	}
}

public Action:Command_Hide(client, args)
{
	if(g_bHide[client])
	{
		g_bHide[client] = false;
	}
	else
	{
		g_bHide[client] = true;
	}
	
	CheckHooks();
	
	return Plugin_Handled;
}

public Action:Command_l5rwQnYf(client, args)
{
	g_bHide[client] = false;
	CheckHooks();
	
	return Plugin_Handled;
}

CheckHooks()
{
	new bool:bShouldHook = false;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_bHide[i])
		{
			bShouldHook = true;
			break;
		}
	}
	
	// Fake (un)hook because toggling actual hooks will cause server instability.
	g_bHooked = bShouldHook;
}

public Action:Hook_SetTransmit(entity, client) 
{
	new mate;

	return (g_bHide[client] && IsPlayerAlive(client) && client != entity && mate != entity && (0 < entity <= MaxClients)) ? Plugin_Handled : Plugin_Continue;
}

public Action:Hook_SetTransmitWeapon(entity, client) 
{
	new mate;

	return (g_bHide[client] && IsPlayerAlive(client) && g_iWeaponOwner[entity] && g_iWeaponOwner[entity] != client && g_iWeaponOwner[entity] != mate) ? Plugin_Handled : Plugin_Continue;
}

public Native_GetClientHide(Handle:plugin, numParams)
{
	return g_bHide[GetNativeCell(1)];
}

public Native_SetClientHide(Handle:plugin, numParams)
{
	g_bHide[GetNativeCell(1)] = bool:GetNativeCell(2);
}