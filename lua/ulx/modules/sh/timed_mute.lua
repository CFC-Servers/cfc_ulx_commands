CFCUlxCommands.tMute = CFCUlxCommands.tMute or {}
local cmd = CFCUlxCommands.tMute

-- Constants
local ULX_CATEGORY_NAME = "Chat"
local MUTES_SQL_TABLE = "cfc_timed_mutes"
local INIT_WAIT_TIME = 1
local MUTE_CHECK_INTERVAL = 1

local MutegedPlayers = {}

local mutesInitialized = false

local MUTE_QUERIES = {
    create_mute   = "INSERT INTO %s(steam_id, expiration, reason) VALUES('%s', %d, '%s')",
    create_table = "CREATE TABLE %s(steam_id TEXT NOT NULL UNIQUE, expiration BIGINT, reason TEXT)",
    delete_mute   = "DELETE FROM %s WHERE steam_id='%s'",
    retrieve_mute = "SELECT %s FROM %s WHERE steam_id='%s'",
    update_mute   = "UPDATE %s SET expiration=%d, reason='%s' WHERE steam_id='%s'"
}


-- HELPERS --

local function isValidPlayer( ply )
    local playerIsValid = IsValid( ply ) and ply:IsPlayer()

    return playerIsValid
end

local function mutePrint( msg )
    print( "[CFC Timed Mute] " .. msg )
end

local function databaseMutePrint( action, succeeded, ply )
    local result = ( succeeded == false ) and "FAILED" or "SUCCEEDED"

    if isValidPlayer( ply ) then
        mutePrint( action .. " for '" .. ply:Nick() .. "' ( " .. ply:SteamID() .. " ) in Database " .. result )
    else
        mutePrint( action .. " " .. result )
    end
end

-- END HELPERS --



-- DATABASE OPERATIONS --

local function SQLOperation( action, query, ply, isRead )
    -- Use QueryValue if it's a read operation, otherwise just Query
    local result = isRead and sql.QueryValue( query ) or sql.Query( query )

    -- False is failure in both cases, but nil is only a fail for read operations
    local failed = ( result == false ) or ( isRead and result == nil )
    local succeeded = not failed

    databaseMutePrint( action, succeeded, ply )

    return result
end

local function SQLAction( action, query, ply )
    return SQLOperation( action, query, ply, false )
end

local function SQLRead( action, query, ply )
    return SQLOperation( action, query, ply, true )
end

local function createTable()
    if sql.TableExists( MUTES_SQL_TABLE ) then return mutePrint( MUTES_SQL_TABLE .. " already exists!" ) end

    local query = string.format( MUTE_QUERIES.create_table, MUTES_SQL_TABLE )

    return SQLAction( "Creating table " .. MUTES_SQL_TABLE, query )
end

local function updatePlayerMuteInDatabase( ply, expirationTime, reason )
    local query = string.format(
        MUTE_QUERIES.update_mute,
        MUTES_SQL_TABLE,
        expirationTime,
        sql.SQLStr( reason, true ),
        ply:SteamID()
    )

    return SQLAction( "Updating timed mute", query, ply )
end

local function createPlayerMuteInDatabase( ply, expirationTime, reason )
    local query = string.format(
        MUTE_QUERIES.create_mute,
        MUTES_SQL_TABLE,
        ply:SteamID(),
        expirationTime,
        sql.SQLStr( reason, true )
    )

    return SQLAction( "Creating timed mute", query, ply )
end

local function getColumnFromDatabase( ply, column )
    local query = string.format( MUTE_QUERIES.retrieve_mute, column, MUTES_SQL_TABLE, ply:SteamID() )

    return SQLRead( "Retrieving time mute " .. column, query, ply )
end

local function getMuteExpirationFromDatabase( ply )
    local expiration = tonumber( getColumnFromDatabase( ply, "expiration" ) )

    return expiration
end

local function getMuteReasonFromDatabase( ply )
    local reason = getColumnFromDatabase( ply, "reason" )

    return reason
end

local function removeMuteFromDatabase( ply )
    if not isValidPlayer( ply ) then return end

    local query = string.format( MUTE_QUERIES.delete_mute, MUTES_SQL_TABLE, ply:SteamID() )

    return SQLAction( "Deleting expired time mute", query, ply )
end

-- END DATABASE OPERATIONS --



-- MUTE UTILITY FUNCTIONS --

local function muteIsExpired( expirationTime )
    return os.time() > expirationTime
end

local function playerIsMuteged( ply )
    return MutegedPlayers[ply] ~= nil
end

local function getExpirationTime( minutesToMute )
    local timeInSeconds = minutesToMute * 60
    local expirationTime = os.time() + timeInSeconds

    return expirationTime
end

local function getMinutesRemainingInMute( expirationTime )
    local secondsLeftInMute = expirationTime - os.time()
    local minutesLeftInMute = math.ceil( secondsLeftInMute / 60 )

    return minutesLeftInMute
end

local function ulxMutePlayer( ply )
    -- This is how ulx mutes someone
    ply.ulx_muted = true
    ply:SetNWBool( "ulx_muted", ply.ulx_muted )
end

local function ulxUnmutePlayer( ply )
    ply.ulx_muted = false
    ply:SetNWBool( "ulx_muted", ply.ulx_muted )
end

local function playerIsUlxMuteged( ply )
    return ply:GetNWBool( "ulx_muted", false )
end

local function mutePlayerUntil( ply, expirationTime, reason, fromDb )
    if not isValidPlayer( ply ) then return end

    -- Did this mute come directly from the database?
    fromDb = fromDb or false

    if not playerIsUlxMuteged( ply ) then ulxMutePlayer( ply ) end

    if not fromDb then
        if playerIsMuteged( ply ) then
            updatePlayerMuteInDatabase( ply, expirationTime, reason )
        else
            createPlayerMuteInDatabase( ply, expirationTime, reason )
        end
    end

    local minutesLeftInMute = getMinutesRemainingInMute( expirationTime )

    mutePrint( "Muteging '" .. ply:Nick() .. "' ( " .. ply:SteamID() .. " ) for " .. minutesLeftInMute .. " minutes!" )

    message = "You have a time mute that expires in " .. tostring( minutesLeftInMute ) .. " minutes."

    if reason then message = message .. " Reason: " .. reason end
    ply:ChatPrint( message )

    MutegedPlayers[ply] = expirationTime
end

local function mutePlayerForTime( ply, minutesToMute, reason )
    local expirationTime = getExpirationTime( minutesToMute )

    mutePlayerUntil( ply, expirationTime, reason )
end

local function unmutePlayer( ply )
    if not isValidPlayer( ply ) then return end

    if playerIsUlxMuteged( ply ) then ulxUnmutePlayer( ply ) end

    MutegedPlayers[ply] = nil
end

local function getPlayerMuteFromDatabase( ply )
    if not isValidPlayer( ply ) then return end

    -- Player is not in database
    local expiration = getMuteExpirationFromDatabase( ply )
    if expiration == nil then
        MutegedPlayers[ply] = nil
        return
    end

    if muteIsExpired( expiration ) then
        removeMuteFromDatabase( ply )
        unmutePlayer( ply )

        return
    end

    local reason = getMuteReasonFromDatabase( ply )

    mutePlayerUntil( ply, expiration, reason, true )
end

local function initializeMutegedPlayers()
    for _, ply in pairs( player.GetHumans() ) do
        getPlayerMuteFromDatabase( ply )
    end
end

-- END MUTE UTILITY FUNCTIONS --



-- ULX COMMAND SETUP --

function cmd.timeMute( callingPlayer, targetPlayers, minutesToMute, reason, shouldUnmute )
    if shouldUnmute then
        for _, ply in pairs( targetPlayers ) do
            removeMuteFromDatabase( ply )
            unmutePlayer( ply )
        end

        return ulx.fancyLogAdmin( callingPlayer, "#A unmuteged #T!", targetPlayers )
    end

    -- time > 100 years
    if minutesToMute == 0 then minutesToMute = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        mutePlayerForTime( ply, minutesToMute, reason )
    end

    ulx.fancyLogAdmin( callingPlayer, "#A muteged #T for #i minutes!", targetPlayers, minutesToMute )
end

local timeMuteCommand = ulx.command( ULX_CATEGORY_NAME, "ulx timemute", cmd.timeMute, "!tmute" )
timeMuteCommand:addParam{ type = ULib.cmds.PlayersArg }
timeMuteCommand:addParam{ type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0 }
timeMuteCommand:addParam{ type = ULib.cmds.StringArg, hint = "reason", ULib.cmds.takeRestOfLine }
timeMuteCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
timeMuteCommand:defaultAccess( ULib.ACCESS_ADMIN )
timeMuteCommand:help( "Mutes a user for a set amount of time" )
timeMuteCommand:setOpposite( "ulx untimemute", {_, _, _, _, true}, "!untmute" )

-- END ULX COMMAND SETUP --

-- HOOKS --

local function waitForPlayerToInitialize( ply )
    -- Timer because the steamId isn't available yet
    timer.Simple( INIT_WAIT_TIME, function()
        getPlayerMuteFromDatabase( ply )
    end )
end
hook.Remove( "PlayerInitialSpawn", "CFC_MuteCheck" )
hook.Add( "PlayerInitialSpawn", "CFC_MuteCheck", waitForPlayerToInitialize )


local function removeDisconnectedPlayer( ply )
    if not playerIsMuteged( ply ) then return end

    MutegedPlayers[ply] = nil
end
hook.Remove( "PlayerDisconnected", "CFC_MuteRemove" )
hook.Add( "PlayerDisconnected", "CFC_MuteRemove", removeDisconnectedPlayer )

local function initializeMutes()
    createTable()

    mutePrint( "Initializing Mutes!" )

    initializeMutegedPlayers()

    mutesInitialized = true
end

local function updateMutes()
    if not mutesInitialized then initializeMutes() end

    for ply, expiration in pairs( MutegedPlayers ) do
        if isValidPlayer( ply ) then
            if muteIsExpired( expiration ) then
                removeMuteFromDatabase( ply )
                unmutePlayer( ply )
            end
        else
            removeDisconnectedPlayer( ply )
        end
    end
end

hook.Remove( "Initialize", "CFC_TimedMuteInitialize" )
hook.Add( "Initialize", "CFC_TimedMuteInitialize", function()
    initializeMutes()

    timer.Remove( "CFC_MuteTimer" )
    timer.Create( "CFC_MuteTimer", MUTE_CHECK_INTERVAL, 0, updateMutes )
end )
