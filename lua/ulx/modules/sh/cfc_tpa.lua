CFCUlxCommands.tpa = CFCUlxCommands.tpa or {}
local cmd = CFCUlxCommands.tpa
local CATEGORY_NAME = "Teleport"

function cmd.tpa( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        -- do code
    end

    --ulx.fancyLogAdmin( callingPlayer, "#A requested teleportation to #T", targetPlayers )
end

local tpaCommand = ulx.command( CATEGORY_NAME, "ulx tpa", cmd.tpa, "!tpa" )
tpaCommand:addParam{ type = ULib.cmds.PlayersArg }
tpaCommand:defaultAccess( ULib.ACCESS_ADMIN )
tpaCommand:help( "Requests a teleport to other players." )
