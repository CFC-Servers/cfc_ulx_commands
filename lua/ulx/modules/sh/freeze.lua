CATEGORY_NAME = "CFC"

local function freezeProps( callingPlayer, targetPlayers ) 
    local entities = ents.FindByClass( "prop_*" )
    local entCount = 0
    local isTarget = {}
    for _, ply in pairs( targetPlayers ) do
        isTarget[ply] = true
    end

    for _, ent in pairs( entities ) do
        if isTarget[ent:CPPIGetOwner()] then
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

local entities = ulx.command( CATEGORY_NAME, "ulx freezeprops", freezeProps, "!freezeprops" )
entities:addParam{ type=ULib.cmds.PlayersArg }
entities:defaultAccess( ULib.ACCESS_ADMIN )
entities:help( "Freezes target(s) props" )