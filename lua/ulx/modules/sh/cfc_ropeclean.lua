CFCUlxCommands.ropeClean = CFCUlxCommands.ropeClean or {}
local cmd = CFCUlxCommands.ropeClean

CATEGORY_NAME = "Cleanup"

function cmd.ropeClean( callingPlayer, targetPlayers )
    local plyCounts = {}
    for _, ply in ipairs( targetPlayers ) do
        plyCounts[ply] = 0
    end

    local ropes = ents.FindByClass( "keyframe_rope" )
    local ropeCount = 0

    for _, rope in ipairs( ropes ) do
        local owner = rope:CPPIGetOwner()

        if plyCounts[owner] ~= nil then
            rope:Remove()
            ropeCount = ropeCount + 1
            plyCounts[owner] = plyCounts[owner] + 1
        end
    end

    ulx.fancyLogAdmin( callingPlayer, "#A removed " .. ropeCount .. " ropes owned by #T", targetPlayers )

    for ply, count in pairs( plyCounts ) do
        if count > 0 then
            callingPlayer:ChatPrint( string.format( "%s owned %u ropes", ply:GetName(), count ) )
        end
    end
end

local ropes = ulx.command( CATEGORY_NAME, "ulx ropeclean", cmd.ropeClean, "!ropeclean" )
ropes:addParam{ type = ULib.cmds.PlayersArg }
ropes:defaultAccess( ULib.ACCESS_ADMIN )
ropes:help( "Remove target( s ) ropes" )
