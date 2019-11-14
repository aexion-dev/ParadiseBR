
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | STYLES",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

#define Energy 0

// Dodging
new Float:g_LastSideMove[MAXPLAYERS + 1][2];
new g_LastDodgeTick[MAXPLAYERS + 1];
new g_LandingTick[MAXPLAYERS + 1];
new g_LastTapTick[MAXPLAYERS + 1];
new g_LastTapKey[MAXPLAYERS + 1];
new g_WallJumpCount[MAXPLAYERS + 1];
new bool:g_bCanDodge[MAXPLAYERS + 1];
new bool:g_bWaitingForGround[MAXPLAYERS + 1];

// Double jumping
new bool:g_Jumped[MAXPLAYERS + 1];
new g_LastButtons[MAXPLAYERS + 1];

//Half-Sideways
new Float:g_fUnblockControl[MAXPLAYERS+1];
new g_iMoveCount[MAXPLAYERS+1] = 0;
new g_iFORWARD_hits[MAXPLAYERS+1] = 0;
new g_iBACK_hits[MAXPLAYERS+1] = 0;
new g_iMOVELEFT_hits[MAXPLAYERS+1] = 0;
new g_iMOVERIGHT_hits[MAXPLAYERS+1] = 0;
new g_iKey_hits[MAXPLAYERS+1] = 0;
new g_iKey_hits_reset[MAXPLAYERS+1] = 0;
new Float:g_fCount_FORWARD[MAXPLAYERS+1] = 0.0;
new Float:g_fCount_BACK[MAXPLAYERS+1] = 0.0;
new Float:g_fCount_MOVELEFT[MAXPLAYERS+1] = 0.0;
new Float:g_fCount_MOVERIGHT[MAXPLAYERS+1] = 0.0;
new Float:g_fCount_Keys[MAXPLAYERS+1] = 0.0;

//Show Keys
new g_iButtonsPressed[MAXPLAYERS+1] = {0,...};
new Spectators[MAXPLAYERS+1];

new TotalSync[MAXPLAYERS+1] = 0;
new GoodSync[MAXPLAYERS+1] = 0;
new Float:g_fOldAngle[MAXPLAYERS+1];
new Float:g_HSWCounter[MAXPLAYERS+1];
new g_buttonsClient[MAXPLAYERS+1];


public StyleTimers()
{
	//Parkour Energy
	CreateTimer(1.0, Timer_Regen, _, TIMER_REPEAT);
}


//----------------------
// Auto BunnyHop Style |
//----------------------

public AutoBhop(client, &buttons)
{
	new index = GetEntProp(client, Prop_Data, "m_nWaterLevel");
	new water = EntIndexToEntRef(index);
	if (water != INVALID_ENT_REFERENCE)
	{
		if (IsPlayerAlive(client))
		{
			if (buttons & IN_JUMP)
			{
				if (index <= 1)
				{
					if (!(GetEntityMoveType(client) & MOVETYPE_LADDER))
					{
						SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
						if (!(GetEntityFlags(client) & FL_ONGROUND))
						{
							if(g_info[client][Style] != 2)
							{
								buttons &= ~IN_JUMP;
							}
						}
					}
				}
			}
		}
	}
}



//----------------
// Parkour Style |
//----------------

public Action:ParkourMoves(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(g_info[client][Style] == 4)
	{
		if(IsPlayerAlive(client) && !IsFakeClient(client))
		{
			// Button detection
			CheckForKeyTap(client, vel);
			
			new energy = GetEntProp(client, Prop_Data, "m_ArmorValue")
		
			if(buttons & IN_ATTACK2)
			{
				if(energy == 100)
				{
					WallRun(client);
				}
			}
		}
	
		g_LastSideMove[client][0] = vel[0];
		g_LastSideMove[client][1] = vel[1];
		g_LastButtons[client] = buttons;
	}
}

public Action:Timer_Regen(Handle:timer, any:data)
{
	for(new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			if(g_info[client][Style] == 4)
			{
				new energy = GetEntProp(client, Prop_Data, "m_ArmorValue");
				
				if(energy <= 80)
				{
					energy += 20;
				}
				else if (energy > 80 && energy < 100)
				{
					energy = 100;
				}
				
				SetEntProp(client, Prop_Data, "m_ArmorValue", energy)
			}
		}
	}
}

public WallRun(client)
{
	new bool:bCanWallRun;
	
	new Float:vAng[3];
	GetClientEyeAngles(client, vAng);
	vAng[0] = 0.0;
	
	new Float:vDodgeDir[3];
	
	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		bCanWallRun = false;
	}
	else
	{
		new Float:vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);
		
		GetAngleVectors(vAng, NULL_VECTOR, vDodgeDir, NULL_VECTOR); //Trace If Wall To Player's Left
		
		new Float:vTraceAngle[3];
		vTraceAngle[0] = vDodgeDir[0];
		vTraceAngle[1] = vDodgeDir[1];
		vTraceAngle[2] = vDodgeDir[2];
		NegateVector(vTraceAngle);
		GetVectorAngles(vTraceAngle, vTraceAngle);
		
		TR_TraceRayFilter(vPos, vTraceAngle, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceRayDontHitSelf, client);
		
		if(TR_DidHit())
		{
			new Float:vHitPos[3];
			TR_GetEndPosition(vHitPos);
			
			if(GetVectorDistance(vPos, vHitPos) < 30)
			{
				bCanWallRun = true;
			}
			else
			{
				NegateVector(vDodgeDir); //Didn't Find Wall, Trace To Player's Right
				
				vTraceAngle[0] = vDodgeDir[0];
				vTraceAngle[1] = vDodgeDir[1];
				vTraceAngle[2] = vDodgeDir[2];
				NegateVector(vTraceAngle);
				GetVectorAngles(vTraceAngle, vTraceAngle);
				
				TR_TraceRayFilter(vPos, vTraceAngle, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceRayDontHitSelf, client);
				
				if(TR_DidHit())
				{
					new Float:vHitPosi[3];
					TR_GetEndPosition(vHitPosi);
				
					if(GetVectorDistance(vPos, vHitPosi) < 30)
					{
						bCanWallRun = true;
					}
				}
			}
		}
	}
	
	//Start WallRun
	if(bCanWallRun == true)
	{
		GetAngleVectors(vAng, vDodgeDir, NULL_VECTOR, NULL_VECTOR)
		vDodgeDir[0] *= 500.0;
		vDodgeDir[1] *= 500.0;
		vDodgeDir[2] *= 10.0;
			
		new Float:vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
			
		new Float:vResult[3];
		AddVectors(vVel, vDodgeDir, vResult);
		
		SetEntityGravity(client, Pow(Pow(100.0, 3.0), -1.0));
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vResult);
		
		SetEntityGravity(client, 0.9);
		
		SetEntProp(client, Prop_Data, "m_ArmorValue", Energy);
		
		g_info[client][WallRuns]++;
		
	}
}

public CheckForKeyTap(client, Float:vel[3])
{
	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		if(g_WallJumpCount[client] > 0)
		{
			g_WallJumpCount[client] = 0;
		}
		
		g_bCanDodge[client] = true;
		
		if(g_bWaitingForGround[client] == true)
		{
			g_bWaitingForGround[client] = false;
			g_LandingTick[client]       = GetGameTickCount();
		}
	}
	
	if(g_bCanDodge[client] == false)
		return;
	
	if((GetGameTickCount() - g_LandingTick[client]) < 30)
		return;
	
	if(g_LastSideMove[client][1] <= 0 && vel[1] > 0)
		OnClientTappedKey(client, IN_MOVERIGHT);
	else if(g_LastSideMove[client][1] >= 0 && vel[1] < 0)
		OnClientTappedKey(client, IN_MOVELEFT);
	else if(g_LastSideMove[client][0] <= 0 && vel[0] > 0)
		OnClientTappedKey(client, IN_FORWARD);
	else if(g_LastSideMove[client][0] >= 0 && vel[0] < 0)
		OnClientTappedKey(client, IN_BACK);
}

public OnClientTappedKey(client, Key)
{
	if(g_LastTapKey[client] == Key && (GetGameTickCount() - g_LastTapTick[client] < 20))
	{
		OnClientDoubleTappedKey(client, Key);
	}
	
	g_LastTapKey[client]  = Key;
	g_LastTapTick[client] = GetGameTickCount();
}

public OnClientDoubleTappedKey(client, Key)
{
	new Float:vAng[3];
	GetClientEyeAngles(client, vAng);
	vAng[0] = 0.0; // Ensures consistent jumps if player is considered to be facing straight outwards
	
	// Get direction player wants to walljump (not the direction the wall is)
	new Float:vDodgeDir[3];
	if(Key == IN_MOVERIGHT)
	{
		GetAngleVectors(vAng, NULL_VECTOR, vDodgeDir, NULL_VECTOR);
	}
	else if(Key == IN_MOVELEFT)
	{
		GetAngleVectors(vAng, NULL_VECTOR, vDodgeDir, NULL_VECTOR);
		NegateVector(vDodgeDir);
	}
	else if(Key == IN_FORWARD)
	{
		GetAngleVectors(vAng, vDodgeDir, NULL_VECTOR, NULL_VECTOR);
	}
	else if(Key == IN_BACK)
	{
		GetAngleVectors(vAng, vDodgeDir, NULL_VECTOR, NULL_VECTOR);
		NegateVector(vDodgeDir);
	}
	
	// Checks if a client is allowed to walljump (Not On Ground, Next To Wall)
	new bool:bCanDodge;
	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		bCanDodge = false;
	}
	else
	{
		new Float:vPos[3];
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);
		
		new Float:vTraceAngle[3];
		vTraceAngle[0] = vDodgeDir[0];
		vTraceAngle[1] = vDodgeDir[1];
		vTraceAngle[2] = vDodgeDir[2];
		NegateVector(vTraceAngle);
		GetVectorAngles(vTraceAngle, vTraceAngle);
		
		TR_TraceRayFilter(vPos, vTraceAngle, MASK_SOLID_BRUSHONLY, RayType_Infinite, TraceRayDontHitSelf, client);
		
		if(TR_DidHit())
		{
			new Float:vHitPos[3];
			TR_GetEndPosition(vHitPos);
			
			if(GetVectorDistance(vPos, vHitPos) < 30)
			{
				bCanDodge = true;
			}
		}
	}
	
	// Start walljump
	if(bCanDodge == true)
	{
		if(g_WallJumpCount[client] < 3)
		{
			vDodgeDir[0] *= 300.0;
			vDodgeDir[1] *= 300.0;
			
			new Float:vVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
			
			new Float:vResult[3];
			AddVectors(vVel, vDodgeDir, vResult);
			vResult[2] = 225.0;
			
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vResult);
			
			g_LastDodgeTick[client] = GetGameTickCount();
			
			new Float:vPos[3];
			GetClientEyePosition(client, vPos);
			
			g_WallJumpCount[client]++;
			g_info[client][WallJumps]++;
			
			g_bWaitingForGround[client] = true;
			g_bCanDodge[client] = true;
		}
	}
}



public Action:AngleMoves(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	new iInitialButtons = buttons;
	
	if(!IsPlayerAlive(client))
		return Plugin_Continue;
	
	new Float:fGameTime = GetGameTime();
	new bool:abuse = false;
	new bool:onground = bool:(GetEntityFlags(client) & FL_ONGROUND);
	
	if(onground && g_info[client][Style] == 5)
	{
		Block_MovementControl(client, true);
	}
	
	if(!onground)
	{
		if(g_info[client][Style] == 5)
		{
			if(IsPlayerAlive(client) && !IsFakeClient(client))
			{
				g_iMoveCount[client] = 0;
					
				new Float:fCheck_KeyCounts = 0.25;													//time after 2 buttons have to be pressed in seconds
				new Float:fReset_KeyHits = 3.00;													//time after keyhits are resetted in seconds
				new iCheck_Key_hits = 5;															//max keyhits allowed within "fCheck_KeyCounts" time
					
					
				new Float:fTickrate = 1.0 / GetTickInterval();										//get server tickrate
				new Float:fCheck_KeyCounts_ticks = fCheck_KeyCounts*fTickrate;						//calculate how many ticks has to be ticked to match "fCheck_KeyCounts" time
					
				if(buttons & IN_FORWARD)
				{
					g_iMoveCount[client]++;															//count how many keys are pressed
					g_fCount_FORWARD[client]++;														//counts up as long as the button is pressed
				}
				else
				{
					if(g_fCount_FORWARD[client] > 1.0 && g_fCount_FORWARD[client] < fCheck_KeyCounts_ticks)
					{
						g_iFORWARD_hits[client]++;													//counts up if key is pressed for a short time (on purpose)
					}
					g_fCount_FORWARD[client] = 0.0;													//reset count after key is released
				}
					
				if(buttons & IN_BACK)
				{
					abuse = true;
				}
					
				if(buttons & IN_MOVELEFT)
				{
					g_iMoveCount[client]++;															//count how many keys are pressed
					g_fCount_MOVELEFT[client]++;													//counts up as long as the button is pressed
				}
				else
				{
					if(g_fCount_MOVELEFT[client] > 1.0 && g_fCount_MOVELEFT[client] < fCheck_KeyCounts_ticks)
					{
						g_iMOVELEFT_hits[client]++;													//counts up if key is pressed for a short time (on purpose)
					}
					g_fCount_MOVELEFT[client] = 0.0;												//reset count after key is released
				}
					
				if(buttons & IN_MOVERIGHT)
				{
					g_iMoveCount[client]++;															//count how many keys are pressed
					g_fCount_MOVERIGHT[client]++;													//counts up as long as the button is pressed
				}
				else
				{
					if(g_fCount_MOVERIGHT[client] > 1.0 && g_fCount_MOVERIGHT[client] < fCheck_KeyCounts_ticks)
					{
						g_iMOVERIGHT_hits[client]++;												//counts up if key is pressed for a short time (on purpose)
					}
					g_fCount_MOVERIGHT[client] = 0.0;												//reset count after key is released
				}
					
				g_fCount_Keys[client] = g_fCount_FORWARD[client]+g_fCount_BACK[client]+g_fCount_MOVELEFT[client]+g_fCount_MOVERIGHT[client];			//calculate time between button presses
					
				g_iKey_hits[client] = g_iFORWARD_hits[client]+g_iBACK_hits[client]+g_iMOVELEFT_hits[client]+g_iMOVERIGHT_hits[client];					//calculate all key hits
					
				if ((g_iMoveCount[client] == 1 && (g_fCount_Keys[client] >= fCheck_KeyCounts_ticks)) || (g_iKey_hits[client] >= iCheck_Key_hits))		//punish the client and reset keyhits/keycounts
				{
					abuse = true;
					g_fCount_FORWARD[client] = 0.0;
					g_fCount_BACK[client] = 0.0;
					g_fCount_MOVELEFT[client] = 0.0;
					g_fCount_MOVERIGHT[client] = 0.0;
					g_iFORWARD_hits[client] = 0;
					g_iBACK_hits[client] = 0;
					g_iMOVELEFT_hits[client] = 0;
					g_iMOVERIGHT_hits[client] = 0;
				}
				
				if (g_iMoveCount[client] == 3 && g_fCount_BACK[client] > 0.0)										// punish client for using +forward/+back exploit
				{
					abuse = true;
					g_fCount_FORWARD[client] = 0.0;
					g_fCount_BACK[client] = 0.0;
					g_fCount_MOVELEFT[client] = 0.0;
					g_fCount_MOVERIGHT[client] = 0.0;
					g_iFORWARD_hits[client] = 0;
					g_iBACK_hits[client] = 0;
					g_iMOVELEFT_hits[client] = 0;
					g_iMOVERIGHT_hits[client] = 0;
				}
				
				if (g_iMoveCount[client] == 2)														// reset keyhits/keycounts if 2 buttons are pressed
				{
					g_fCount_FORWARD[client] = 0.0;
					g_fCount_BACK[client] = 0.0;
					g_fCount_MOVELEFT[client] = 0.0;
					g_fCount_MOVERIGHT[client] = 0.0;
					g_iFORWARD_hits[client] = 0;
					g_iBACK_hits[client] = 0;
					g_iMOVELEFT_hits[client] = 0;
					g_iMOVERIGHT_hits[client] = 0;
				}
				
				g_iKey_hits_reset[client]++;
				
				if(g_iKey_hits_reset[client] > (fReset_KeyHits*fTickrate))									// reset keyhits
				{
					g_iFORWARD_hits[client] = 0;
					g_iBACK_hits[client] = 0;
					g_iMOVELEFT_hits[client] = 0;
					g_iMOVERIGHT_hits[client] = 0;
					g_iKey_hits_reset[client] = 0;
				}
			}
			
			if(vel[0] > 0 && vel[1] != 0)
			{
				g_HSWCounter[client] = GetEngineTime();
			}
			
			if(((GetEngineTime() - g_HSWCounter[client] > 0.4) || vel[0] <= 0) && !(GetEntityFlags(client) & FL_ONGROUND))	
			{
				abuse = true;
			}
		}
	
		if(g_info[client][Style] == 6 || g_info[client][Style] == 7)
		{
			if(IsPlayerAlive(client) && !IsFakeClient(client))
			{

				if (buttons & IN_MOVELEFT || vel[1] < 0)
				{
					abuse = true;
				}
				
				if (buttons & IN_MOVERIGHT || vel[1] > 0)
				{
					abuse = true;
				}
				
				if(g_info[client][Style] == 7)
				{
					if (buttons & IN_BACK || vel[0] < 0)
					{
						abuse = true;
					}
				}
			}

		}
	
		if(abuse && (g_info[client][Style] == 6 || g_info[client][Style] == 7))
		{
			//Block_MovementControl(client);
			//g_fUnblockControl[client] = (fGameTime + 1.0);
			
			if(!(GetEntityFlags(client) & FL_ATCONTROLS))
					SetEntityFlags(client, GetEntityFlags(client) | FL_ATCONTROLS);
		}
		else if(g_info[client][Style] == 6 || g_info[client][Style] == 7)// if(g_fUnblockControl[client] - fGameTime < 0.0)
		{
			//Block_MovementControl(client, true);
			if(GetEntityFlags(client) & FL_ATCONTROLS)
					SetEntityFlags(client, GetEntityFlags(client) &  ~FL_ATCONTROLS);
		}
	
	}
	else
	{
		if(abuse && (g_info[client][Style] == 6 || g_info[client][Style] == 7))
		{
			if(!(GetEntityFlags(client) & FL_ATCONTROLS))
					SetEntityFlags(client, GetEntityFlags(client) | FL_ATCONTROLS);
		}
		else if(g_info[client][Style] == 6 || g_info[client][Style] == 7)
		{
			if(GetEntityFlags(client) & FL_ATCONTROLS)
					SetEntityFlags(client, GetEntityFlags(client) &  ~FL_ATCONTROLS);
		}
	}
	
	if(abuse && g_info[client][Style] == 5)
	{
		Block_MovementControl(client);
		g_fUnblockControl[client] = (fGameTime + 0.2);
	}
	else if(g_fUnblockControl[client] - fGameTime < 0.0 && g_info[client][Style] == 5)
	{
		Block_MovementControl(client, true);
	}
	
	if(iInitialButtons != buttons)
		return Plugin_Changed;
    
	return Plugin_Continue;
}

stock Block_MovementControl(client, bool:unblock = false)
{
	if(!unblock)
	{
		SetEntityFlags(client, GetEntityFlags(client) | FL_ATCONTROLS);
	}
	else
	{
		SetEntityFlags(client, GetEntityFlags(client) & ~FL_ATCONTROLS);
	}
}

/** Black'y Strafe Formula - Thank You <3 **/

public VectorAngles(Float:vel[3], Float:angles[3])
{
	new Float:tmp, Float:yaw, Float:pitch;
	
	if(vel[1] == 0 && vel[0] == 0)
	{
		yaw = 0.0;
		if (vel[2] > 0)
			pitch = 270.0;
		else
			pitch = 90.0;
	}
	else
	{
		yaw = (ArcTangent2(vel[1], vel[0]) * (180 / 3.141593));
		if (yaw < 0)
			yaw += 360;

		tmp = SquareRoot(vel[0]*vel[0] + vel[1]*vel[1]);
		pitch = (ArcTangent2(-vel[2], tmp) * (180 / 3.141593));
		if (pitch < 0)
			pitch += 360;
	}
	
	angles[0] = pitch;
	angles[1] = yaw;
	angles[2] = 0.0;
}

public GetDirection(client)
{
	new Float:vVel[3];
	Entity_GetAbsVelocity(client, vVel);
	
	new Float:vAngles[3];
	GetClientEyeAngles(client, vAngles);
	new Float:fTempAngle = vAngles[1];

	VectorAngles(vVel, vAngles);

	if(fTempAngle < 0)
		fTempAngle += 360;

	new Float:fTempAngle2 = fTempAngle - vAngles[1];

	if(fTempAngle2 < 0)
		fTempAngle2 = -fTempAngle2;
	
	if(fTempAngle2 < 22.5 || fTempAngle2 > 337.5)
		return 1; // Forwards
	if(fTempAngle2 > 22.5 && fTempAngle2 < 67.5 || fTempAngle2 > 292.5 && fTempAngle2 < 337.5 )
		return 2; // Half-sideways
	if(fTempAngle2 > 67.5 && fTempAngle2 < 112.5 || fTempAngle2 > 247.5 && fTempAngle2 < 292.5)
		return 3; // Sideways
	if(fTempAngle2 > 112.5 && fTempAngle2 < 157.5 || fTempAngle2 > 202.5 && fTempAngle2 < 247.5)
		return 4; // Backwards Half-sideways
	if(fTempAngle2 > 157.5 && fTempAngle2 < 202.5)
		return 5; // Backwards
	
	return 0; // Unknown
}

Float:GetClientSync(client)
{
    if(GoodSync[client] == 0)
        return 0.0;
    
    return float(GoodSync[client])/float(TotalSync[client]) * 100.0;
}

public CheckSync(client, buttons, Float:vel[3], Float:angles[3])
{
	new Direction = GetDirection(client);
	
	if(Direction == 1 && GetClientVelocity(client, true, true, false) != 0)
	{	
		new flags = GetEntityFlags(client);
		new MoveType:movetype = GetEntityMoveType(client);
		if(!(flags & (FL_ONGROUND|FL_INWATER)) && (movetype != MOVETYPE_LADDER))
		{
			// Normalize difference
			new Float:fAngleDiff = angles[1] - g_fOldAngle[client];
			if (fAngleDiff > 180)
				fAngleDiff -= 360;
			else if(fAngleDiff < -180)
				fAngleDiff += 360;
			
			// Add to good sync if client buttons match up
			if(fAngleDiff > 0)
			{
				TotalSync[client]++;
				if((buttons & IN_MOVELEFT) && !(buttons & IN_MOVERIGHT))
				{
					GoodSync[client]++;
				}
				/*if(vel[1] < 0)
				{
					g_TimerStats[client][Timer_GoodSync][1]++;
				}*/
			}
			else if(fAngleDiff < 0)
			{
				TotalSync[client]++;
				if((buttons & IN_MOVERIGHT) && !(buttons & IN_MOVELEFT))
				{
					GoodSync[client]++;
				}
				/*if(vel[1] > 0)
				{
					g_TimerStats[client][Timer_GoodSync][1]++;
				}*/
			}
		}
	}
	
	g_fOldAngle[client] = angles[1];
}


public CountStrafes(client, buttons)
{
	if(!(g_buttonsClient[client] & IN_MOVELEFT) && (buttons & IN_MOVELEFT))
		g_info[client][Strafes]++;
	if(!(g_buttonsClient[client] & IN_MOVERIGHT) && (buttons & IN_MOVERIGHT))
		g_info[client][Strafes]++;

	g_buttonsClient[client] = buttons;
}

public ResetCounters(client)
{
	g_info[client][Jumps] = 0;
	g_info[client][Strafes] = 0;
	g_info[client][PreSpeed] = 0.0;
	g_info[client][WallRuns] = 0;
	g_info[client][WallJumps] = 0;
}






