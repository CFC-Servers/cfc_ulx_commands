require( "logger" )

local IsValid = IsValid
local logger = Logger( "ULX_TimedPunishments" )

TimedPunishments = {
    logger = logger,
    Data = SERVER and include( "cfc_ulx_commands/timed_punishments/server/data.lua" )( logger ),
    MakeULXCommands = include( "cfc_ulx_commands/timed_punishments/ulx.lua" )( logger ),
    Punishments = {}
}

if CLIENT then return end

util.AddNetworkString( "CFC_TimedPunishments_Punishments" )
AddCSLuaFile( "cfc_ulx_commands/timed_punishments/ulx.lua" )

local TP = TimedPunishments
local Data = TP.Data
local Punishments = TP.Punishments

function TP.Register( punishment, enable, disable )
    logger:info( "Registering new punishment type: ", punishment )

    Punishments[punishment] = {
        enable = enable,
        disable = disable
    }
end

function TP.Punish( steamID64, punishment, expiration, issuer, reason )
    Data:createPunishment( punishment, steamID64, expiration, issuer, reason )

    local ply = player.GetBySteamID64( steamID64 )
    if not IsValid( ply ) then return end

    ply.TimedPunishments = ply.TimedPunishments or {}
    ply.TimedPunishments[punishment] = expiration
    Punishments[punishment].enable( ply )

    timer.Simple( 0.1, function()
        TP.SendPunishments( ply )
    end )
end

function TP.Unpunish( steamID64, punishment )
    Data:removePunishment( punishment, steamID64 )

    local ply = player.GetBySteamID64( steamID64 )
    if not IsValid( ply ) then return end

    ply.TimedPunishments = ply.TimedPunishments or {}
    ply.TimedPunishments[punishment] = nil
    Punishments[punishment].disable( ply )

    timer.Simple( 0.1, function()
        TP.SendPunishments( ply )
    end )
end

local none = {}

function TP.SendPunishments( ply )
    local punishments = ply.TimedPunishments

    net.Start( "CFC_TimedPunishments_Punishments" )

    local count = table.Count( punishments )
    net.WriteUInt( count, 8 )

    for name, expiration in pairs( punishments ) do
        net.WriteString( name )
        net.WriteDouble( expiration )
    end

    net.Send( ply )
end

hook.Add( "PlayerInitialSpawn", "CFC_TimedPunishments_Check", function( ply )
    local steamID64 = ply:SteamID64()
    local punishments = Data:getActivePunishments( steamID64 )
    if not punishments then return end

    local listenerName = "CFC_TimedPunishments_StartPunishments_" .. steamID64

    -- Wait until the player is fully done spawning (ensures net is reliable, LocalPlayer() exists, etc)
    hook.Add( "SetupMove", listenerName, function( movePly, _, cmd )
        if movePly ~= ply then return end
        if cmd:IsForced() then return end

        hook.Remove( "SetupMove", listenerName )

        -- Double check to make sure punishments haven't changed
        punishments = Data:getActivePunishments( steamID64 )
        if not punishments then return end

        ply.TimedPunishments = punishments

        -- Run punishment enable functions
        for punishment in pairs( punishments ) do
            local basePunishment = Punishments[punishment]
            if basePunishment then
                basePunishment.enable( ply )
            else
                ErrorNoHaltWithStack( "Unknown punishment type: " .. punishment )
                punishments[punishment] = nil -- Remove unknown punishment (note that pairs() still works when removing values)
            end
        end

        TP.SendPunishments( ply )
    end )
end )

hook.Add( "CheckPassword", "CFC_TimedPunishments_Check", function( steamID64 )
    local punishments = Data:getActivePunishments( steamID64 )
    local message = hook.Run( "CFC_TimedPunishments_PunishmentNotify", steamID64, punishments )
    if not message then return end

    return false, message
end )

hook.Add( "Initialize", "CFC_TimedPunishments_Init", function()
    local function checkExpirations()
        local now = os.time()

        for _, ply in ipairs( player.GetHumans() ) do
            local steamID64 = ply:SteamID64()
            local punishments = ply.TimedPunishments or none

            for punishment, expiration in pairs( punishments ) do
                if expiration > 0 and expiration <= now then
                    ply.TimedPunishments[punishment] = nil
                    TP.Unpunish( steamID64, punishment )
                end
            end
        end
    end

    timer.Create( "CFC_TimedPunishments_ExpirationChecker", 1, 0, checkExpirations )
end )
