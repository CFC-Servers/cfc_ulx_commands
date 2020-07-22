local CATEGORY_NAME = "Refund"

local playerKills = {}

hook.Add( "PlayerInitialSpawn", "OnPlayerJoin", function(ply)
	playerKills[ply] = {}
end)

hook.Add( "PlayerDisconnected", "OnPlayerDisconnect", function(ply)
	playerKills[ply] = nil

	for k, killData in pairs( playerKills )
		killData[ply] = nil
	end
end)

hook.Add( "PlayerDeath", "OnPlayerKill", function( ply, inflictor, attacker )
	local playerKillsOnVictim = playerKills[ply][attacker]

	playerKillsOnVictim = (playerKillsOnVictim or 0) + 1
end)

local function playerRefunds( callingPlayer, targetPlayers )

	for victim, killsFromPly in pairs( playerKills[targetPlayers] ) do
		local victimDeaths = victim:Frags()
		victim:SetFrags( victimDeaths - killsFromPly )
	end

	ulx.fancyLogAdmin( callingPlayer, "#A has reset #T 's deaths and kills", targetPlayers)

end

local refund = ulx.command( CATEGORY_NAME, "ulx refund", playerRefunds, "!refund" )
refund:addParam{ type = ULib.cmds.PlayersArg }
refund:defaultAccess( ULib.ACCESS_ADMIN )
refund:help( "Reset player kills and deaths" )
