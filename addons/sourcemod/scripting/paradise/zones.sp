
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Plugin | ZONES",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

#define START_ZONE	0
#define END_ZONE	1
#define BONUS_START	2
#define BONUS_END	3
#define CHEAT_ZONE	4

enum Settings
{
	Float:PointA[3],
	Float:PointB[3],
	Float:PointC[3],
	Float:PointD[3],
	Float:PointE[3],
	Float:PointF[3],
	PointCount,
	Float:zHeight
}

new g_Zone[6][Settings];
new g_ZoneCount;

new bool:g_ZoneExists[6];
new bool:g_ZonesLoaded;

//Player Properties
new Float:g_Positions[MAXPLAYERS+1][2][3];
new Float:playerpos[MAXPLAYERS+1][3];
new g_SelectedZone[MAXPLAYERS+1];
new bool:IsPlayerInZone[6][MAXPLAYERS+1];

//Zone Properties
new zMaterial;
new zColor[4];
new Float:zWidth;
new ZoneFrame;
new ZoneFrameRepeat;

//Textures
new g_TextMaterial;
new g_BeamMaterial;
new g_GlowMaterial;
new g_RainbowMaterial;

new g_NeonRainbow[5][4];
new g_RGBCycle;

//Misc



//-----------------------------------
// Initialize Zones For Current Map |
//-----------------------------------

public InitZones()
{
	decl String:_sBuffer[PLATFORM_MAX_PATH];
	
	Format(_sBuffer, sizeof(_sBuffer), "materials/sprites/custom-sprite3.vmt");
	AddFileToDownloadsTable(_sBuffer);
	g_TextMaterial = PrecacheModel(_sBuffer);
	
	ReplaceString(_sBuffer, sizeof(_sBuffer), ".vmt", ".vtf", false);
	AddFileToDownloadsTable(_sBuffer);
	PrecacheModel(_sBuffer);
	
	Format(_sBuffer, sizeof(_sBuffer), "materials/sprites/lgtning.vmt");
	AddFileToDownloadsTable(_sBuffer);
	g_BeamMaterial = PrecacheModel(_sBuffer);
	
	ReplaceString(_sBuffer, sizeof(_sBuffer), ".vmt", ".vtf", false);
	AddFileToDownloadsTable(_sBuffer);
	PrecacheModel(_sBuffer);
	
	Format(_sBuffer, sizeof(_sBuffer), "materials/sprites/light_glow02.vmt");
	AddFileToDownloadsTable(_sBuffer);
	g_GlowMaterial = PrecacheModel(_sBuffer);
	
	ReplaceString(_sBuffer, sizeof(_sBuffer), ".vmt", ".vtf", false);
	AddFileToDownloadsTable(_sBuffer);
	PrecacheModel(_sBuffer);
	
	Format(_sBuffer, sizeof(_sBuffer), "materials/sprites/rainbowscroll.vmt");
	AddFileToDownloadsTable(_sBuffer);
	g_RainbowMaterial = PrecacheModel(_sBuffer);
	
	ReplaceString(_sBuffer, sizeof(_sBuffer), ".vmt", ".vtf", false);
	AddFileToDownloadsTable(_sBuffer);
	PrecacheModel(_sBuffer);
	
	g_ZoneCount = 5;

	for(new i = 0; i <= g_ZoneCount; i++)
	{
		for(new j = 0; j < 3; j++)
		{
			g_Zone[i][PointA][j] = 0.0;
			g_Zone[i][PointB][j] = 0.0;
			g_Zone[i][PointC][j] = 0.0;
			g_Zone[i][PointD][j] = 0.0;
			g_Zone[i][PointE][j] = 0.0;
			g_Zone[i][PointF][j] = 0.0;
		}
		
		g_ZoneExists[i] = false;
		g_Zone[i][PointCount] = 0;
	}
	
	g_ZonesLoaded = false;
	
	LoadZones(Map[MapName]);
	
	ZoneFrame = 0;
	ZoneFrameRepeat = 0;
	
	g_NeonRainbow[0] = {255, 0, 146, 255};
	g_NeonRainbow[1] = {255, 202, 27, 255};
	g_NeonRainbow[2] = {182, 255, 0, 255};
	g_NeonRainbow[3] = {34, 141, 255, 255};
	g_NeonRainbow[4] = {186, 1, 255, 255};
	
	CreateTimer(0.01, RainbowCycle, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(1.0, RefreshBeams, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action:RainbowCycle(Handle:timer)
{
	if(g_RGBCycle >= 4)
		g_RGBCycle = 0;
	else
		++g_RGBCycle;
}

public Action:RefreshBeams(Handle:timer)
{
	for(new z = 0; z < g_ZoneCount; z++)
	{
		switch(z)
		{
			case START_ZONE:
			{
				zColor = {34, 141, 255, 255};
				zMaterial = g_BeamMaterial;
				zWidth = 5.0;
			}
			case END_ZONE:
			{
				zColor = {255, 0, 146, 255};
				zMaterial = g_BeamMaterial;
				zWidth = 5.0;
			}
			case BONUS_START:
			{
				zColor = {255, 255, 255, 255};
				zMaterial = g_RainbowMaterial;
				zWidth = 2.0;
			}
			case BONUS_END:
			{
				zColor = {255, 255, 255, 255};
				zMaterial = g_RainbowMaterial;
				zWidth = 2.0;
			}
		}
		
		new Float:poly[6][3];
		new Float:polyR[6][3];
		new Float:xpoints[6];
		new Float:ypoints[6];
	
		Array_Copy(g_Zone[z][PointA], poly[0], 3);
		Array_Copy(g_Zone[z][PointB], poly[1], 3);
		Array_Copy(g_Zone[z][PointC], poly[2], 3);
		Array_Copy(g_Zone[z][PointD], poly[3], 3);
		Array_Copy(g_Zone[z][PointE], poly[4], 3);
		Array_Copy(g_Zone[z][PointF], poly[5], 3);
		
		for(new v = 0; v < g_Zone[z][PointCount]; v++)
		{
			if (v > 0)
			{
				if(poly[v][2] != poly[0][2])
				{
					poly[v][2] = poly[0][2];
				}
			}
			
			AddVectors(polyR[v], poly[v], polyR[v]);
			polyR[v][2] += g_Zone[z][zHeight];
			
			xpoints[v] = poly[v][0];
			ypoints[v] = poly[v][1];
		}
		
		switch(g_Zone[z][PointCount])
		{
			//Two Points (Single Line)
			case 2:
			{
				TE_SetupBeamPoints(poly[0], poly[1], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				
				if(z == START_ZONE || z == END_ZONE)
				{
					TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
				}
				//DrawLaser(poly[0], poly[1], z);
			}
			//Three Points (Triangle)
			case 3:
			{
				TE_SetupBeamPoints(poly[0], poly[1], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[1], poly[2], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[2], poly[0], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				
				if(z == START_ZONE || z == END_ZONE)
				{
					TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[2], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
				}
				
				//DrawLaser(poly[0], poly[1], z);
				//DrawLaser(poly[1], poly[2], z);
				//DrawLaser(poly[2], poly[0], z);
			}
			//Four Points (Quadrilateral)
			case 4:
			{
				TE_SetupBeamPoints(poly[0], poly[1], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 0, 0.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[1], poly[2], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 0, 0.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[2], poly[3], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 0, 0.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[3], poly[0], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 0, 0.0, zColor, 0);TE_SendToAll(0.0);
				
				if(z == START_ZONE || z == END_ZONE)
				{
					TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[2], polyR[3], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[3], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
				}
				
				//DrawLaser(poly[0], poly[1], z);
				//DrawLaser(poly[1], poly[2], z);
				//DrawLaser(poly[2], poly[3], z);
				//DrawLaser(poly[3], poly[0], z);
			}
			//Five Points (Pentagon)
			case 5:
			{
				TE_SetupBeamPoints(poly[0], poly[1], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[1], poly[2], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[2], poly[3], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[3], poly[4], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[4], poly[0], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				
				if(z == START_ZONE || z == END_ZONE)
				{
					TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[2], polyR[3], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[3], polyR[4], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[4], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
				}
				
				//DrawLaser(poly[0], poly[1], z);
				//DrawLaser(poly[1], poly[2], z);
				//DrawLaser(poly[2], poly[3], z);
				//DrawLaser(poly[3], poly[4], z);
				//DrawLaser(poly[4], poly[0], z);
			}
			//Six Points (Hexagon)
			case 6:
			{
				TE_SetupBeamPoints(poly[0], poly[1], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[1], poly[2], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[2], poly[3], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[3], poly[4], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[4], poly[5], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				TE_SetupBeamPoints(poly[5], poly[0], zMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 0);TE_SendToAll(0.0);
				
				if(z == START_ZONE || z == END_ZONE)
				{
					TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[2], polyR[3], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[3], polyR[4], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[4], polyR[5], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					TE_SetupBeamPoints(polyR[5], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 1.0, zWidth, zWidth, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
				}

				//DrawLaser(poly[0], poly[1], z);
				//DrawLaser(poly[1], poly[2], z);
				//DrawLaser(poly[2], poly[3], z);
				//DrawLaser(poly[3], poly[4], z);
				//DrawLaser(poly[4], poly[5], z);
				//DrawLaser(poly[5], poly[0], z);
			}
		}
	}
}

public TeleportToZone(client, zID)
{
	//Stop The Clients Timer
	StopTimer(client);
	
	if(g_ZoneExists[zID] && (g_ZonesLoaded))
	{
		//Get Zone's Position
		new Float:Location[3];
		GetZoneCenter(zID, Location);
		
		//Teleport Client To Zone
		TeleportEntity(client, Location, NULL_VECTOR, Float:{0.0, 0.0, 0.0});
	}
	else
	{
		PrintToServer("[Paradise] Error: Zone Not Found!");
	}
}

//---------------------------------------
// Create Zones | Test Players Position |
//---------------------------------------

public CreateZones()
{
	for(new z = 0; z < g_ZoneCount; z++)
	{
		//Zone Settings
		switch(z)
		{
			case START_ZONE:
			{
				zColor = {34, 141, 255, 255};
			}
			case END_ZONE:
			{
				zColor = {255, 0, 146, 255};
			}
			case BONUS_START:
			{
				zColor[0] = g_NeonRainbow[g_RGBCycle][0];
				zColor[1] = g_NeonRainbow[g_RGBCycle][1];
				zColor[2] = g_NeonRainbow[g_RGBCycle][2];
				zColor[3] = g_NeonRainbow[g_RGBCycle][3];
			}
			case BONUS_END:
			{
				zColor[0] = g_NeonRainbow[g_RGBCycle][0];
				zColor[1] = g_NeonRainbow[g_RGBCycle][1];
				zColor[2] = g_NeonRainbow[g_RGBCycle][2];
				zColor[3] = g_NeonRainbow[g_RGBCycle][3];
			}
			case CHEAT_ZONE:
			{
				zColor = {0, 0, 0, 0};
			}
		}
		
		//Point In Polygon Algorithm
		//by Aexi0n

		//We have a Polygon with anywhere from 2-6 vertices, and each vert consists of a vector(x,y,z).
		//First, Create the variables that will store our data. We are creating 4 Arrays. 'poly' holds the 6 ground points, polyR holds the 6 air points,
		//xpoints holds X points of polygon, ypoints holds y points of polygon.
		
		new Float:poly[6][3];
		new Float:polyR[6][3];
		new Float:xpoints[6];
		new Float:ypoints[6];

		//Fill the Poly & PolyR arrays with the proper data for the polygon. PolyR is all of the polygon's points with the Z increased by ZoneHeight.
		
		Array_Copy(g_Zone[z][PointA], poly[0], 3);
		Array_Copy(g_Zone[z][PointB], poly[1], 3);
		Array_Copy(g_Zone[z][PointC], poly[2], 3);
		Array_Copy(g_Zone[z][PointD], poly[3], 3);
		Array_Copy(g_Zone[z][PointE], poly[4], 3);
		Array_Copy(g_Zone[z][PointF], poly[5], 3);

		for(new v = 0; v < g_Zone[z][PointCount]; v++)
		{
			if (v > 0)
			{
				if(poly[v][2] != poly[0][2])
				{
					poly[v][2] = poly[0][2];
				}
			}
			
			AddVectors(polyR[v], poly[v], polyR[v]);
			polyR[v][2] += g_Zone[z][zHeight];
			
			xpoints[v] = poly[v][0];
			ypoints[v] = poly[v][1];
		}
		
		if(z != CHEAT_ZONE && (z == BONUS_START || z == BONUS_END))
		{
			if((ZoneFrame == z && ZoneFrameRepeat == 0))
			{
				switch(g_Zone[z][PointCount])
				{
					//Two Points (Single Line)
					case 2:
					{
						TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					}
					//Three Points (Triangle)
					case 3:
					{
						TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 0.2, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[2], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					}
					//Four Points (Quadrilateral)
					case 4:
					{
						TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 0.8, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 0.8, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[2], polyR[3], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 0.8, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[3], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 0.8, zColor, 10);TE_SendToAll(0.0);
					}
					//Five Points (Pentagon)
					case 5:
					{
						TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[2], polyR[3], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[3], polyR[4], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[4], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					}
					//Six Points (Hexagon)
					case 6:
					{
						TE_SetupBeamPoints(polyR[0], polyR[1], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[1], polyR[2], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[2], polyR[3], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[3], polyR[4], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[4], polyR[5], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
						TE_SetupBeamPoints(polyR[5], polyR[0], g_TextMaterial, g_GlowMaterial, 0, 0, 0.1, 5.0, 5.0, 2, 1.0, zColor, 10);TE_SendToAll(0.0);
					}
				}
			}
		}

		//Now we begin to loop through all of the clients doing a series of checks.
		for (new p = 1; p <= MaxClients; p++)
		{
			//First Check. Is Client In Game & Alive?
			if(IsClientInGame(p) && IsPlayerAlive(p))
			{
				//Store Client's Position As Test Point(X,Y,Z)
				GetClientAbsOrigin(p, playerpos[p]);
				
				//Second Check. Is Client Near The Polygon?
				if(IsPNearPoly(g_Zone[z][PointCount], z, poly, playerpos[p]) == 1)
				{
					//Final Check. Is Client Inside The Polygon, AND Is Client Below Top Point, and Above Bottom Point?
					if((IsPnPoly(g_Zone[z][PointCount], xpoints, ypoints, playerpos[p][0], playerpos[p][1]) == 1) && (playerpos[p][2] <= (polyR[0][2])) && (playerpos[p][2] >= (poly[0][2])))
					{
						//Client Is In Polygon. Did He Just Enter It?
						if(!IsPlayerInZone[z][p])
						{
							Zone_OnClientEntry(p, z);
							IsPlayerInZone[z][p] = true;
						}
					}
					else
					{
						//Client Is Outside Polygon. Did He Just Leave It?
						if(IsPlayerInZone[z][p])
						{
							Zone_OnClientLeave(p, z);
							IsPlayerInZone[z][p] = false;
						}
					}
				}
				else
				{
					//Client Is Outside Polygon. Did He Just Leave It?
					if(IsPlayerInZone[z][p])
					{
						Zone_OnClientLeave(p, z);
						IsPlayerInZone[z][p] = false;
					}
				}
			}
		}
	}
}


//----------------
// Zone Formulas |
//----------------

// |Is Point In Polygon| (Determines if a player is inside a 2D Polygon)
// Credits: http://www.ecse.rpi.edu/~wrf/Research/Short_Notes/pnpoly.html

public IsPnPoly(nvert, Float:vertx[6], Float:verty[6], Float:testx, Float:testy)
{
  new i, j, c = 0;
  
  for (i = 0, j = nvert-1; i < nvert; j = i++) 
  {
	//	 //verty[1] > testy != verty[2] > testy 
    if ( ((verty[i]>testy) != (verty[j]>testy)) && (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )
	{
		c = !c;
		
		//PrintToChatAll("%i V | L: P%i - P%i | C = %i", nvert, j, i, c);
	}
  }
  
  return c;
}

// |Is Point Near Polygon| (Determines if a player is near a zone, to prevent useless checks.)
// Credits: Aexi0n

public IsPNearPoly(nvert, zType, Float:polygon[6][3], Float:location[3])
{
	new Float:distance, Float:playerdistance, Float:center[3];
	
	distance = 0.0;

	GetZoneCenter(zType, center);

	for(new i = 0; i < nvert; i++)
	{
		new Float:temp = GetVectorDistance(polygon[i], center, false);

		if(temp > distance)
		{
			distance = temp;
		}
	}
	
	playerdistance = GetVectorDistance(location, center, false);
	
	if(playerdistance < distance)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

// |Center Point Of Polygon| (Calculates The Center X,Y,Z of a Polygon)
// Credits: Aexi0n

public GetZoneCenter(ZoneType, Float:zPos[3])
{
	for(new i = 0; i < 3; i++)
	{
		switch(g_Zone[ZoneType][PointCount])
		{
			case 3:{zPos[i] = (g_Zone[ZoneType][PointA][i] + g_Zone[ZoneType][PointB][i] + g_Zone[ZoneType][PointC][i]) / 3.0;}
			case 4:{zPos[i] = (g_Zone[ZoneType][PointA][i] + g_Zone[ZoneType][PointB][i] + g_Zone[ZoneType][PointC][i] + g_Zone[ZoneType][PointD][i]) / 4.0;}
			case 5:{zPos[i] = (g_Zone[ZoneType][PointA][i] + g_Zone[ZoneType][PointB][i] + g_Zone[ZoneType][PointC][i] + g_Zone[ZoneType][PointD][i] + g_Zone[ZoneType][PointE][i]) / 5.0;}
			case 6:{zPos[i] = (g_Zone[ZoneType][PointA][i] + g_Zone[ZoneType][PointB][i] + g_Zone[ZoneType][PointC][i] + g_Zone[ZoneType][PointD][i] + g_Zone[ZoneType][PointE][i] + g_Zone[ZoneType][PointF][i]) / 6.0;}
		}
	}
}