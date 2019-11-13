<h1 align="center">Bunnyhop Battle Royale</h1>
<h4 align="center"></h4>
<p align="center">
  <a href="https://travis-ci.com/aexion-dev/Paradise"><img src="http://img.shields.io/badge/build-passing-brightgreen?style=flat-square"></a>
  <a href="https://github.com/aexion-dev/Paradise"><img src="https://img.shields.io/badge/release-v1.2.1-blue?style=flat-square"></a>
  <a href="https://github.com/aexion-dev/Paradise/issues"><img src="https://img.shields.io/badge/issues-0-brightgreen?style=flat-square&logo=github"></a>
  <br>
  <a href="#requirements">Requirements</a> •
  <a href="#installation">Installation</a> •
  <a href="#features">Overview</a> •
  <a href="#commands">Commands</a> •
  <a href="#wiki">Wiki</a> •
  <a href="#support">Support</a> •
  <a href="#changelog">Changelog</a>
</p>
Paradise is a CS:GO server plug-in built from the ground up to re-define bunnyhopping within the Counter-Strike franchise. New styles, complex features and global competitions combine to create an experience unlike anything you've played before.

### Requirements
```
* CS:GO Dedicated Server
  o SourceMod: Greater Than or Equal To 1.7
  o MetaMod: Source
* MySQL Database
  o MySQL 5.6 or MariaDB 10 and higher
```
### Installation
1. Download the latest version of Paradise and extract it to any folder.
2. Compile the plug-ins. (Optional)
    * Download Sourcemod V1.8 or later and extract it to any folder.
    * Copy all files from Paradise/addons/sourcemod/scripting/ into Sourcemod/addons/sourcemod/scripting.
    * Drag-and-drop paradise-plugin.sp onto compile.exe.
    * Copy paradise-plugin.smx from Sourcemod/addons/sourcemod/compiled/ to Paradise/addons/sourcemod/plugins.
3. Install plug-ins to CS:GO Dedicated Server.
    * Copy all files from Paradise/ into the server's csgo directory.
4. Configure MySQL/MariaDB Database.
    * Open the config file located at addons/sourcemod/configs/databases.cfg and add the following:
      ```
      "Databases"
      {
        "default"
        {
            "driver"			"mysql"
            "host"			"YourURL"
            "database"		"YourDatabaseName"
            "user"			"user"
            "pass"			"pass"
            //"timeout"		"0"
            //"port"			"0"
        }
      }
      ```
4. Restart Game Server and open server console to verify Paradise has been installed successfully.
### Recommended Add-ons
* [Slope Boost Fix v1.2](https://forums.alliedmods.net/showthread.php?t=266888) by Blacky
* [CS:GO Movement Unlocker v1.0](https://forums.alliedmods.net/showthread.php?t=255298) by Peace-Maker
* [Trigger_Push Fix v1.3](https://forums.alliedmods.net/showthread.php?t=267131) by Blacky/Hmmmm
* [MPBhops v1.0.1](https://forums.alliedmods.net/showpost.php?p=2561012&postcount=118) by DaFox/Hmmmmm
## Overview
### Gameplay
### Maps
### Rules
### Scoring
### Winners Circle
## Commands
Client Commands | Variables | Description
------------ | ------------- | -------------
sm_style | none | Open style selection menu
sm_r | none | Respawn at start of map
sm_b | none | Respawn at start of bonus map
sm_wr | none | Open world records menu
sm_maptop | [mapname] | View top records on map
sm_eve | none | Open EVE Bunnyhop Companion menu
sm_hideweapons | none | Toggle weapon visibility
sm_hideknife | none | Toggle knife visibility
sm_mapinfo | none |  View map information

Admin Commands | Variables | Description
------------ | ------------- | -------------
sm_zones | none | Open Paradise Zone Editor
sm_addmap | [mapname] [tier] [XP] | Add new map to database
sm_deletemap | [mapname] | Remove existing map from database
sm_querycount | none | Show # of MySQL Queries ran this round
sm_sh | [playername] | Show players strafes/angles for cheat detection

For a full list of commands and their functions, view our wiki page.
## Wiki
## Support
Feel free to reach out with any questions/feedback:
  * Website: [aexion.dev](https://www.aexion.dev/)
  * Steam: [Hunny Bop](https://steamcommunity.com/profiles/[U:1:196129736])
  * AlliedModders: [aexi0n](https://forums.alliedmods.net/member.php?u=255100)
## Changelog
