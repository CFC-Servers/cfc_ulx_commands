CFCUlxCommands.forceBuddy = CFCUlxCommands.forceBuddy or {}
local cmd = CFCUlxCommands.forceBuddy
local CATEGORY_NAME = "Utility"

local tonumber = tonumber
local og_setbuddy

if SERVER then
    local concommands = concommand.GetTable()
    concommands._fpp_setbuddy = concommands._fpp_setbuddy or concommands.fpp_setbuddy
    og_setbuddy = concommands._fpp_setbuddy

    concommands.fpp_setbuddy = function( ply, command, args )
        local forcedBuddies = ply.ForcedBuddies
        if not forcedBuddies then return og_setbuddy( ply, command, args ) end

        local target = tonumber( args[1] ) and Player( tonumber( args[1] ) )
        if IsValid( target ) and forcedBuddies[target:SteamID64()] then return end

        return og_setbuddy( ply, command, args )
    end
end

function cmd.forceBuddy( callingPlayer, targetPlayers, reason )
    -- Doesn't work from console
    if not IsValid( callingPlayer ) then return end

    local callingSteamID = callingPlayer:SteamID64()
    local callingID = callingPlayer:UserID()

    for _, ply in ipairs( targetPlayers ) do
        ply.ForcedBuddies = ply.ForcedBuddies or {}
        ply.ForcedBuddies[callingPlayer] = true

        og_setbuddy( ply, "fpp_setbuddy", { callingID, 1, 1, 1, 1, 1, 1 } )
    end

    timer.Simple( 10 * 60, function()
        for _, ply in ipairs( targetPlayers ) do
            if IsValid( ply ) and ply.ForcedBuddies then
                -- TODO: If a player already has some buddy perms, we should set them back, not override them
                ply.ForcedBuddies[callingSteamID] = nil
                og_setbuddy( ply, "fpp_setbuddy", { callingID, 0, 0, 0, 0, 0, 0 } )
            end
        end
    end )

    ulx.fancyLogAdmin( callingPlayer, "#A forced #T to grant them prop protection access for 10 minutes (#s)", targetPlayers, reason )
end

local forceBuddyCommand = ulx.command( CATEGORY_NAME, "ulx forcebuddy", cmd.forceBuddy, "!forcebuddy" )
forceBuddyCommand:addParam{ type = ULib.cmds.PlayersArg }
forceBuddyCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason" }
forceBuddyCommand:defaultAccess( ULib.ACCESS_ADMIN )
forceBuddyCommand:help( "Force the target(s) to add you as a FPP buddy" )
