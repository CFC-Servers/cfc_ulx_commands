CFCUlxCommands.checklua = CFCUlxCommands.checklua or {}
local cmd = CFCUlxCommands.checklua

CATEGORY_NAME = "Utility"
                    
function cmd.checkluaPlayers( callingPlayer, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
    end
    ulx.fancyLogAdmin( callingPlayer, true, "#A checked sv_allowcslua from #T", targetPlayers )
end

local checkluaCommand = ulx.command( CATEGORY_NAME, "ulx checklua", cmd.checkluaPlayers, "!checklua" )
checkluaCommand:addParam{ type = ULib.cmds.PlayersArg }
checkluaCommand:defaultAccess( ULib.ACCESS_ADMIN )
checkluaCommand:help( "Checks target(s) sv_allowcslua" )
