CFCUlxCommands.speed = CFCUlxCommands.speed or {}
local cmd = CFCUlxCommands.speed

CATEGORY_NAME = "Fun"
                    
function cmd.speedPlayers( callingPlayer, targetPlayers, amount )
    for _, ply in pairs( targetPlayers ) do
        ply:SetWalkSpeed( 400 )
        ply:SetRunSpeed( 600 )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A set the speed for #T to #i", targetPlayers )
end

local speedCommand = ulx.command( CATEGORY_NAME, "ulx speed", cmd.speedPlayers, "!speed" )
speedCommand:addParam{ type = ULib.cmds.PlayersArg }
speedCommand:addParam{ type=ULib.cmds.NumArg, min=1, max=2^32/2-1, hint="speed", ULib.cmds.round }
speedCommand:defaultAccess( ULib.ACCESS_ADMIN )
speedCommand:help( "Sets the speed for target(s)." )
