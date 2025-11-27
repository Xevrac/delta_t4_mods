#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init() {
	maps = undefined;
	votetime = undefined;
	winnertime = undefined;	
	
	maps = "mp_airfield,mp_asylum,mp_kwai,mp_drum,mp_bgate,mp_castle,mp_shrine,mp_stalingrad,mp_courtyard,mp_dome,mp_downfall,mp_hangar,mp_kneedeep,mp_makin,mp_makin_day,mp_nachtfeuer,mp_outskirts,mp_vodka,mp_roundhouse,mp_seelow,mp_subway,mp_docks,mp_suburban";

	votetime = 15.0;
	winnertime = 5.0;
	
	startup( maps, votetime, winnertime );
}

startup( maps, votetime, winnertime ) {
	level.inVote = undefined;
	
	level.VoteVoteTime = int( votetime ); 
	level.VoteWinnerTime = int( winnertime );

	CreateMapArray();
	level thread onPlayerConnect();

	game["menu_vote"] = "vote";
	precacheMenu( game["menu_vote"] );

	level.inVote = false;
	level.VotePosition = undefined;
	level.mapVotes = [];
	
	level.mapTok = [];
	level.mapTok = strTok( maps, "," );
	
    randomArray = [];
    for( i = 0; i < 6; i++ ) {
		selectedRand = RandomIntRange( 0, level.mapTok.size );	
        randomArray[i] = level.mapTok[selectedRand];
        level.mapTok = restructMapArray( level.mapTok, selectedRand );
    }
	
 	level.mapTok = randomArray;
	for( i = 0; i < level.mapTok.size; i++ ) {
		level.mapVotes[i] = 0;
	}
}

CreateMapArray() {
	level.cod5maps = [];
	
	//Custom Maps
	level.cod5maps["mp_78bathroom"] = "78 Bathroom";
	level.cod5maps["mp_78kwai"] = "78 Kwai";
	level.cod5maps["mp_78port"] = "78 Port";
	level.cod5maps["mp_82ab_erdol"] = "82 Ab Erdol";
	level.cod5maps["mp_agx_port"] = "AGX Port";
	level.cod5maps["mp_backlot"] = "Backlot";
	level.cod5maps["mp_beertruck"] = "Beertruck";
	level.cod5maps["mp_canal2"] = "Canal 2";
	level.cod5maps["mp_crash_day"] = "Crash Day";
	level.cod5maps["mp_doc78"] = "Doc 78";
	level.cod5maps["mp_feba"] = "Feba";
	level.cod5maps["mp_hijacked"] = "Hijacked";
	level.cod5maps["mp_homeroom"] = "Homeroom";
	level.cod5maps["mp_jungle"] = "Jungle";
	level.cod5maps["mp_killhouse"] = "Killhouse";
	level.cod5maps["mp_king"] = "King";
	level.cod5maps["mp_konigsberg"] = "Konigsberg";
	level.cod5maps["mp_lolv2"] = "Lol V2";
	level.cod5maps["mp_mohaa_dasboot"] = "Mohaa Dasboot";
	level.cod5maps["mp_montargis"] = "Montargis";
	level.cod5maps["mp_railyard"] = "Railyard";
	level.cod5maps["mp_ratsbedroom"] = "Rats Bedroom";
	level.cod5maps["mp_ratskitchen"] = "Rats Kitchen";
	level.cod5maps["mp_snr_arnhem44"] = "Arnhem 44";
	level.cod5maps["mp_snr_arnhemwt"] = "Arnhem WT";
	level.cod5maps["mp_snr_flatdeck"] = "Flatdeck";
	level.cod5maps["mp_tge"] = "TGE";
	level.cod5maps["mp_thor"] = "Thor";
	level.cod5maps["mp_toujane"] = "Toujane";
	level.cod5maps["mp_warlord"] = "Warlord";
	
	//Original Maps 
	level.cod5maps["mp_airfield"] = "Airfield";
	level.cod5maps["mp_asylum"] = "Asylum";
	level.cod5maps["mp_castle"] = "Castle";
	level.cod5maps["mp_courtyard"] = "Courtyard";
	level.cod5maps["mp_dome"] = "Dome";
	level.cod5maps["mp_downfall"] = "Downfall";
	level.cod5maps["mp_hangar"] = "Hangar";
	level.cod5maps["mp_makin"] = "Makin";
	level.cod5maps["mp_makin_day"] = "Makin Day";
	level.cod5maps["mp_outskirts"] = "Outskirts";
	level.cod5maps["mp_roundhouse"] = "Roundhouse";
	level.cod5maps["mp_seelow"] = "Seelow";
	level.cod5maps["mp_shrine"] = "Cliffside";
	level.cod5maps["mp_suburban"] = "Upheaval";
	level.cod5maps["mp_nachtfeuer"] = "Nightfire";
	level.cod5maps["mp_subway"] = "Station";
	level.cod5maps["mp_kneedeep"] = "Knee Deep";
	level.cod5maps["mp_docks"] = "Sub Pens";
	level.cod5maps["mp_kwai"] = "Banzai";
	level.cod5maps["mp_vodka"] = "Revolution";
	level.cod5maps["mp_bgate"] = "Breach";
	level.cod5maps["mp_drum"] = "Battery";
	level.cod5maps["mp_stalingrad"] = "Corrosion";
}

VoteTimerAndText( text, countDown ) {
	level notify( "newVoteText" );
	level endon( "newVoteText" );
	
	for( ; countDown > 0; countDown-- ) {
		for( i = 0; i < level.players.size; i++ ) {
			player = level.players[i];
		
			player setClientDvar( "hud_voteText", ( text + " (" + countDown + "s):" ) );
			player PlaySoundToPlayer( "ui_mp_timer_countdown", player );
		}
		wait 1;
		countDown--;
	}
}

BeginVoteForMatch() {
	if( !isDefined( level.inVote ) )
		return;
	
	level.inVote = true;
	level.VotePosition = "voting";
	
	updateVoteDisplayForPlayers();
	
	for( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];
		
		for( j = 0; j < level.mapTok.size; j++ ) 
			player setClientDvar( "hud_mapName"+j, getLocalisedName( level.mapTok[j] ) );
		
		player thread StartVoteForPlayer();
	}
	
	VoteTimerAndText( "^3Vote for new map", level.VoteVoteTime );
	level notify( "time_over" );
	SetFinalVoteMap();
	
	for( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];
		player setClientDvar( "hud_ShowWinner", "1" );
	}
	
	level.VotePosition = "winner";
	VoteTimerAndText( "^3Next Map", level.VoteWinnerTime );
	level.VotePosition = undefined;
	
	for( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];
		
		player closeMenu( game["menu_vote"] );
		player setClientDvar( "ui_inVote", "0" );
		player setClientDvar( "hud_ShowWinner", "0" );
	}
	
	for( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];
		
		if( player.sessionstate != "intermission" )
			player.sessionstate = "intermission";
	}
	
	level.inVote = false;
}

StartVoteForPlayer() {
	if( self.sessionstate != "spectator" )
		self.sessionstate = "spectator";
		
	self closeMenu();
	self closeInGameMenu();
	
	self setClientDvar( "hud_ShowWinner", "0" );
	self setClientDvar( "ui_inVote", "1" );
	self openMenu( "vote" );
	
	self thread onDisconnect();
}

getMapName( InputMap ) {
	map = tolower( InputMap ); //Make lower case
	
	return map;
}

getLocalisedName( InputMap ) {
	map = tolower( InputMap );
	
	if( isDefined( level.cod5maps[map] ) )
		return level.cod5maps[map];
	else
		return map;
}

onPlayerConnect() {
	for(;;) {
		level waittill( "connected", player );
        	
		player thread onMenuResponse();
		player thread playerInitVote();
    }
}

playerInitVote() {
	self endon( "disconnect" );

	self setClientDvar( "ui_inVote", "0" );
	self setClientDvar( "ui_selected_vote", "" );

	if( level.inVote && isDefined( level.VotePosition ) ) {	
		if( level.VotePosition == "voting" ) {
			wait 1;
			updateVoteDisplayForPlayers();
			self StartVoteForPlayer();
		}
		else if( level.VotePosition == "winner" ) {
			wait 1;
			winNumberA = getHighestVotedMap();
			self StartVoteForPlayer();
			self setClientDvar( "hud_voteText", "^3Next Map:" );
			self setClientDvar( "hud_ShowWinner", "1" );
	
			MapNameLoc = ("^3" + getLocalisedName(level.mapTok[winNumberA]));
	
			self setClientDvar( "hud_WinningMap", MapNameLoc );
		}
	}
}

onMenuResponse() {
    self endon( "disconnect" );

    for(;;) {
        self waittill( "menuresponse", menu, response );
		
		if( menu == game["menu_vote"] && level.inVote ) {
			switch(response) {
			case "map1":
				self castMap(0);
				break;
			case "map2":
				self castMap(1);
				break;
			case "map3":
				self castMap(2);
				break;
			case "map4":
				self castMap(3);
				break;
			case "map5":
				self castMap(4);
				break;
			case "map6":
				self castMap(5);
			default:
				break;
			}
        }
		if( response == "back" && level.inVote )
			self openMenu( "vote" );
	}
}

restructMapArray( oldArray, index ) {
	restructArray = [];
	for( i = 0; i < oldArray.size; i++ ) {
		if( i < index ) 
			restructArray[i] = oldArray[i];
		else if( i > index ) 
			restructArray[i - 1] = oldArray[i];
	}
	return restructArray;
}

updateVoteDisplayForPlayers() {
	for( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];
		
		player setClientDvar( "hud_gamesize", level.players.size );
		for( j = 0; j < level.mapTok.size; j++ ) {
			player setClientDvar( "hud_mapVotes"+j, "^7" + level.mapVotes[j] );
			player setClientDvar( "hud_mapName"+j, "^7" + getLocalisedName(level.mapTok[j]) );
		}
		
		highestIndex = getHighestVotedMap();
		if( level.mapVotes[highestIndex] != 0 ) {
			player setClientDvar( "hud_mapVotes"+highestIndex, "^3"+level.mapVotes[highestIndex] );
			player setClientDvar( "hud_mapName"+highestIndex, "^3"+getLocalisedName(level.mapTok[highestIndex]) );
		}
	}
}

getHighestVotedMap() {
	highest = 0;

	position = randomInt( level.mapVotes.size );
	
	for( i = 0; i < level.mapVotes.size; i++ ) {
		if( level.mapVotes[i] > highest ) {
			highest = level.mapVotes[i];
			position = i;
		}
	}		

	return position;
}

getRandomGameMode()
{
    modes = [];

    modes[0] = "tdm";
    modes[1] = "dom";
    modes[2] = "sab";
    modes[3] = "twar";
	modes[4] = "koth";
	modes[5] = "dm";

    randomIndex = randomInt(modes.size);
    return modes[randomIndex];
}

castMap( number ) {
	if( !isDefined(self.hasVoted) || !self.hasVoted ) {
		self.hasVoted = 1;
		level.mapVotes[number]++;
		self.votedNum = number;
		updateVoteDisplayForPlayers();

		MapNameLoc = getLocalisedName(level.mapTok[self.votedNum]);
	}
	else if( self.hasVoted && isDefined( self.votedNum ) && self.votedNum != number ) {
		level.mapVotes[self.votedNum]--;
		level.mapVotes[number]++;
		self.votedNum = number;
		updateVoteDisplayForPlayers();
		
		MapNameLoc = getLocalisedName(level.mapTok[self.votedNum]);
	}
}

onDisconnect() {
	level endon ( "time_over" );
	self waittill ( "disconnect" );
	
	if( level.inVote && isDefined(level.VotePosition) ) {
		if ( isDefined( self.votedNum ) ) 
			level.mapVotes[self.votedNum]--;
			
		if ( level.VotePosition == "voting" )
			updateVoteDisplayForPlayers();
	}
}

SetFinalVoteMap()
{
    winNumberA = randomInt(level.mapTok.size);
    level.RandomMap = level.mapTok[winNumberA];  
    level.winMap = getMapName(level.RandomMap);

    if (level.players.size > 0)
    {
        winNumberA = getHighestVotedMap();
        level.winMap = getMapName(level.mapTok[winNumberA]);
        for (i = 0; i < level.players.size; i++)
        {
            player = level.players[i];
            MapNameLoc = ("^3" + getLocalisedName(level.mapTok[winNumberA]));
            player setClientDvar("hud_WinningMap", MapNameLoc);
        }
    }

    level.randomMode = getRandomGameMode();

    setDvar("sv_maprotation", "gametype " + level.randomMode + " map " + level.winMap);
    setDvar("sv_maprotationCurrent", "gametype " + level.randomMode + " map " + level.winMap);

}