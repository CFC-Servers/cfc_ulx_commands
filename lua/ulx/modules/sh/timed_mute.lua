CFCUlxCommands.timemute = CFCUlxCommands.timemute or {}
local cmd = CFCUlxCommands.timemute
local CATEGORY_NAME = "Chat"
local PUNISHMENT = "timemute"
local HELP = "Mutes a user for a set amount of time"

if SERVER then
    local function enable( ply )
        ply.gimp = 2
        ply:SetNWBool( "ulx_muted", true )
    end

    local function disable( ply )
        ply.gimp = nil
        ply:SetNWBool( "ulx_muted", false )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "muted ##"
local inverseAction = "removed ##'s time mute"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )

