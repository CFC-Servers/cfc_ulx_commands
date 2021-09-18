if engine.ActiveGamemode() == "terrortown" then return end

CFCUlxCommands.removeShadows = CFCUlxCommands.removeShadows or {}
local cmd = CFCUlxCommands.removeShadows

CATEGORY_NAME = "Cleanup"

function cmd.removeShadows( callingPlayer, targetPlayers, removeShadows )
    local entities = ents.GetAll()
    local entCount = 0
    local entCounts = {}
    for _, ply in ipairs( targetPlayers ) do
        entCounts[ply] = 0
    end

    for _, ent in ipairs( entities ) do
        local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
        if owner and entCounts[owner] then
            local canShadow = not ( ent:IsWeapon() or ent:IsPlayer() )
            if IsValid( ent ) and canShadow then
                if not removeShadows then
                    ent:DrawShadow( false )
                else
                    ent:DrawShadow( true )
                end
                entCount = entCount + 1
                entCounts[owner] = entCounts[owner] + 1
            end
        end
    end

    if not removeShadows then
        ulx.fancyLogAdmin( callingPlayer, "#A removed shadows from " .. entCount .. " props owned by #T", targetPlayers )
    else
        ulx.fancyLogAdmin( callingPlayer, "#A added shadows to " .. entCount .. " props owned by #T", targetPlayers )
    end

    if #targetPlayers <= 1 then return end

    for ply, num in pairs( entCounts ) do
        ULib.tsay( ply, ply:Nick() .. " owned " .. num .. " props.", true )
    end
end

local removeShadows = ulx.command( CATEGORY_NAME, "ulx removeshadows", cmd.removeShadows, "!removeshadows" )
removeShadows:addParam{ type = ULib.cmds.PlayersArg }
removeShadows:addParam{ type = ULib.cmds.BoolArg, invisible = true }
removeShadows:defaultAccess( ULib.ACCESS_ADMIN )
removeShadows:help( "Removes shadows from target( s ) props" )
removeShadows:setOpposite( "ulx addshadows", { _, _, true }, "!addshadows" )
