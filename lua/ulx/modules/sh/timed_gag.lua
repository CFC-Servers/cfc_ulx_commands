CFCUlxCommands.timegag = CFCUlxCommands.timegag or {}
local cmd = CFCUlxCommands.timegag
local CATEGORY_NAME = "Chat"
local PUNISHMENT = "timegag"
local HELP = "Gags a user for a set amount of time"

if SERVER then
    local function enable( ply )
        ply.ulx_gagged = true
        ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
    end

    local function disable( ply )
        ply.ulx_gagged = false
        ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "gagged ##"
local inverseAction = "removed ##'s time gag"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )

