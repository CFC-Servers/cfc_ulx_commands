CATEGORY_NAME = "Cleanup"

local function ropeClean( callingPlayer, targetPlayers )
    local plyCounts = {}
    for _, ply in pairs( targetPlayers ) do
        plyCounts[ply] = 0
    end
    
    local ropes = ents.FindByClass( "keyframe_rope" )
    local ropeCount = 0
    
    for _, rope in pairs( ropes ) do
        local owner = rope:CPPIGetOwner()
        
        if plyCounts[owner] ~= nil then 
            rope:Remove()
            ropeCount = ropeCount + 1
            plyCounts[owner] = plyCounts[owner] + 1
        end
    end

    ulx.fancyLogAdmin( callingPlayer, "#A removed "..ropeCount.." ropes owned by #T", targetPlayers )

    for ply, count in pairs( plyCounts ) do
        if count > 0 then
            callingPlayer:ChatPrint( string.format( "%s owned %u ropes", ply:GetName(), count ) ) 
        end
    end
end

local ropes = ulx.command( CATEGORY_NAME, "ulx ropeclean", ropeClean, "!ropeclean" )
ropes:addParam{ type=ULib.cmds.PlayersArg }
ropes:defaultAccess( ULib.ACCESS_ADMIN )
ropes:help( "Remove target(s) ropes" )


local function cleanupPlayerEnts( callingPlayer, targetPlayer )
    local count = 0
    for _, ent in ipairs( ents.GetAll() ) do
        local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
        if owner == targetPlayer and not ent:IsWeapon() then
            ent:Remove()
            count = count + 1
        end
    end

    ulx.fancyLogAdmin( callingPlayer,  "#A removed "..count.." entities owned by #T", targetPlayer )

end

local cleanup = ulx.command( CATEGORY_NAME, "ulx cleanup", cleanupPlayerEnts, "!cleanup" )
cleanup:addParam{ type=ULib.cmds.PlayerArg }
cleanup:defaultAccess( ULib.ACCESS_ADMIN )
cleanup:help( "Remove targets entities" )
