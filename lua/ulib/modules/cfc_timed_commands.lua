if CLIENT then return end -- ULX has forced my hand here, server modules run after everything so im forced to use shared
CFCTimedCommands = {}
CFCTimedCommands.types = {}

local punishedPlayers = {}

-- CONSTANTS
local PUNISH_CHECK_INTERVAL = 1
local INIT_WAIT_TIME = 1

local punishmentsInitialized = false

local PUNISH_QUERIES = {
    create_punishment   = "INSERT INTO %s(steam_id, expiration, reason) VALUES('%s', %d, '%s')",
    create_table = "CREATE TABLE %s(steam_id TEXT NOT NULL UNIQUE, expiration BIGINT, reason TEXT)",
    delete_punishment  = "DELETE FROM %s WHERE steam_id='%s'",
    retrieve_punishment = "SELECT %s FROM %s WHERE steam_id='%s'",
    update_punishment   = "UPDATE %s SET expiration=%d, reason='%s' WHERE steam_id='%s'"
}

-- HELPERS

local function isValidPlayer( ply )
    local playerIsValid = IsValid( ply ) and ply:IsPlayer()

    return playerIsValid
end


local function punishPrint( msg )
    print( "[CFC Timed Punishments] " .. msg )
end

local function databasePunishPrint( action, succeeded, ply )
    local result = ( succeeded == false ) and "FAILED" or "SUCCEEDED"

    if isValidPlayer( ply ) then
        punishPrint( action .. " for '" .. ply:Nick() .. "' ( " .. ply:SteamID() .. " ) in Database " .. result )
    else
        punishPrint( action .. " " .. result )
    end
end

local function catchTable( method )
    local tbl
    if istable( method ) then
        tbl = method
    else
        tbl = CFCTimedCommands.types[method]
    end
    return tbl
end

local function getExpirationTime( minutesToPunish )
    local timeInSeconds = minutesToPunish * 60
    local expirationTime = os.time() + timeInSeconds

    return expirationTime
end

-- END HELPERS

-- SQL STUFF

local function SQLOperation( action, query, ply, isRead )
    -- Use QueryValue if it's a read operation, otherwise just Query
    local result = isRead and sql.QueryValue( query ) or sql.Query( query )

    -- False is failure in both cases, but nil is only a fail for read operations
    local failed = ( result == false ) or ( isRead and result == nil )
    local succeeded = not failed

    databasePunishPrint( action, succeeded, ply )

    return result
end

local function SQLAction( action, query, ply )
    return SQLOperation( action, query, ply, false )
end

local function SQLRead( action, query, ply )
    return SQLOperation( action, query, ply, true )
end

local function updatePlayerPunishmentInDatabase( ply, expirationTime, reason, tbl )
    local query = string.format(
        PUNISH_QUERIES.update_punishment,
        tbl.name,
        expirationTime,
        sql.SQLStr( reason, true ),
        ply:SteamID()
    )

    return SQLAction( "Updating " .. tbl.name, query, ply )
end

local function createPlayerPunishmentInDatabase( ply, expirationTime, reason, tbl )
    local query = string.format(
        PUNISH_QUERIES.create_punishment,
        tbl.name,
        ply:SteamID(),
        expirationTime,
        sql.SQLStr( reason, true )
    )

    return SQLAction( "Creating " .. tbl.name, query, ply )
end

local function removePunishmentFromDatabase( ply, name )
    local query = string.format( PUNISH_QUERIES.delete_punishment, name, ply:SteamID() )

    return SQLAction( "Deleting expired " .. name, query, ply )
end

local function getColumnFromDatabase( ply, punishType, column )
    local query = string.format( PUNISH_QUERIES.retrieve_punishment, column, punishType, ply:SteamID() )

    return SQLRead( "Retrieving " .. punishType .. " : " .. column, query, ply )
end

local function getPunishExpirationFromDatabase( ply, punishType )
    local expiration = tonumber( getColumnFromDatabase( ply, punishType, "expiration" ) )

    return expiration
end

local function getPunishReasonFromDatabase( ply, punishType )
    local reason = getColumnFromDatabase( ply, punishType, "reason" )

    return reason
end

-- END OF SQL STUFF

-- FUNCTIONS

local function punishmentIsExpired( expirationTime )
    return os.time() > expirationTime
end

local function getMinutesRemainingInPunishment( expirationTime )
    local secondsLeftInPunishment = expirationTime - os.time()
    local minutesLeftInPunishment = math.ceil( secondsLeftInPunishment / 60 )

    return minutesLeftInPunishment
end

local function punishPlayerUntil( ply, expirationTime, reason, method, fromDb )
    if not isValidPlayer( ply ) then return end

    local tbl = catchTable( method )
    if not tbl.check( ply ) then tbl.punish( ply ) end

    if getPunishExpirationFromDatabase( ply, method.name ) then
        updatePlayerPunishmentInDatabase( ply, expirationTime, reason, tbl )
    else
        createPlayerPunishmentInDatabase( ply, expirationTime, reason, tbl )
    end

    local minutesLeftInPunishment = getMinutesRemainingInPunishment( expirationTime )

    punishPrint( "Punishing " .. ply:Nick() .. "' ( " .. ply:SteamID() .. " ) with " .. tbl.name .. " for " .. minutesLeftInPunishment .. " minutes!" )

    local message = "You have a " .. tbl.pretty .. " that expires in " .. tostring( minutesLeftInPunishment ) .. " minutes."

    if reason then message = message .. " Reason: " .. reason end
    ply:ChatPrint( message )

    punishedPlayers[tbl.name][ply] = expirationTime
end

local function getPlayerPunishmentsFromDatabase( ply, punishType )
    if not isValidPlayer( ply ) then return end

    -- Player is not in database
    local expiration = getPunishExpirationFromDatabase( ply, punishType )
    if expiration == nil then
        punishedPlayers[punishType][ply] = nil
        return
    end

    if punishmentIsExpired( expiration ) then
        removePunishmentFromDatabase( ply, punishType.name )
        CFCTimedCommands.types[punishType].unpunish( ply )
        return
    end

    local reason = getPunishReasonFromDatabase( ply, punishType )

    punishPlayerUntil( ply, expiration, reason, punishType, true )
end

local function initializePunishedPlayers()
    for _, ply in pairs( player.GetHumans() ) do
        for punishType in pairs( CFCTimedCommands.types ) do
            getPlayerPunishmentsFromDatabase( ply, punishType )
        end
    end
end

-- END FUNCTIONS

-- GLOBAL FUNCTIONS

function CFCTimedCommands.punishPlayer( ply, minutes, reason ,tbl )
    local expirationTime = getExpirationTime( minutes )

    punishPlayerUntil( ply, expirationTime, reason, tbl, false )
end

function CFCTimedCommands.unpunishPlayer( ply, method )
    local tbl = catchTable( method )
    removePunishmentFromDatabase( ply, tbl.name )

    if tbl.check( ply ) then tbl.unpunish( ply ) end
    punishedPlayers[tbl.name][ply] = nil
end

function CFCTimedCommands.createTable( tableName )
    punishedPlayers[tableName] = {}
    if sql.TableExists( tableName ) then return end

    local query = string.format( PUNISH_QUERIES.create_table, tableName )

    return SQLAction( "Creating table " .. tableName, query )
end

-- END GLOBAL FUNCTIONS

-- HOOKS

local function waitForPlayerToInitialize( ply )
    -- Timer because the steamId isn't available yet
    timer.Simple( INIT_WAIT_TIME, function()
        for punishType in pairs( CFCTimedCommands.types ) do
            getPlayerPunishmentsFromDatabase( ply, punishType )
        end
    end )
end
hook.Add( "PlayerInitialSpawn", "CFC_PunishCheck", waitForPlayerToInitialize )

local function removeDisconnectedPlayer( target )
    for punishType in pairs( CFCTimedCommands.types ) do
        for ply in pairs( punishedPlayers[punishType] ) do
            if ply == target then
                punishedPlayers[punishType][ply] = nil
            end
        end
    end
end

hook.Add( "PlayerDisconnected", "CFC_PunishRemove", removeDisconnectedPlayer )

local function initializePunishments()
    punishPrint( "Initializing Punishments!" )

    initializePunishedPlayers()

    punishmentsInitialized = true
end

local function updatePunishments()
    if not punishmentsInitialized then initializePunishments() end

    local typeTable = CFCTimedCommands.types

    for punishType in pairs( typeTable ) do
        for ply, expiration in pairs( punishedPlayers[punishType] ) do
            if isValidPlayer( ply ) then
                if punishmentIsExpired( expiration ) then
                    removePunishmentFromDatabase( ply, typeTable[punishType].name )
                    typeTable[punishType].unpunish( ply )
                    punishedPlayers[punishType][ply] = nil

                    local message = "Your " .. typeTable[punishType].pretty .. " has expired."
                    ply:ChatPrint( message )
                end
            else
                removeDisconnectedPlayer( ply )
            end
        end
    end
end

hook.Remove( "Initialize", "CFC_TimedPunishmentsInitialize" )
hook.Add( "Initialize", "CFC_TimedPunishmentsInitialize", function()
    initializePunishments()

    timer.Create( "CFC_PunishTimer", PUNISH_CHECK_INTERVAL, 0, updatePunishments )
end )
