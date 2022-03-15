CFCUlxCommands.timedDarkRP = CFCUlxCommands.timedDarkRP or {}
local cmd = CFCUlxCommands.timedDarkRP
local CATEGORY_NAME = "Fun"
local PUNISHMENT = "timeddarkrp"
local HELP = "Prevents the target(s) from spawning anything at all"

if SERVER then
    local function enable( ply )
        ply:DisallowNoclip( true )
        ply:DisallowSpawning( true )
        ply:DisallowVehicles( true )

        ply:StripWeapons()
        cleanup.CC_Cleanup( ply, "gmod_cleanup", {} )
    end

    local function disable( ply )
        ply:DisallowNoclip( false )
        ply:DisallowSpawning( false )
        ply:DisallowVehicles( false )
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "forced ## into DarkRP Mode"
local inverseAction = "removed ## from DarkRP Mode"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
