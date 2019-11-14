
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Timer | EVE",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

new replayCount;

//----------------------------
// Initialize EVE Replay Bot |
//----------------------------

public LoadEVE(client)
{
	decl String:buffer[35];
		
	Format(buffer, sizeof(buffer), "Status: Online | Timeleft: %i min.", TimeLeft);
	CS_SetClientClanTag(client, "EVE");
	SetClientName(client, buffer);
}

public Action:BotMimic_OnPlayerStartsMimicing(client, String:name[], String:category[], String:evePath[])
{
	decl String:buffer[256];
	decl String:Message[256];
	
	if(StrEqual(name, "bhop_worldwar_csgoWR-8", false))
	{
		Format(buffer, 256, "Map Overview");

		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Welcome To \x01\x06bhop_worldwar!");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08This WWI Style Map by Saspatoon has\x01\x06 3 Stages\x01\x08, and rewards\x01\x06 25 XP.");
		PrintToChatAll(Message);
	}
	else if(StrEqual(name, "bhop_spongebob_csgoWR-8", false))
	{
		Format(buffer, 256, "Map Overview");

		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Welcome To \x01\x06bhop_spongebob!");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08This Underwater Spongebob-Themed  Map by A. Nightwolf has\x01\x06 10 Stages\x01\x08, and rewards\x01\x06 75 XP.");
		PrintToChatAll(Message);
	}
	else if(StrEqual(name, "bhop_peachrace_csgoWR-8", false))
	{
		Format(buffer, 256, "Map Overview");

		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Welcome To \x01\x06bhop_peachrace!");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08This Friendly Cartoon Race Map by TonyToes has\x01\x06 12 Stages\x01\x08, and rewards\x01\x06 125 XP.");
		PrintToChatAll(Message);
	}
	else if(StrEqual(name, "bhop_pillars_csgoWR-8", false))
	{
		Format(buffer, 256, "Map Overview");

		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Welcome To \x01\x06bhop_pillars!");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08This Ancient Church-Themed Map by A. Nighwolf has\x01\x06 7 Stages\x01\x08, and rewards\x01\x06 50 XP.");
		PrintToChatAll(Message);
	}
	else if(StrEqual(name, "bhop_sina_csgoWR-8", false))
	{
		Format(buffer, 256, "Map Overview");

		//Set EVE's Replay Info
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
			
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08Welcome To \x01\x06bhop_sina!");
		PrintToChatAll(Message);
		Format(Message, sizeof(Message), " \x01\x03[EVE] \x01\x08This Unique Adventure Style Map by Saspatoon has\x01\x06 10 Stages\x01\x08, and rewards\x01\x06 1000 XP.");
		PrintToChatAll(Message);
	}
}

public BotMimic_OnPlayerStopsMimicing(client, String:name[], String:category[], String:evepath2[])
{
	if(StrContains(name, "WR-8", true) != -1)
	{
		BR_MOStart = true;
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsValidClient(i, false) && !IsFakeClient(i))
			{
				if(BR_Round == 1)
				{
					g_info[i][BRPoints] = 0.0;
				}
		
				new iRed, iBlue;
				for(new j = 1; j <= MaxClients; j++)
				{
					if(!IsClientInGame(j))
						continue;

					new iTeam = GetClientTeam(j);
					if(iTeam == CS_TEAM_T)
						iRed++;
					else if(iTeam == CS_TEAM_CT)
						iBlue++;
				}

				if(iRed < iBlue)
					ChangeClientTeam(i, 2);
				else
					ChangeClientTeam(i, 3);	

				CS_RespawnPlayer(i);
				
				SetClientOverlay(i, "effects/hsv.vmt");
				
				FakeClientCommand(i, "say !scstop");
			}
		}
		
		CreateTimer(1.0, Round_Countdown, _, TIMER_REPEAT);
	}
	else if(0 <= resultType < 8 && BR_RoundEnd)
	{
		resultType = resultType + 1;
		
		replayCount = 1;
		
		Round_Results(resultType);
	}
}

public BotMimic_OnPlayerMimicLoops(client)
{
	if(replayCount == 1)
	{
		decl String:buffer[35];
		replayCount = 0;
		BotMimic_StopPlayerMimic(client);
		
		Format(buffer, sizeof(buffer), "Status: Online | Timeleft: %i min.", TimeLeft);
		CS_SetClientClanTag(client, "EVE");
		SetClientName(client, buffer);
	}
	else if(replayCount == 0)
	{
		replayCount++;
	}
}

