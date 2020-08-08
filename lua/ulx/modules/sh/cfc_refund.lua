--[[Credit goes to Phatso for the idea and BullyHunter for the extra support.]]

-- This resets kills and deaths caused by the cheater.
local CATEGORY_NAME = "Refund"

-- Storing table for kills on a player from a cheater.
local kills = {}

for k, v in ipairs( player.GetAll() ) do
	kills[ v ] = {}
end

-- Storing ply and attacker in playerKills table and reversing the deaths inflicted by the cheater.
hook.Add( "PlayerDeath", "CFC_ULXCommands_PlayerDeath", function( ply, inflictor, attacker )
	kills[ ply ][ attacker ] = tonumber( 0 )
	kills[ply][attacker] = kills[ ply ][ attacker] + 1
end)
	
function HackerMan( ply )
	for k, v in pairs( kills ) do
		for x, p in pairs(v) do
			if ( x == ply ) then
				kills[ k ][ x ] = nil
			end
		end
	end
end

-- Still keep track of it after disconnect. Forgot to add do.
hook.Add( "PlayerDisconnected", "CFC_ULXCommands_KeepingTrackofDeathTable", function(ply)
	HackerMan(ply)
end)

-- Remove frags caused by the cheater.
local function playerRefunds( callingPlayer, targetPlayers )

	for _, ply in pairs( targetPlayers ) do
    	HackerMan( ply )
	end

	ulx.fancyLogAdmin( callingPlayer, "#A has reset #T 's deaths and kills", targetPlayers)

end

local refund = ulx.command( CATEGORY_NAME, "ulx refund", playerRefunds, "!refund" )
refund:addParam{ type = ULib.cmds.PlayersArg }
refund:defaultAccess( ULib.ACCESS_ADMIN )
refund:help( "Reset player kills and deaths" )
