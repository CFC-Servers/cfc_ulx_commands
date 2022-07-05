CFCUlxCommands.sounds = CFCUlxCommands.sounds or {}
local cmd = CFCUlxCommands.sounds

function cmd.sounds( callingPlayer )
    for _, ply in ipairs( player.GetHumans() ) do
        ply:ConCommand( "stopsound" )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A cleaned up sounds." )
end

local soundsCommand = ulx.command( "Utility", "ulx sounds", cmd.sounds, "!sounds" )
soundsCommand:defaultAccess( ULib.ACCESS_ADMIN )
soundsCommand:help( "Cleans up all sounds in the server." )
