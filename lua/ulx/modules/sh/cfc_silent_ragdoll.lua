local function ragdoll( calling_ply, target_plys, should_unragdoll )
	local affected_plys = {}
	for i = 1, #target_plys do
		local v = target_plys[i]

		if not should_unragdoll then
			if ulx.getExclusive( v, calling_ply ) then
				ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
			elseif not v:Alive() then
				ULib.tsayError( calling_ply, v:Nick() .. " is dead and cannot be ragdolled!", true )
			else
				ulx.ragdollPlayer( v )
				table.insert( affected_plys, v )
			end
		elseif v.ragdoll then -- Only if they're ragdolled...
			ulx.unragdollPlayer( v )
			table.insert( affected_plys, v )
		end
	end
end

local sragdoll = ulx.command( "Fun", "ulx sragdoll", ragdoll, "!sragdoll" )
sragdoll:addParam{ type = ULib.cmds.PlayersArg }
sragdoll:addParam{ type = ULib.cmds.BoolArg, invisible = true }
sragdoll:defaultAccess( ULib.ACCESS_SUPERADMIN )
sragdoll:help( "sragdolls target(s)." )
sragdoll:setOpposite( "ulx unsragdoll", { _, _, true }, "!unsragdoll" )
