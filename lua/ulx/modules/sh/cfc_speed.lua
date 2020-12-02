CFCUlxCommands.speed = CFCUlxCommands.speed or {}
local cmd = CFCUlxCommands.speed

CATEGORY_NAME = "Fun"
                    
function cmd.speedPlayers( callingPlayer, targetPlayers, amount )
    for _, ply in pairs( targetPlayers ) do
        ply:SetWalkSpeed( 200 * amount )
        ply:SetRunSpeed( 400 * amount )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A set the speed for #T to a " .. amount .. " speed multiplier", targetPlayers )
end

local speedCommand = ulx.command( CATEGORY_NAME, "ulx speed", cmd.speedPlayers, "!speed" )
speedCommand:addParam{ type = ULib.cmds.PlayersArg }
speedCommand:addParam{ type=ULib.cmds.NumArg, min=1, max=10, hint="speed", ULib.cmds.round }
speedCommand:defaultAccess( ULib.ACCESS_ADMIN )
speedCommand:help( "Sets the speed for target(s)." )
