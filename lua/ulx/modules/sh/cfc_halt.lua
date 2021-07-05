CFCUlxCommands.halt = CFCUlxCommands.halt or {}
local cmd = CFCUlxCommands.halt

CATEGORY_NAME = "Cleanup"

function cmd.halt( callingPlayer, targetPlayers )
    local entities = ents.GetAll()
    local entCount = 0
    local entCounts = {}
    for _, ply in ipairs( targetPlayers ) do
        entCounts[ply] = 0
    end

    for _, ent in ipairs( entities ) do
        local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
        if owner and entCounts[owner] then
            if ent:GetClass() == "gmod_wire_expression2" then
                ent:PCallHook("destruct")
                ent:ResetContext()
                ent:PCallHook("construct")
                ent:Error( ent.name .. ": Halted by ULX" )
            end

            if ent:GetClass() == "starfall_processor" then
                ent:Error( SF.MakeError( ent.name .. ": Halted by ULX", 1, true, true) )
            end

            local canFreeze = not ( ent:IsWeapon() or ent:GetUnFreezable() or ent:IsPlayer() )
            local physicsObj = ent:GetPhysicsObject()
            if IsValid( physicsObj ) and canFreeze then
                physicsObj:EnableMotion( false )
                physicsObj:Sleep()
                entCount = entCount + 1
                entCounts[owner] = entCounts[owner] + 1
            end
        end
    end
    ulx.fancyLogAdmin( callingPlayer, "#A halted " .. entCount .. " props owned by #T", targetPlayers )
    ulx.jail( callingPlayer, targetPlayers, 0 )

    if #targetPlayers <= 1 then return end

    for ply, num in pairs( entCounts ) do
        ULib.tsay( ply, ply:Nick() .. " owned " .. num .. " props.", true )
    end
end

local freezeCMD = ulx.command( CATEGORY_NAME, "ulx halt", cmd.halt, "!halt" )
freezeCMD:addParam{ type = ULib.cmds.PlayersArg }
freezeCMD:defaultAccess( ULib.ACCESS_ADMIN )
freezeCMD:help( "Halts target( s ) props, chips and jails the target." )
