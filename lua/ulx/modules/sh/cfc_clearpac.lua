CFCUlxCommands.clearpac = CFCUlxCommands.clearpac or {}
local cmd = CFCUlxCommands.clearpac
local CATEGORY_NAME = "Utility"

function cmd.clearPac( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        ply:ConCommand( "pac_clear_parts" )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A cleared #T's pac", targetPlayers )
end

local clearpacCommand = ulx.command( CATEGORY_NAME, "ulx clearpac", cmd.clearPac, "!clearpac" )
clearpacCommand:addParam{ type = ULib.cmds.PlayersArg }
clearpacCommand:defaultAccess( ULib.ACCESS_ADMIN )
clearpacCommand:help( "Clear the pac for the target(s)." )
