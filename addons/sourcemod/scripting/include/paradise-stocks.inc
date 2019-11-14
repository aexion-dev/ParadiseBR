#if defined _paradise_stocks_included
 #endinput
#endif
#define _paradise_stocks_included


/** Limit Player Movement Velocity **/

stock LimitVelocity(client, Float:maxspeed)
{
	new Float:fVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
		
	if(fVelocity[0] == 0.0)
		fVelocity[0] = 1.0;
	if(fVelocity[1] == 0.0)
		fVelocity[1] = 1.0;
	if(fVelocity[2] == 0.0)
		fVelocity[2] = 1.0;
		
	new Float:currentspeed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
	
	if (currentspeed >= maxspeed)
	{
		new Float:Multpl = currentspeed / maxspeed;
		fVelocity[0] /= Multpl;
		fVelocity[1] /= Multpl;

		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	}
}

stock FakePrecacheSound( const String:szPath[] )
{
	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
}

stock bool:SetClientOverlay(client, String:strOverlay[])
{
	if(IsValidClient(client, false))
	{
		new iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);	
		ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
		return true;
	}
	return false;
}

/**
* Gets a client's velocity with extra settings to disallow velocity on certain axes
*/
stock Float:GetClientVelocity(client, bool:UseX, bool:UseY, bool:UseZ)
{
	new Float:vVel[3];
	
	if(UseX)
	{
		vVel[0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	}
	
	if(UseY)
	{
		vVel[1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	}
	
	if(UseZ)
	{
		vVel[2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
	}
	
	return GetVectorLength(vVel);
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	return entity != data && !(0 < entity <= MaxClients);
}

stock FormatNumberInt(value, String:buffer[], size, seperator=',')
{
    decl String:helper[size];
    IntToString(value, helper, size);
    strcopy(buffer, size, helper);

    new length = strlen(helper);

    new n_helper;

    if (helper[0] == '-') {
        n_helper += ((length-1) % 3) + 1;

        if (n_helper == 1) {
            n_helper = 4;
        }
    }
    else {
        n_helper += length % 3;

        if (n_helper == 0) {
            n_helper = 3;
        }
    }

    new n_buffer = n_helper;

    while (n_helper < length) {
        buffer[n_buffer] = seperator;
        strcopy(buffer[n_buffer + 1], size, helper[n_helper]);

        n_buffer += 4;
        n_helper += 3;
    }
}

stock FormatPlayerTime(Float:Time, String:result[], maxlength, bool:showDash, precision)
{
    if(Time <= 0.0 && showDash == true)
    {
        Format(result, maxlength, "-");
        return;
    }
    
    new hours     = RoundToFloor(Time/3600);
    Time         -= hours*3600;
    new minutes     = RoundToFloor(Time/60);
    Time         -= minutes*60;
    new Float:seconds = Time;
    
    decl String:sPrecision[16];
    
    if(precision == 0)
        Format(sPrecision, sizeof(sPrecision), (hours > 0 || minutes > 0)?"%04.1f":"%.1f", seconds);
    else if(precision == 1)
        Format(sPrecision, sizeof(sPrecision), (hours > 0 || minutes > 0)?"%06.3f":"%.3f", seconds);
    else if(precision == 2)
        Format(sPrecision, sizeof(sPrecision), (hours > 0 || minutes > 0)?"%05.2f":"%.2f", seconds);
    
    if(hours > 0)
        Format(result, maxlength, "%d:%02d:%s", hours, minutes, sPrecision);
    else if(minutes > 0)
        Format(result, maxlength, "%d:%s", minutes, sPrecision);
    else
        Format(result, maxlength, "%s", sPrecision);
}

stock bool:IsValidClient(client, bool:isAlive = false){ 
    if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (isAlive == false || IsPlayerAlive(client))) 
    { 
        return true; 
    } 
    return false; 
}

stock DrawLaser(Float:start[3], Float:end[3], lasertype)
{
    new ent = CreateEntityByName("env_beam");
    if (ent != -1)
    {
        TeleportEntity(ent, start, NULL_VECTOR, NULL_VECTOR);
		
		//Laser Types
		switch(lasertype)
		{
			//Start Zone Laser
			case 0:
			{
				SetEntityModel(ent, "materials/sprites/rainbowscroll.vmt"); // This is where you would put the texture, ie "sprites/laser.vmt" or whatever				        
				SetEntPropVector(ent, Prop_Data, "m_vecEndPos", end);
				DispatchKeyValue(ent, "targetname", "beam");
				DispatchKeyValue(ent, "rendercolor", "34 141 255 255");
				DispatchKeyValue(ent, "renderamt", "100");
				DispatchSpawn(ent);
				SetEntPropFloat(ent, Prop_Data, "m_fWidth", 5.0); // how big the beam will be, i.e "4.0"
				SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", 5.0); // same as above.
			}
			//End Zone Laser
			case 1:
			{
				SetEntityModel(ent, "materials/sprites/rainbowscroll.vmt"); // This is where you would put the texture, ie "sprites/laser.vmt" or whatever				        
				SetEntPropVector(ent, Prop_Data, "m_vecEndPos", end);
				DispatchKeyValue(ent, "targetname", "beam");
				DispatchKeyValue(ent, "rendercolor", "255, 0, 146, 255");
				DispatchKeyValue(ent, "renderamt", "100");
				DispatchSpawn(ent);
				SetEntPropFloat(ent, Prop_Data, "m_fWidth", 5.0); // how big the beam will be, i.e "4.0"
				SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", 5.0); // same as above.
			}
			//Bonus Start Laser
			case 2:
			{
				SetEntityModel(ent, "materials/sprites/rainbowscroll.vmt"); // This is where you would put the texture, ie "sprites/laser.vmt" or whatever				        
				SetEntPropVector(ent, Prop_Data, "m_vecEndPos", end);
				DispatchKeyValue(ent, "targetname", "beam");
				DispatchKeyValue(ent, "rendercolor", "0, 0, 0, 255");
				DispatchKeyValue(ent, "renderamt", "100");
				DispatchSpawn(ent);
				SetEntPropFloat(ent, Prop_Data, "m_fWidth", 2.0); // how big the beam will be, i.e "4.0"
				SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", 2.0); // same as above.
			}
			//Bonus End Laser
			case 3:
			{
				SetEntityModel(ent, "materials/sprites/rainbowscroll.vmt"); // This is where you would put the texture, ie "sprites/laser.vmt" or whatever				        
				SetEntPropVector(ent, Prop_Data, "m_vecEndPos", end);
				DispatchKeyValue(ent, "targetname", "beam");
				DispatchKeyValue(ent, "rendercolor", "255, 255, 255, 255");
				DispatchKeyValue(ent, "renderamt", "100");
				DispatchSpawn(ent);
				SetEntPropFloat(ent, Prop_Data, "m_fWidth", 2.0); // how big the beam will be, i.e "4.0"
				SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", 2.0); // same as above.
			}
		}
		
		
        ActivateEntity(ent);
        AcceptEntityInput(ent, "TurnOn");
    }
}

stock FixMotdCSGO(String:web[512], String:title[64])
{
	Format(web, sizeof(web), "http://www.cola-team.com/franug/webshortcuts2.php?web=%s;franug_is_pro;%s", title,web);
}

stock bool:GetCommunityIDString(const String:SteamID[], String:CommunityID[], const CommunityIDSize) 
{ 
    decl String:SteamIDParts[3][11]; 
    new const String:Identifier[] = "76561197960265728"; 
     
    if ((CommunityIDSize < 1) || (ExplodeString(SteamID, ":", SteamIDParts, sizeof(SteamIDParts), sizeof(SteamIDParts[])) != 3)) 
    { 
        CommunityID[0] = '\0'; 
        return false; 
    } 

    new Current, CarryOver = (SteamIDParts[1][0] == '1'); 
    for (new i = (CommunityIDSize - 2), j = (strlen(SteamIDParts[2]) - 1), k = (strlen(Identifier) - 1); i >= 0; i--, j--, k--) 
    { 
        Current = (j >= 0 ? (2 * (SteamIDParts[2][j] - '0')) : 0) + CarryOver + (k >= 0 ? ((Identifier[k] - '0') * 1) : 0); 
        CarryOver = Current / 10; 
        CommunityID[i] = (Current % 10) + '0'; 
    } 

    CommunityID[CommunityIDSize - 1] = '\0'; 
    return true; 
}

stock DrawRainbow(Float:start[3], Float:end[3])
{
    new ent = CreateEntityByName("env_beam");
    if (ent != -1)
    {
        TeleportEntity(ent, start, NULL_VECTOR, NULL_VECTOR);
        SetEntityModel(ent, "materials/sprites/rainbowscroll.vmt"); // This is where you would put the texture, ie "sprites/laser.vmt" or whatever.
        SetEntPropVector(ent, Prop_Data, "m_vecEndPos", end);
        DispatchKeyValue(ent, "targetname", "beam");
        DispatchKeyValue(ent, "rendercolor", "255 255 255");
        DispatchKeyValue(ent, "renderamt", "100");
        DispatchSpawn(ent);
        SetEntPropFloat(ent, Prop_Data, "m_fWidth", 1.0); // how big the beam will be, i.e "4.0"
        SetEntPropFloat(ent, Prop_Data, "m_fEndWidth", 1.0); // same as above
        ActivateEntity(ent);
        AcceptEntityInput(ent, "TurnOn");
    }
}

stock bool:CheatFlag(const String:voice_inputfromfile[], bool:isCommand, bool:remove)
{
	if(remove)
	{
		if (!isCommand)
		{
			new Handle:hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != INVALID_HANDLE)
			{
				new flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags &= ~FCVAR_CHEAT);
				return true;
			} 
			else 
				return false;			
		} 
		else 
		{
			new flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags &= ~FCVAR_CHEAT))
				return true;
			else 
				return false;
		}
	}
	else
	{
		if (!isCommand)
		{
			new Handle:hConVar = FindConVar(voice_inputfromfile);
			if (hConVar != INVALID_HANDLE)
			{
				new flags = GetConVarFlags(hConVar);
				SetConVarFlags(hConVar, flags & FCVAR_CHEAT);
				return true;
			}
			else 
				return false;
			
			
		} else
		{
			new flags = GetCommandFlags(voice_inputfromfile);
			if (SetCommandFlags(voice_inputfromfile, flags & FCVAR_CHEAT))	
				return true;
			else 
				return false;
				
		}
	}
}

stock bool:IsValidSteamID(String:steamid[])
{
	if(StrContains(steamid,"STEAM_", true) == 0)
	{
		return true;
	}
	return false;
}

stock SetCvar(String:scvar[], String:svalue[])
{
	new Handle:cvar = FindConVar(scvar);
	SetConVarString(cvar, svalue, true);
}
