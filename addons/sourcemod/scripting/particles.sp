#include <sourcemod>
#include <sdktools>

#pragma tabsize 0
#pragma semicolon 1

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | <3",
    author = "Aexi0n",
    description = "Official Bhop Plugin for Paradise Servers",
    version = "BR",
	url = ""
}

public OnPluginStart()
{
	RegConsoleCmd("sm_sp", Command_SpawnParticle);
	RegConsoleCmd("sm_spawnparticle", Command_SpawnParticle);
}

public OnMapStart()
{
	AddFileToDownloadsTable("particles/iex2.pcf");
	PrecacheGeneric("particles/iex2.pcf", true);  
}

public Action:Command_SpawnParticle(client, args)
{
	if(client == 0)
	{
	PrintToServer("Command In-game Only!");
	}
	if (args != 1)
	{
		ReplyToCommand(client, "[Particles] Usage:sm_sp or sm_spawnparticle <particle_name>");
		return Plugin_Handled;
	}
	
	decl String:particle[99];
	GetCmdArg(1, particle, sizeof(particle));
	CreateParticle(client, particle, 5.0);
	
	return Plugin_Handled;
}

stock CreateParticle(ent, String:particleType[], Float:time)
{
    new particle = CreateEntityByName("info_particle_system");

	decl String:name[64];

    if (IsValidEdict(particle))
    {
        new Float:position[3];
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
        TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
        GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
        DispatchKeyValue(particle, "targetname", "tf2particle");
        DispatchKeyValue(particle, "parentname", name);
        DispatchKeyValue(particle, "effect_name", particleType);
        DispatchSpawn(particle);
        SetVariantString(name);
        AcceptEntityInput(particle, "SetParent", particle, particle, 0);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "start");
        CreateTimer(time, DeleteParticle, particle);
    }
}

public Action:DeleteParticle(Handle:timer, any:particle)
{
    if (IsValidEntity(particle))
    {
        new String:classN[64];
        GetEdictClassname(particle, classN, sizeof(classN));
        if (StrEqual(classN, "info_particle_system", false))
        {
            RemoveEdict(particle);
        }
    }
}