if not CFCPvp then return end -- Command only exists when CFCPVP is on the server

CFCUlxCommands.pvpban = CFCUlxCommands.pvpban or {}
local cmd = CFCUlxCommands.pvpban
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "pvpban"
local HELP = "Bans the target for a certain time from entering pvp"


if SERVER then
    local function enable( ply )
        ply.isPvpBanned = true
        CFCPvp.setPlayerBuild( ply )
    end

    local function disable( ply )
        ply.isPvpBanned = false
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "banned ## from PvP"
local inverseAction = "unbanned ## from PvP"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )

local function checkPvpBan( ply )
    if ply.isPvpBanned then
        ply:ChatPrint( "You cannot enter pvp because you're currently banned from pvp." )
        return false
    end
end

hook.Add( "CFC_PvP_PlayerWillEnterPvp", "ULX_PVPBan_RestrictPvp", checkPvpBan )

