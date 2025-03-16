CFCUlxCommands.clearpac = CFCUlxCommands.clearpac or {}
local cmd = CFCUlxCommands.clearpac
local CATEGORY_NAME = "Utility"

function cmd.clearPac( callingPlayer, targetPlayers )
    if not pace then
        callingPlayer:PrintMessage( HUD_PRINTTALK, "Pac is not installed on the server!" )
        return
    end

    for _, ply in ipairs( targetPlayers ) do
        pace.ClearOutfit( ply )
        pac.emut.RemoveMutationsForPlayer( ply )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A cleared #T's pac", targetPlayers )
end

local clearpacCommand = ulx.command( CATEGORY_NAME, "ulx clearpac", cmd.clearPac, "!clearpac" )
clearpacCommand:addParam{ type = ULib.cmds.PlayersArg }
clearpacCommand:defaultAccess( ULib.ACCESS_ADMIN )
clearpacCommand:help( "Clear the pac for the target(s)." )
