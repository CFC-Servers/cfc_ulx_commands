local CATEGORY_NAME = "CFC"

local SQL_TABLE = "cfc_timed_gags"

local INIT_WAIT_TIME = 1

local GaggedPlayers = {}

local gagsInitialized = false

local function BRAIDSPRINT(msg)
    for _, ply in pairs( player.GetHumans()) do
        if ply:Nick() == "iLikeYoBraids" then ply:ChatPrint(msg) end
        PrintTable(GaggedPlayers)
    end
end


local function isValidPlayer(ply)
    playerIsValid = IsValid( ply ) and ply:IsPlayer()

    return playerIsValid
end

local function createTable()
    BRAIDSPRINT("conditionally creating gags table...")

    if sql.TableExists( SQL_TABLE ) then return end

    BRAIDSPRINT("creating gags table because it wasn't found...")

    local createTableQuery = string.format( "CREATE TABLE %s(steam_id TEXT, expiration BIGINT, reason TEXT)", SQL_TABLE )

    sql.Query( createTableQuery )
end

GET_PLAYER_QUERY = "SELECT %s FROM %s WHERE steam_id='%s'"
local function getColumnFromDatabase(ply, column)
    local query = string.format( GET_PLAYER_QUERY, column, SQL_TABLE, ply:SteamID() )
    BRAIDSPRINT(query)

    value = sql.QueryValue( query )

    return value
end

local function getGagExpirationFromDatabase(ply)
    expiration = getColumnFromDatabase(ply, "expiration")

    return expiration
end

local function getGagReasonFromDatabase(ply)
    reason = getColumnFromDatabase(ply, "reason")

    return reason
end

local function getPlayerGagFromDatabase(ply)
    if not isValidPlayer( ply ) then return end

    local playerSteamId = ply:SteamID()

    local expiration = tonumber( getGagExpirationFromDatabase( ply ) )
    BRAIDSPRINT(ply:Nick().." gag expiration from db: "..tostring(expiration))
    if expiration == nil then return end

    if gagIsExpired( expiration ) then return removeExpiredGag( ply ) end


    reason = getGagReasonFromDatabase( ply )

    gagPlayerUntil( expiration, reason )
end

local function initializeGaggedPlayers()
    for _, ply in pairs( player.GetHumans() ) do
        getPlayerGagFromDatabase( ply )
    end
    
    gagsInitialized = true
end

local function init()
    createTable()

    BRAIDSPRINT("INITITALIZING")

    -- Wait a second before initializing players
    timer.Simple( INIT_WAIT_TIME, initializeGaggedPlayers )
end


REMOVE_GAG_QUERY = "REMOVE FROM %s WHERE steam_id='%s'"
local function removeExpiredGag(ply)
    if not isValidPlayer( ply ) then return end

    GaggedPlayers[ply] = nil

    local query = string.format( REMOVE_GAG_QUERY, SQL_TABLE, ply:SteamID() )
    sql.Query( query )
end


local function gagIsExpired(expirationTime)
    return os.time() > tonumber( expirationTime )
end


local function playerIsAlreadyGagged(ply)
    return GaggedPlayers[ply] ~= nil
end


local UPDATE_QUERY = "UPDATE %s SET expiration=%d,reason='%s' WHERE steam_id='%s'"
local function updatePlayerGag(steamId, expirationTime, reason)
    local query = string.format(UPDATE_QUERY,
                                SQL_TABLE,
                                expirationTime,
                                steamId,
                                reason)
                                
    local succeeded = sql.Query( query )
    if succeeded == false then
        print( "Failed to update time gag for SteamID "..steamId.."!" )
        BRAIDSPRINT( "Failed to update time gag for SteamID "..steamId.."!" )
        return false
    end

    return true
end


local NEW_GAG_QUERY = "INSERT INTO %s(steam_id, expiration, reason) VALUES('%s', %d, '%s')"
local function newPlayerGag(steamId, expirationTime, reason)
    local query = string.format(NEW_GAG_QUERY,
                                SQL_TABLE,
                                steamId,
                                expirationTime,
                                reason)

    local succeeded = sql.Query( query )
    if succeeded == false then
        print("Failed to create time gag for SteamID "..steamId.."!")
        BRAIDSPRINT("Failed to create time gag for SteamID "..steamId.."!")
        return false
    end

    return true
end


local function getExpirationTime(timeToGag)
    local timeInSeconds = timeToGag * 60
    local expirationTime = os.time() + timeInSeconds

    return expirationTime
end


local function ulxGagPlayer(ply)
    -- This is how ulx gags someone
    ply.ulx_gagged = true
	ply:SetNWBool("ulx_gagged", ply.ulx_gagged)
end

local function ulxUngagPlayer(ply)
    ply.ulx_gagged = false
    ply:SetNWBool("ulx_gagged", ply.ulx_gagged)
end

local function gagPlayerUntil(ply, expirationTime, reason)
    if not isValidPlayer( ply ) then return end
    
    ulxGagPlayer( ply )
    
    if playerIsAlreadyGagged( ply ) then
        updatePlayerGag(ply:SteamID(), expirationTime, reason)
    else
        newPlayerGag(ply:SteamID(), expirationTime, reason)
    end
    
    secondsLeftInGag = tonumber( expirationTime ) - os.time()
    minutesLeftInGag = math.ceil( secondsLeftInGag / 60 )

    message = "You have a time gag that expires in " .. tostring(minutesLeftInGag) .. " minutes." 

    if reason then message = message .. " Reason: " .. reason end
    ply:ChatPrint(message)

    GaggedPlayers[ply] = expirationTime
end

local function gagPlayerForTime(ply, timeToGag, reason)
    local expirationTime = getExpirationTime( timeToGag )

    gagPlayerUntil(ply, expirationTime, reason)
end

local function ungagPlayer(ply)
    if not isValidPlayer( ply ) then return end

    ulxUngagPlayer(ply)
    GaggedPlayers[ply] = nil
end

local function timeGag( callingPlayer, targetPlayers, timeToGag, reason )
	ulx.fancyLogAdmin( callingPlayer, "#A gagged #T for #i minutes!", targetPlayers, timeToGag )

    -- time > 100 years
    if timeToGag == 0 then timeToGag = 9999999999 end

    for _, ply in pairs( targetPlayers ) do
        gagPlayerForTime(ply, timeToGag, reason)
    end
end

local timegag = ulx.command( CATEGORY_NAME, "ulx timegag", timeGag, "!tgag" )
timegag:addParam{ type=ULib.cmds.PlayersArg }
timegag:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.allowTimeString, min=0 }
timegag:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine }
timegag:defaultAccess( ULib.ACCESS_ADMIN )
timegag:help( "Gags a user for a set amount of time" )


function updateGags()
    BRAIDSPRINT("UPDATING GAGS!")

    if not gagsInitialized then init() end

    for ply, expiration in pairs( GaggedPlayers ) do
        if not IsValid( ply ) then return removeDisconnectedPlayer( ply ) end

        if gagIsExpired( expiration ) or ply:GetNWBool( "ulx_gagged", false ) == false then
            removeExpiredGag( ply )
            ungagPlayer( ply )
        else
            ply:ChatPrint("You are time gagged! " .. os.time() .." vs ".. expiration .. " ("..expiration-os.time().." more seconds)")
        end
    end
end

timer.Remove("CFC_GagTimer")
timer.Create("CFC_GagTimer", 1, 0, updateGags)

-- HOOKS --

hook.Remove( "PlayerInitialSpawn", "CFC_GagCheck" )
hook.Add( "PlayerInitialSpawn", "CFC_GagCheck", function( ply )
    -- Timer because the steamId isn't available yet
    timer.Simple(1, function()
        getPlayerGagFromDatabase( ply )
    end)
end)


local function removeDisconnectedPlayer(ply)
    if not GaggedPlayers[ply] then return end

    GaggedPlayers[steamId] = nil
end

hook.Remove( "PlayerDisconnected", "CFC_GagRemove" )
hook.Add( "PlayerDisconnected", "CFC_GagRemove", removeDisconnectedPlayer )


hook.Remove( "Initialize", "CFC_GagInit" )
hook.Add( "Initialize", "CFC_GagInit", init)

