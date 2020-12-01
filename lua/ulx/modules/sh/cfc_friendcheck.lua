CFCUlxCommands.friendcheck = CFCUlxCommands.friendcheck or {}
local cmd = CFCUlxCommands.friendcheck

CATEGORY_NAME = "Utilities"
                    
function cmd.friendcheckPlayers( callingPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
    end

    ulx.fancyLogAdmin( callingPlayer, "#A friendcheck #T", targetPlayers )
end

local friendcheckCommand = ulx.command( CATEGORY_NAME, "ulx friendcheck", cmd.friendcheckPlayers, "!friendcheck" )
friendcheckCommand:addParam{ type = ULib.cmds.PlayersArg }
friendcheckCommand:defaultAccess( ULib.ACCESS_ADMIN )
friendcheckCommand:help( "friendchecks target(s)" )
