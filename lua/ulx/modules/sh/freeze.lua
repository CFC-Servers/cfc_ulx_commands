CATEGORY_NAME = "CFC"

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
            local canFreeze = not (ent:IsWeapon() or ent:GetUnFreezable() or ent:IsPlayer())
            local physicsObj = ent:GetPhysicsObject()
            if IsValid( physicsObj ) and canFreeze then
                physicsObj:EnableMotion( false )
                physicsObj:Sleep()
                entCount = entCount + 1
                entCounts[owner] = entCounts[owner] + 1
            end
        end
    end
    local concatVal = ""
    for nam, num in pairs( entCounts ) do
        concatVal = concatVal .. nam:Nick() .. " - " .. num .. ", "
    end
    concatVal = string.sub( concatVal, 1, #concatVal - 2 )
    timer.Simple( engine.TickInterval() +0.001 + callingPlayer:Ping()/(1000), function() callingPlayer:ChatPrint( concatVal ) end )
    ulx.fancyLogAdmin( callingPlayer, "#A froze "..entCount.." props owned by #T, in total. ", targetPlayers )
end

local freezeCMD = ulx.command( CATEGORY_NAME, "ulx freezeprops", freezeProps, "!freezeprops" )
freezeCMD:addParam{ type=ULib.cmds.PlayersArg }
freezeCMD:defaultAccess( ULib.ACCESS_ADMIN )
freezeCMD:help( "Freezes target(s) props" )