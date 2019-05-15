CATEGORY_NAME = "CFC"

local function ropeClean( calling_ply, target_plys)
    local plyCounts = {}
    for _, ply in pairs(target_plys) do
        plyCounts[ply] = 0
    end
    
    local ropes = ents.FindByClass( "keyframe_rope" )
    local ropeCount = 0
    
    for _, rope in pairs(ropes) do
        local owner = rope:CPPIGetOwner()
        
        if plyCounts[owner] ~= nil then 
            rope:Remove()
            ropeCount = ropeCount + 1
            plyCounts[owner] = plyCounts[owner] + 1
        end
    end
    
    ulx.fancyLogAdmin( calling_ply, "#A removed "..ropeCount.." ropes owned by #T", target_plys )
    
    for ply, count in pairs(plyCounts) do
        if count > 0 then
            calling_ply:ChatPrint(string.format("%s had %u ropes", ply:GetName(), count)) 
        end
    end
    
end

local ropes = ulx.command( CATEGORY_NAME, "ulx ropeclean", ropeClean, "!ropeclean" )
ropes:addParam{ type=ULib.cmds.PlayersArg }
ropes:defaultAccess( ULib.ACCESS_ADMIN )
ropes:help( "Remove target(s) ropes" )
