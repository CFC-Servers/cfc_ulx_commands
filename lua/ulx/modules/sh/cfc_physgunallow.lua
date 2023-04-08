CFCUlxCommands.physgunallow = CFCUlxCommands.physgunallow or {}
local cmd = CFCUlxCommands.physgunallow

hook.Add( "PhysgunPickup", "ULXphysgunallowPlayer", function( _, ent )
    if not ent:IsPlayer() then return end
    if ent:GetNWBool( "ULXphysgunallow", false ) then
        ent:SetMoveType( MOVETYPE_NONE )
        return true
    end
end, HOOK_HIGH )

function cmd.physgunallow( callingPly, targetPlys, shouldUndo )
    for _, ply in ipairs( targetPlys ) do
        ply:SetNWBool( "ULXphysgunallow", not shouldUndo )
    end

    if shouldUndo then
        ulx.fancyLogAdmin( callingPly, "#A physgun disallowed #T", targetPlys )
    else
        ulx.fancyLogAdmin( callingPly, "#A physgun allowed #T", targetPlys )
    end
end

local physgunallow = ulx.command( "Fun", "ulx physgunallow", cmd.physgunallow, "!physgunallow" )
physgunallow:addParam( { type = ULib.cmds.PlayersArg, ULib.cmds.optional } )
physgunallow:addParam( { type = ULib.cmds.BoolArg, invisible = true } )
physgunallow:defaultAccess( ULib.ACCESS_ADMIN )
physgunallow:help( "Allows everyone to physgun the target(s)." )
physgunallow:setOpposite( "ulx unphysgunallow", { _, _, true }, "!unphysgunallow" )
