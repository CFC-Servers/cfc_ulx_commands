local function ragdoll( calling_ply, should_unragdoll )
    if not should_unragdoll then
        if ulx.getExclusive( calling_ply, calling_ply ) then
            ULib.tsayError( calling_ply, ulx.getExclusive( calling_ply, calling_ply ), true )
        elseif not calling_ply:Alive() then
            ULib.tsayError( calling_ply, calling_ply:Nick() .. " is dead and cannot be ragdolled!", true )
        elseif ply.IsInPvp and ply:IsInPvp() then
            ply:ChatPrint( "You cannot ragdoll or propify yourself in PvP mode!" )
        else
            ulx.ragdollPlayer( calling_ply )
        end
    elseif calling_ply.ragdoll then -- Only if they're ragdolled...
        ulx.unragdollPlayer( calling_ply )
    end
end

local sragdoll = ulx.command( "Fun", "ulx sragdoll", ragdoll, "!sragdoll" )
sragdoll:addParam{ type = ULib.cmds.BoolArg, invisible = true }
sragdoll:defaultAccess( ULib.ACCESS_SUPERADMIN )
sragdoll:help( "sragdolls target(s)." )
sragdoll:setOpposite( "ulx unsragdoll", { _, true }, "!unsragdoll" )
