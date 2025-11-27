#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include common_scripts\utility;

init() {
    // Initialize clientid before using it
    level.clientid = 0;
    
    level thread maps\mp\gametypes\_vote::init();
    
    level thread onPlayerConnect();
}


onPlayerConnect()
{
    for(;;) 
    {
        level waittill("connecting", player);
        
        // Assign the clientid to the player before incrementing
        player.clientid = level.clientid;
        level.clientid++;
        
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned() {
    self endon( "disconnect" );
    for(;;) {
        self waittill( "spawned_player" );
    }
}
