CATEGORY_NAME = "CFC"

do
    local function freezeProps( callingPlayer, targetPlayers ) 
        local entits = ents.FindByClass( "prop_*" )
        local entCount = 0
        
        for _, ent in pairs( entits ) do
            if table.HasValue( targetPlayers, ent:CPPIGetOwner() ) then 
                local physicsObj = ent:GetPhysicsObject()
                if IsValid( physicsObj ) then
                    physicsObj:EnableMotion( false )
                    physicsObj:Sleep()
                    entCount = entCount + 1
                end
            end
        end

        ulx.fancyLogAdmin( callingPlayer, "#A froze all "..entCount.." props owned by #T", targetPlayers )
    end

    local entits = ulx.command( CATEGORY_NAME, "ulx freezeprops", freezeProps, "!freezeprops" )
    entits:addParam{ type=ULib.cmds.PlayersArg }
    entits:defaultAccess( ULib.ACCESS_ADMIN )
    entits:help( "Freezes target(s) props" )
end

do
    local function freezeSelfProps( callingPlayer ) 
        local entits = ents.FindByClass( "prop_*" )
        local entCount = 0
        
        for _, ent in pairs( entits ) do
            if ent:CPPIGetOwner() == callingPlayer then
                local physicsObj = ent:GetPhysicsObject()
                if IsValid( physicsObj ) then
                    physicsObj:EnableMotion( false )
                    physicsObj:Sleep()
                    entCount = entCount + 1
                end
            end
        end

        ulx.fancyLogAdmin( callingPlayer, "#A froze all "..entCount.." of their props." )
    end

    local entits = ulx.command( CATEGORY_NAME, "ulx freezeself", freezeSelfProps, "!freezeself" )
    entits:defaultAccess( ULib.ACCESS_ADMIN )
    entits:help( "Freezes Caller's props" )
end