CFCUlxCommands.breen = CFCUlxCommands.breen or {}
local cmd = CFCUlxCommands.breen

function cmd.breen( callingPlayer, targetPlayers )
    for _, ply in ipairs( targetPlayers ) do
        ply:ConCommand( "pac_clear_parts" )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A cleared #T's pac", targetPlayers )
end

local breenCommand = ulx.command( "Fun", "ulx breen", cmd.breen, "!breen" )
breenCommand:addParam{ type = ULib.cmds.PlayersArg }
breenCommand:defaultAccess( ULib.ACCESS_ADMIN )
breenCommand:help( "Drops a Breen desk on target's head." )
