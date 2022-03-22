CFCUlxCommands.respawn = CFCUlxCommands.respawn or {}
local cmd = CFCUlxCommands.respawn
local CATEGORY_NAME = "Utility"

function cmd.respawn( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        ply:Spawn()
    end

    ulx.fancyLogAdmin( callingPlayer, "#A respawned #T", targetPlayers )
end

local respawnCommand = ulx.command( CATEGORY_NAME, "ulx respawn", cmd.respawn, "!respawn" )
respawnCommand:addParam{ type = ULib.cmds.PlayersArg }
respawnCommand:defaultAccess( ULib.ACCESS_ADMIN )
respawnCommand:help( "Respawn the target(s)." )
