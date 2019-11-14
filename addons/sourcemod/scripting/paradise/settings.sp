#define ENT_RADAR 1 << 12
#define ENT_SPECHUD 1 << 13

public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | SETTINGS",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

public ParadiseSettings()
{
	PrintToServer("**---------------------------------------------------------------------------------------**");
	PrintToServer(" ");
	PrintToServer("Welcome to Paradise BunnyHop. Plugin Initializing..");
	PrintToServer(" ");
	PrintToServer("Connecting to Database.. ");
	
	if(db != INVALID_HANDLE)
	{
		PrintToServer("[SQL] Connection Successful!");
	}
	else if(db == INVALID_HANDLE)
	{
		PrintToServer("[SQL] Connection Failed! Could Not Connect To Database!");
	}
	
	PrintToServer(" ");
	PrintToServer("Loading System Settings..");
	
	SetCvar("sv_enablebunnyhopping", "1");
	PrintToServer("[Settings] BunnyHop Enabled");
	
	SetCvar("sv_airaccelerate", "600");
	PrintToServer("[Settings] Air Accelerate: 600");
	
	SetCvar("sv_friction", "4");
	PrintToServer("[Settings] Friction: 4");
	
	SetCvar("sv_accelerate", "5");
	PrintToServer("[Settings] Accelerate: 5");
	
	SetCvar("sv_maxvelocity", "9999");
	PrintToServer("[Settings] Max Velocity: Unlimited");
	
	SetCvar("sv_gravity", "800");
	PrintToServer("[Settings] Gravity: 800");
	
	SetCvar("sv_staminajumpcost", "0");
	PrintToServer("[Settings] Jump Cost: 0");
	
	SetCvar("sv_staminalandcost", "0");
	PrintToServer("[Settings] Land Cost: 0");
	
	SetCvar("sv_staminamax", "0");
	PrintToServer("[Settings] Stamina Max: 0");
	
	SetCvar("sv_staminarecoveryrate", "55");
	PrintToServer("[Settings] Stamina Recovery: 55");
	
	PrintToServer(" ");
	PrintToServer("System Settings Enabled!");
	PrintToServer(" ");
	PrintToServer("Loading Complete!");
	PrintToServer("P.A.R.A.D.I.S.E System Online");
	PrintToServer("V4.6.0 by Aexi0n");
	PrintToServer("http://bunnyhopparadise.com/");
	PrintToServer(" ");
	PrintToServer("**---------------------------------------------------------------------------------------**");
	
	CheatFlag("bot_zombie", false, true);
	
	SetCvar("sv_full_alltalk", "1");
	SetCvar("sv_allow_votes", "0");
	SetCvar("sv_footsteps", "0");
	SetCvar("sv_infinite_ammo", "1");
	SetCvar("sv_ladder_scale_speed", "1");
	SetCvar("mp_playercashawards", "0");
	SetCvar("mp_teamcashawards", "0");
	SetCvar("mp_match_restart_delay", "10");
	SetCvar("mp_ignore_round_win_conditions", "1");
	SetCvar("mp_do_warmup_period", "0");
	SetCvar("bot_zombie", "1");
	SetCvar("bot_join_after_player", "1");
	SetCvar("bot_quota", "1");
	SetCvar("bot_quota_mode", "normal");
	
	ServerCommand("sm_cvar bot_controllable 0");
	ServerCommand("sm_cvar sm_trigger_show 0");
	ServerCommand("mp_warmup_end");
}


//---------------------
// Enable All Talk    |
//---------------------

public SetAllTalk(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Handle:CvarHandle = FindConVar("sv_full_alltalk");
	new Full_AllTalk = GetConVarInt(CvarHandle);
	
	if(Full_AllTalk == 0 )
	{
		SetCvar("sv_full_alltalk", "1");
	}
}


public Action:Event_ServerCvar(Handle:event, const String:name[], bool:dontBroadcast)
{
	return Plugin_Handled;
}

//-------------------------------------
// Disable Name Change Notification   |
//-------------------------------------

public Action:SayText2(UserMsg:msg_id, Handle:bf, players[], playersNum, bool:reliable, bool:init)
{
    if(!reliable)
    {
        return Plugin_Continue;
    }

    new String:buffer[25];

    if(GetUserMessageType() == UM_Protobuf) // CSGO
    {
        PbReadString(bf, "msg_name", buffer, sizeof(buffer));

        if(StrEqual(buffer, "#Cstrike_Name_Change"))
        {
            return Plugin_Handled;
        }
    }

    return Plugin_Continue;
} 
//---------------------
// Disable Grenades   |
//---------------------

public Action:OnWeaponCanUse(client, weapon)  
{  
    decl String:sWeapon[32];  
    GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));  
    
    if((StrEqual(sWeapon, "weapon_hegrenade")) || (StrEqual(sWeapon, "weapon_smokegrenade")) || (StrEqual(sWeapon, "weapon_flashbang")) || (StrEqual(sWeapon, "weapon_decoy")) || (StrEqual(sWeapon, "weapon_incgrenade")))  
    {
		if( IsValidEdict( weapon ) )
		{
			AcceptEntityInput( weapon, "Kill" );
		}
		
		return Plugin_Handled;
    }     
    return Plugin_Continue;  
} 

//---------------------
// Disable Radar HUD  |
//---------------------

public Action:RemoveRadar(Handle:timer, any:client)
{
	if(IsValidClient(client, false))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", ENT_RADAR);
	}
}


public Action:OnPlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	return (Plugin_Handled);
}

//---------------------
// Enable HUD        |
//---------------------

public Action:ShowHUD(Handle:timer, any:client)
{
	if(IsValidClient(client, false))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", ENT_RADAR);
	}
}


//---------------------
// Disable HUD        |
//---------------------

public Action:RemoveHUD(Handle:timer, any:client)
{
	if(IsValidClient(client, false))
	{
		SetEntProp(client, Prop_Send, "m_iHideHUD", HIDEHUD_ALL);
	}
}


//--------------------------------
// Destroy Weapons When Dropped  |
//--------------------------------

public Action:Hook_WeaponDrop( client, weapon )
{
    if( IsValidEdict( weapon ) )
        AcceptEntityInput( weapon, "Kill" );
    
    return Plugin_Continue;
}