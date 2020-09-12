--[[Credit goes to Phatso for the idea and BullyHunter for the extra support.]]

-- This resets kills and deaths caused by the cheater.
local CATEGORY_NAME = "Refund"

-- Storing table for kills on a player from a cheater.
local deaths = {}

hook.Add( "PlayerInitialSpawn", "CFC_ULXCommands_InitialSpawn", function(ply)
	deaths[ply] = {}
end)

-- Storing ply and attacker in playerKills table and reversing the deaths inflicted by the cheater.
hook.Add( "PlayerDeath", "CFC_ULXCommands_PlayerDeath", function( ply, inflictor, attacker )
    if not IsValid( attacker ) then return end
    if ply == attacker then return end

    local deathCount = deaths[ply][attacker] or 0
    deaths[ply][attacker] = deathCount + 1
end)

function removeKills( ply )
    for victim, plyDeaths in pairs( deaths ) do
        for attacker in pairs( plyDeaths ) do
            if attacker == ply then
                deaths[victim][attacker] = nil
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
		HackerMan(ply)
	end

	ulx.fancyLogAdmin( callingPlayer, "#A has reset #T 's deaths and kills", targetPlayers)

end

local refund = ulx.command( CATEGORY_NAME, "ulx refund", playerRefunds, "!refund" )
refund:addParam{ type = ULib.cmds.PlayersArg }
refund:defaultAccess( ULib.ACCESS_ADMIN )
refund:help( "Reset player kills and deaths" )
