CATEGORY_NAME = "Cleanup"

local function freezeProps( callingPlayer, targetPlayers ) 
    local entities = ents.GetAll()
    local entCount = 0
    local entCounts = {}
    for _, ply in pairs( targetPlayers ) do
        entCounts[ply] = 0
    end

    for _, ent in pairs( entities ) do
        local owner = ent:CPPIGetOwner()
        if entCounts[owner] then
            local cantFreezeIf = ent:IsWeapon() or ent:GetUnFreezable() or ent:IsPlayer()
            local canFreeze = not cantFreezeIf
            local physicsObj = ent:GetPhysicsObject()
            if IsValid( physicsObj ) and canFreeze then
                physicsObj:EnableMotion( false )
                physicsObj:Sleep()
                entCount = entCount + 1
                entCounts[owner] = entCounts[owner] + 1
            end
        end
    end
    ulx.fancyLogAdmin( callingPlayer, "#A froze "..entCount.." props owned by #T", targetPlayers )
    for ply, num in pairs( entCounts ) do
        ULib.tsay( ply, ply:Nick() .. " owned " .. num .. " props.", true )
    end
end

local freezeCMD = ulx.command( CATEGORY_NAME, "ulx freezeprops", freezeProps, "!freezeprops" )
freezeCMD:addParam{ type=ULib.cmds.PlayersArg }
freezeCMD:defaultAccess( ULib.ACCESS_ADMIN )
freezeCMD:help( "Freezes target(s) props" )
