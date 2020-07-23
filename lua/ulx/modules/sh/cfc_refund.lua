-- This resets kills and deaths caused by the cheater.
local CATEGORY_NAME = "Refund"

-- Storing table for kills on a player from a cheater.
local playerKills = {}

-- Initialize the table when the cheater spawns.
hook.Add( "PlayerInitialSpawn", "CFC_ULXCommands_CreateDeathTable", function(ply)
	playerKills[ply] = {}
end)

-- Still keep track of it after disconnect.
hook.Add( "PlayerDisconnected", "CFC_ULXCommands_KeepingTrackofDeathTable", function(ply)
	playerKills[ply] = nil

	for _, killData in pairs( playerKills )
		killData[ply] = nil
	end
end)

-- Storing ply and attacker in playerKills table and reversing the deaths inflicted by the cheater.
hook.Add( "PlayerDeath", "CFC_ULXCommands_PlayerDeath", function( ply, inflictor, attacker )
	local playerKillsOnVictim = playerKills[attacker][ply] or 0
	playerKills[attacker][ply] = playerKillsOnVictim + 1
end)

-- Remove frags caused by the cheater.
local function playerRefunds( callingPlayer, targetPlayers )

	for victim, killsFromPly in pairs( playerKills[targetPlayers] ) do
		local victimDeaths = victim:Frags()
		victim:SetFrags( victimDeaths - killsFromPly )
	end

	ulx.fancyLogAdmin( callingPlayer, "#A has reset #T 's deaths and kills", targetPlayers)

end

local refund = ulx.command( CATEGORY_NAME, "ulx refund", playerRefunds, "!refund" )
refund:addParam{ type = ULib.cmds.PlayerArg }
refund:defaultAccess( ULib.ACCESS_ADMIN )
refund:help( "Reset player kills and deaths" )
