if not ACF then return end

local IsValid = IsValid

CFCUlxCommands.acfban = CFCUlxCommands.acfban or {}
local cmd = CFCUlxCommands.acfban
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "acfban"
local HELP = "Bans the target from using ACF Weapons"

if SERVER then
    local function enable( ply )
        ply.isAcfBanned = true
    end

    local function disable( ply )
        ply.isAcfBanned = false
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "banned ## from using ACF"
local inverseAction = "unbanned ## from using ACF"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )

local function checkACFBan( ply )
    if not ply.isAcfBanned then return end

    ply:ChatPrint( "You cannot use ACF while ACF banned!" )
    return false
end

local function checkOwner( object )
    if not IsValid( object ) then return end

    -- FIXME: What's the right ACF property to get the owner
    local owner = object.Owner
    if not IsValid( owner ) then return end
end

hook.Add( "ACF_FireShell", "CFC_ULXCommands_ACFBan", checkOwner )
hook.Add( "ACF_AmmoExplode", "CFC_ULXCommands_ACFBan", checkOwner )
hook.Add( "ACF_FuelExplode", "CFC_ULXCommands_ACFBan", checkOwner )

