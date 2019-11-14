
public Plugin:myinfo =
{
    name = "Paradise BunnyHop Timer | VIP",
    author = "Aexi0n",
    description = "Bunnyhop Battle Royale",
    version = "BR",
    url = ""
}

enum VIP
{
	String:Model[100],
	
}

new g_vip[MAXPLAYERS+1][VIP];
new bool:VIP_Player[MAXPLAYERS + 1];

new downloadtype;
new String:mediatype[256];


public PrecacheModels()
{
	PrecacheModel("models/player/paradise/hands/default/paradise_hands.mdl", true);
	PrecacheModel("models/player/pokemon_trainer/pokemon_trainer.mdl", true);
	PrecacheModel("models/player/bbs_93x_net/miku_skin/miku_spring.mdl", true);
	PrecacheModel("models/player/paradise/elsa/elsa2.mdl", true);
	PrecacheModel("models/player/paradise/mario/mario2.mdl", true);
	PrecacheModel("models/player/paradise/sonic/sonic.mdl", true);
	PrecacheModel("models/player/paradise/eve/eve.mdl", true);
	PrecacheModel("models/blackout.mdl", true);
	
	ReadDownloads();
}

public ReadDownloads()
{
	new String:file[256];
	BuildPath(Path_SM, file, 255, "configs/sm_skinchooser/skinchooserdownloads.ini");
	new Handle:fileh = OpenFile(file, "r");
	new String:buffer[256];
	downloadtype = 1;
	new len;
	
	if(fileh == INVALID_HANDLE) return;
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{	
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(!StrEqual(buffer,"",false))
		{
			ReadFileFolder(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	if(fileh != INVALID_HANDLE)
	{
		CloseHandle(fileh);
	}
}

public ReadFileFolder(String:filepath[])
{
	new Handle:dirh = INVALID_HANDLE;
	new String:buffer[256];
	new String:tmp_path[256];
	new FileType:type = FileType_Unknown;
	new len;
	
	len = strlen(filepath);
	if (filepath[len-1] == '\n')
		filepath[--len] = '\0';

	TrimString(filepath);
	
	if(DirExists(filepath))
	{
		dirh = OpenDirectory(filepath);
		while(ReadDirEntry(dirh,buffer,sizeof(buffer),type))
		{
			len = strlen(buffer);
			if (buffer[len-1] == '\n')
				buffer[--len] = '\0';

			TrimString(buffer);

			if (!StrEqual(buffer,"",false) && !StrEqual(buffer,".",false) && !StrEqual(buffer,"..",false))
			{
				strcopy(tmp_path,255,filepath);
				StrCat(tmp_path,255,"/");
				StrCat(tmp_path,255,buffer);
				if(type == FileType_File)
				{
					if(downloadtype == 1)
					{
						ReadItem(tmp_path);
					}
					
				
				}
			}
		}
	}
	else
	{
		if(downloadtype == 1)
		{
			ReadItem(filepath);
		}
		
	}
	if(dirh != INVALID_HANDLE)
	{
		CloseHandle(dirh);
	}
}

public ReadItem(String:buffer[])
{
	new len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);
	
	if(len >= 2 && buffer[0] == '/' && buffer[1] == '/')
	{
		if(StrContains(buffer,"//") >= 0)
		{
			ReplaceString(buffer,255,"//","");
		}
	}
	else if (!StrEqual(buffer,"",false) && FileExists(buffer))
	{
		if(StrContains(mediatype, "Model", true) >= 0)
		{
			PrecacheModel(buffer,true);
		}
		AddFileToDownloadsTable(buffer);
	}
}