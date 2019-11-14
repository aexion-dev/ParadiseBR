<h1 align="center"><img src="https://aexion.dev/img/Battle%20Royal%202016%20Banner.jpg"></h1>
<h4 align="center"></h4>
<p align="center">
  <a href="https://travis-ci.com/aexion-dev/Paradise"><img src="http://img.shields.io/badge/build-passing-brightgreen?style=flat-square"></a>
  <a href="https://github.com/aexion-dev/Paradise"><img src="https://img.shields.io/badge/release-v1.2.1-blue?style=flat-square"></a>
  <a href="https://github.com/aexion-dev/Paradise/issues"><img src="https://img.shields.io/badge/issues-0-brightgreen?style=flat-square&logo=github"></a>
  <br>
  <a href="#requirements">Requirements</a> •
  <a href="#installation">Installation</a> •
  <a href="#features">Gameplay</a> •
  <a href="#commands">Features</a> •
  <a href="#wiki">Commands</a> •
  <a href="#wiki">Wiki</a> •
  <a href="#support">Support</a> •
  <a href="#changelog">Changelog</a>
</p>
<p>Bunnyhop Battle Royale is the first ever bunnyhopping tournament for CS:GO. Players compete head-to-head for five rounds to determine who is truly the best bunnyhopper. Each round features a never-before seen map, and as the rounds progress the maps increase in difficulty/tier. Players can set records on any of the seven styles and are awarded points at the end of each round corresponding to the records they still hold. The player with the most points at the end of the final round is the winner.</p>

**Previous Events:**
  * [Spring 2016 Bunnyhop Battle Royale (VOD)](https://www.youtube.com/watch?v=4Vf-ORN6cbk&t=19s)
  * [Summer 2016 Bunnyhop Battle Royale (VOD)](https://www.youtube.com/watch?v=SbejlBjM8KQ)

## Gameplay
### Overview
Bunnyhop Battle Royale is a tournament event plug-in that places 28 players head-to-head in a competition to determine the best bunnyhopper. The event consists of five rounds of gameplay, each on a map that has never been played before. As the rounds progress, the maps become increasingly more difficult, and the roundtime is increased accordingly. During the round, players can switch between any of the seven styles and complete as many map runs as they can before time runs out. At the end of each round, the top 5 record holders for on each style will be awarded points based on the position of the record(s) they hold. At the completion of the final round, the player with the most points is the winner of the battle royale. 
### Maps
There are five maps in every battle royale, each one with a unique difficulty/tier corresponding to the round it's used in. Maps should be custom-made to ensure all competitors are new to the map and have an equal amount of time to develop routes/complete map runs. Due to different latencies, players should be given the maps in advanced to ensure everyone spawns in at relatively the same time. For best results, maps should be obfuscated beforehand using BSPSafe v1.0.0 in order to prevent players from decompiling maps and studying them before the event begins.
### Rounds
Every round will pause on start until every player has been authenticated and loaded-in successfully. At the start of each round, a cinematic map overview is displayed before the countdown begins. The timelimit of the first round is 20 min. and is increased by 10 min. for each round there after to account for the increase in map tier/difficulty. At the completion of each round players are moved to spectate and the current event standings are printed to chat. Each world record run is replayed once before the map is changed and the next round begins.
### Rules
During the event, players will be limited to the !respawn/!r, !style, !worldrecord/!wr and !pb/!me commands and map completion messages will only appear clientside unless it breaks the current world record. All player models are hidden and spectate is disabled to ensure players have no idea what style others are competing on. Replays are disabled to force players to develop their own unique routes.
### Scoring
At the end of each round, players are moved to spectate and the scores are calculated and printed to the chat. The top 5 record holders on each style are awarded points as follows: WR = 5pts. 2nd = 4 pts. 3rd = 3pts. 4th = 2pts. and 5th = 1pt. This score system forces players to decide between spending their time creating a faster route or completing the map on as many styles as possible before time runs out.
### Features
#### Map Overviews
#### Warm-up Lobby
#### Player Authentication
#### Winners Celebration

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
