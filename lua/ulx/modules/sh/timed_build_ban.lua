if not CFCPvp then return end -- Command only exists when CFCPVP is on the server

CFCUlxCommands.buildban = CFCUlxCommands.buildban or {}
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "buildban"
local HELP = "Bans the target for a certain time from entering build"


if SERVER then
    local function enable( ply )
        ply.isBuildBanned = true
        if ply:IsInBuild() then CFCPvp.setPlayerBuild( ply ) end
    end

    local function disable( ply )
        ply.isBuildBanned = nil
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "banned ## from Build"
local inverseAction = "unbanned ## from Build"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )

local function checkBuildBan( ply )
    if ply.isBuildBanned then
        ply:ChatPrint( "You cannot enter build because you're currently banned from build." )
        return false
    end
end

hook.Add( "CFC_PvP_PlayerWillExitPvp", "ULX_BuildBan_RestrictBuild", checkBuildBan )

