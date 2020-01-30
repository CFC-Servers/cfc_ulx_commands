-- Constants
local ULX_CATEGORY_NAME = "CFC"
local GAGS_SQL_TABLE = "cfc_timed_gags"
local INIT_WAIT_TIME = 1
local GAG_CHECK_INTERVAL = 1

local GaggedPlayers = {}

local gagsInitialized = false

local GAG_QUERIES = {}
GAG_QUERIES['create_gag']   = "INSERT INTO %s(steam_id, expiration, reason) VALUES('%s', %d, '%s')"
GAG_QUERIES['create_table'] = "CREATE TABLE %s(steam_id TEXT NOT NULL UNIQUE, expiration BIGINT, reason TEXT)"
GAG_QUERIES['delete_gag']   = "DELETE FROM %s WHERE steam_id='%s'"
GAG_QUERIES['retrieve_gag'] = "SELECT %s FROM %s WHERE steam_id='%s'"
GAG_QUERIES['update_gag']   = "UPDATE %s SET expiration=%d,reason='%s' WHERE steam_id='%s'"


-- HELPERS --

local function IsValidPlayer( ply )
    local playerIsValid = IsValid( ply ) and ply:IsPlayer()

    return playerIsValid
end

local function GagPrint( msg )
    print( "[CFC Timed Gag] " .. msg )
end

local function DatabaseGagPrint( action, succeeded, ply )
    local result = ( succeeded == false ) and "FAILED" or "SUCCEEDED"

    if IsValidPlayer( ply ) then
        GagPrint( action .. " for '" .. ply:Nick() .. "' (" .. ply:SteamID() .. ") in Database " .. result )
    else
        GagPrint( action .. " " .. result )
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

    DatabaseGagPrint( action, succeeded, ply )

    return result
end

local function SQLAction( action, query, ply )
    return SQLOperation( action, query, ply, false )
end

local function SQLRead( action, query, ply )
    return SQLOperation( action, query, ply, true )
end

local function createTable()
    if sql.TableExists( GAGS_SQL_TABLE ) then return GagPrint( GAGS_SQL_TABLE .. " already exists!" ) end

    local query = string.format( GAG_QUERIES['create_table'], GAGS_SQL_TABLE )

    return SQLAction( "Creating table " .. GAGS_SQL_TABLE, query )
end

local function updatePlayerGagInDatabase( ply, expirationTime, reason )
    local query = string.format(
        GAG_QUERIES['update_gag'],
        GAGS_SQL_TABLE,
        expirationTime,
        sql.SQLStr( reason, true ),
        ply:SteamID()
    )

    return SQLAction( "Updating timed gag", query, ply )
end

local function createPlayerGagInDatabase( ply, expirationTime, reason )
    local query = string.format(
        GAG_QUERIES['create_gag'],
        GAGS_SQL_TABLE,
        ply:SteamID(),
        expirationTime,
        sql.SQLStr( reason, true )
    )

    return SQLAction( "Creating timed gag", query, ply )
end

local function getColumnFromDatabase( ply, column )
    local query = string.format( GAG_QUERIES['retrieve_gag'], column, GAGS_SQL_TABLE, ply:SteamID() )

    return SQLRead( "Retrieving time gag " .. column, query, ply )
end

local function getGagExpirationFromDatabase( ply )
    local expiration = tonumber( getColumnFromDatabase( ply, "expiration" ) )

    return expiration
end

local function getGagReasonFromDatabase( ply )
    local reason = getColumnFromDatabase( ply, "reason" )

    return reason
end

local function removeExpiredGagFromDatabase( ply )
    if not IsValidPlayer( ply ) then return end

    local query = string.format( GAG_QUERIES['delete_gag'], GAGS_SQL_TABLE, ply:SteamID() )
    
    return SQLAction( "Deleting expired time gag", query, ply )
end

-- END DATABASE OPERATIONS --



-- GAG UTILITY FUNCTIONS -- 

local function gagIsExpired( expirationTime )
    return os.time() > expirationTime
end

local function playerIsGagged( ply )
    return GaggedPlayers[ply] ~= nil
end

local function getExpirationTime( minutesToGag )
    local timeInSeconds = minutesToGag * 60
    local expirationTime = os.time() + timeInSeconds

    return expirationTime
end

local function getMinutesRemainingInGag( expirationTime )
    local secondsLeftInGag = expirationTime - os.time()
    local minutesLeftInGag = math.ceil( secondsLeftInGag / 60 )

    return minutesLeftInGag
end

local function ulxGagPlayer( ply )
    -- This is how ulx gags someone
    ply.ulx_gagged = true
	ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
end

local function ulxUngagPlayer( ply )
    ply.ulx_gagged = false
    ply:SetNWBool( "ulx_gagged", ply.ulx_gagged )
end

local function playerIsUlxGagged( ply )
    return ply:GetNWBool( "ulx_gagged", false )
end

local function gagPlayerUntil( ply, expirationTime, reason, fromDb )
    if not IsValidPlayer( ply ) then return end
    
    -- Did this gag come directly from the database?
    fromDb = fromDb or false

    if not playerIsUlxGagged( ply ) then ulxGagPlayer( ply ) end
    
    if not fromDb then
        if playerIsGagged( ply ) then
            updatePlayerGagInDatabase( ply, expirationTime, reason )
        else
            createPlayerGagInDatabase( ply, expirationTime, reason )
        end
    end

    local minutesLeftInGag = getMinutesRemainingInGag( expirationTime )

    GagPrint( "Gagging '" .. ply:Nick() .. "' (" .. ply:SteamID() .. ") for " .. minutesLeftInGag .. " minutes!" )

    message = "You have a time gag that expires in " .. tostring( minutesLeftInGag ) .. " minutes." 

    if reason then message = message .. " Reason: " .. reason end
    ply:ChatPrint( message )

    GaggedPlayers[ply] = expirationTime
end

local function gagPlayerForTime( ply, minutesToGag, reason )
    local expirationTime = getExpirationTime( minutesToGag )

    gagPlayerUntil( ply, expirationTime, reason )
end

local function ungagPlayer( ply )
    if not IsValidPlayer( ply ) then return end

    if playerIsUlxGagged( ply ) then ulxUngagPlayer( ply ) end

    GaggedPlayers[ply] = nil
end

local function getPlayerGagFromDatabase( ply )
    if not IsValidPlayer( ply ) then return end

    -- Player is not in database
    local expiration = getGagExpirationFromDatabase( ply )
    if expiration == nil then 
        GaggedPlayers[ply] = nil
        return
    end

    if gagIsExpired( expiration ) then 
        removeExpiredGagFromDatabase( ply ) 
        ungagPlayer( ply )

        return
    end

    local reason = getGagReasonFromDatabase( ply )

    gagPlayerUntil( ply, expiration, reason, true )
end

local function initializeGaggedPlayers()
    for _, ply in pairs( player.GetHumans() ) do
        getPlayerGagFromDatabase( ply )
    end
end

-- END GAG UTILITY FUNCTIONS --



-- ULX COMMAND SETUP --

local function timeGag( callingPlayer, targetPlayers, minutesToGag, reason )
	ulx.fancyLogAdmin( callingPlayer, "#A gagged #T for #i minutes!", targetPlayers, minutesToGag )

    -- time > 100 years
    if minutesToGag == 0 then minutesToGag = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        gagPlayerForTime( ply, minutesToGag, reason )
    end
end

local timegag = ulx.command( ULX_CATEGORY_NAME, "ulx timegag", timeGag, "!tgag" )
timegag:addParam{ type=ULib.cmds.PlayersArg }
timegag:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.allowTimeString, min=0 }
timegag:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine }
timegag:defaultAccess( ULib.ACCESS_ADMIN )
timegag:help( "Gags a user for a set amount of time" )

-- END ULX COMMAND SETUP --

-- HOOKS --

local function waitForPlayerToInitialize( ply )
    -- Timer because the steamId isn't available yet
    timer.Simple(INIT_WAIT_TIME, function()
        getPlayerGagFromDatabase( ply )
    end)
end
hook.Remove( "PlayerInitialSpawn", "CFC_GagCheck" )
hook.Add( "PlayerInitialSpawn", "CFC_GagCheck", waitForPlayerToInitialize )
    

local function removeDisconnectedPlayer( ply )
    if not playerIsGagged( ply ) then return end

    GaggedPlayers[ply] = nil
end
hook.Remove( "PlayerDisconnected", "CFC_GagRemove" )
hook.Add( "PlayerDisconnected", "CFC_GagRemove", removeDisconnectedPlayer )

local function initializeGags()
    createTable()

    GagPrint("Initializing Gags!")

    initializeGaggedPlayers()

    gagsInitialized = true
end

local function updateGags()
    if not gagsInitialized then initializeGags() end

    for ply, expiration in pairs( GaggedPlayers ) do
        if IsValidPlayer( ply ) then 
            if gagIsExpired( expiration ) or not playerIsUlxGagged( ply ) then
                removeExpiredGagFromDatabase( ply )
                ungagPlayer( ply )
            end
        else
            removeDisconnectedPlayer( ply )
        end
    end
end

hook.Remove( "Initialize", "CFC_TimedGagInitialize" )
hook.Add( "Initialize", "CFC_TimedGagInitialize", function()
    initializeGags()

    timer.Remove( "CFC_GagTimer" )
    timer.Create( "CFC_GagTimer", GAG_CHECK_INTERVAL, 0, updateGags )
end )
