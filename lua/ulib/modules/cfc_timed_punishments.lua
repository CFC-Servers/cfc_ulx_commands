if CLIENT then return end

require "logger"
local IsValid = IsValid

TimedPunishments = {
    logger = Logger( "ULX_TimedPunishments" ),
    Data = include( "cfc_ulx_commands/timed_punishments/server/data.lua" )( logger ),
    MakeULXCommands = include( "cfc_ulx_commands/timed_punishments/ulx.lua" )( logger ),
    Punishments = {}
}

local TP = TimedPunishments
local logger = TP.logger
local Data = TP.Data
local Punishments = TP.Punishments

local function try( f, ... )
    local success, err = pcall( f )
    if not success then ErrorNoHaltWithStack( err, ... ) end
end

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

    try( function() Punishments[punishment].enable( ply ) end, ply, punishment )
end

function TP.Unpunish( steamID64, punishment )
    Data:removePunishment( punishment, steamID64 )

    local ply = player.GetBySteamID64( steamID64 )
    if not IsValid( ply ) then return end

    try( function() Punishments[punishment].disable( ply ) end, ply, punishment )
end

hook.Add( "PlayerInitialSpawn", "CFC_TimedPunishments_Check", function( ply )
    local steamID64 = ply:SteamID64()
    local punishments = Data:getPunishments( steamID64 )

    for punishment, expiration in pairs( punishments ) do
        try( function() Punishments[punishments].enable( ply ) end, ply, punishment )
    end

    ply.TimedPunishments = punishments
end )

hook.Add( "Initialize", "CFC_TimedPunishments_Init", function()
    local function checkExpirations()
        local now = os.time()

        for _, ply in ipairs( player.GetHumans() ) do
            local steamID64 = ply:SteamID64()
            local expired = {}

            for punishment, expiration in pairs( ply.TimedPunishments ) do
                if expiration > 0 and expiration <= now then
                    try( function() TP.Unpunish( steamID64, punishment ) end, punishment )
                end
            end

            if table.Count( expired ) > 0 then
                for punishment in pairs( expired ) do
                    ply.TimedPunishments[punishment] = nil
                end
            end
        end
    end

    tiemr.Create( "CFC_TimedPunishments_ExpirationChecker", PUNISH_CHECK_INTERVAL, 0, function() try( checkExpirations ) end )
end )
