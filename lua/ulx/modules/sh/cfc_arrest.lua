CFCUlxCommands.arrest = CFCUlxCommands.arrest or {}
local cmd = CFCUlxCommands.arrest

CATEGORY_NAME = "Cleanup"

local function isTargetPlayer( ply, targetPlayers )
    for _, p in pairs( targetPlayers ) do
        if p == ply then
            return true
        end
    end

    return false
end

function cmd.arrest( callingPlayer, targetPlayers )
    local entities = ents.GetAll()
    local entCount = 0
    local entCounts = {}

    for _, ent in ipairs( entities ) do
        local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
        if owner and isTargetPlayer(owner) then
            if ent:GetClass() == "gmod_wire_expression2" then
                ent:PCallHook( "destruct" )
                ent:ResetContext()
                ent:PCallHook( "construct" )
                ent:Error( ent.name .. ": Halted by ULX" )
            end

            if ent:GetClass() == "starfall_processor" then
                ent:Error( SF.MakeError( ent.name .. ": Halted by ULX", 1, true, true ) )
            end

            local canFreeze = not ( ent:IsWeapon() or ent:GetUnFreezable() or ent:IsPlayer() )
            local physicsObj = ent:GetPhysicsObject()
            if IsValid( physicsObj ) and canFreeze then
                physicsObj:EnableMotion( false )
                physicsObj:Sleep()
                entCount = entCount + 1
                entCounts[owner] = ( entCounts[owner] or 0 ) + 1
            end
        end
    end
    ulx.fancyLogAdmin( callingPlayer, "#A froze " .. entCount .. " props owned by #T", targetPlayers )
    ulx.jail( callingPlayer, targetPlayers, 0 )

    if #targetPlayers <= 1 then return end

    for ply, num in pairs( entCounts ) do
        ULib.tsay( ply, ply:Nick() .. " owned " .. num .. " props.", true )
    end
end

local freezeCMD = ulx.command( CATEGORY_NAME, "ulx arrest", cmd.arrest, "!arrest" )
freezeCMD:addParam{ type = ULib.cmds.PlayersArg }
freezeCMD:defaultAccess( ULib.ACCESS_ADMIN )
freezeCMD:help( "Arrests target( s ) props, chips and jails the target." )
