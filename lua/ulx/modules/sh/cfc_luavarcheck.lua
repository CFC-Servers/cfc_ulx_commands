CFCUlxCommands.cllua = CFCUlxCommands.cllua or {}
local cmd = CFCUlxCommands.cllua

CATEGORY_NAME = "Utility"
                    
function cmd.clluaPlayers( callingPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
    end
    ulx.fancyLogAdmin( callingPlayer, true, "#A checked sv_allowcslua from #T", targetPlayers )
end

local clluaCommand = ulx.command( CATEGORY_NAME, "ulx cllua", cmd.clluaPlayers, "!cllua" )
clluaCommand:addParam{ type = ULib.cmds.PlayersArg }
clluaCommand:defaultAccess( ULib.ACCESS_ADMIN )
clluaCommand:help( "Checks target(s) sv_allowcslua" )
