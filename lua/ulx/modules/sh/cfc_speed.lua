CFCUlxCommands.speed = CFCUlxCommands.speed or {}
local cmd = CFCUlxCommands.speed

local CATEGORY_NAME = "Fun"
                    
function cmd.speedPlayers( callingPlayer, targetPlayers, amount )
    for _, ply in pairs( targetPlayers ) do
        local inPvp = hook.Run( "CFC_ULXCommands_CanApplySpeedModifier", ply )
        -- false = in pvp
        if inPvp ~= false then
            ply:SetWalkSpeed( 2 * amount )
            ply:SetRunSpeed( 4 * amount )
        end
    end

    ulx.fancyLogAdmin( callingPlayer, "#A set the speed for #T to " .. amount .. "% speed", targetPlayers )
end

local speedCommand = ulx.command( CATEGORY_NAME, "ulx speed", cmd.speedPlayers, "!speed" )
speedCommand:addParam{ type = ULib.cmds.PlayersArg }
speedCommand:addParam{ type=ULib.cmds.NumArg, min=1, max=1000, default=100, hint="speed %", ULib.cmds.round, ULib.cmds.optional }
speedCommand:defaultAccess( ULib.ACCESS_ADMIN )
speedCommand:help( "Sets the speed percentage for target(s) default = 100." )
