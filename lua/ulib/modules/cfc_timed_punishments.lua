require "logger"
AddCSLuaFile( "cfc_ulx_commands/timed_punishments/ulx.lua" )

local IsValid = IsValid
local logger = Logger( "ULX_TimedPunishments" )

TimedPunishments = {
    logger = logger,
    Data = SERVER and include( "cfc_ulx_commands/timed_punishments/server/data.lua" )( logger ),
    MakeULXCommands = include( "cfc_ulx_commands/timed_punishments/ulx.lua" )( logger ),
    Punishments = {}
}

if CLIENT then return end

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

    Punishments[punishment].enable( ply )
end

function TP.Unpunish( steamID64, punishment )
    Data:removePunishment( punishment, steamID64 )

    local ply = player.GetBySteamID64( steamID64 )
    if not IsValid( ply ) then return end

    Punishments[punishment].disable( ply )
end

local none = {}

hook.Add( "PlayerInitialSpawn", "CFC_TimedPunishments_Check", function( ply )
    local steamID64 = ply:SteamID64()
    local punishments = Data:getPunishments( steamID64 )

    for punishment, expiration in pairs( punishments or none ) do
        Punishments[punishment].enable( ply )
    end

    ply.TimedPunishments = punishments
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
