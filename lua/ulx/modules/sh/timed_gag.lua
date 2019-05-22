CATEGORY_NAME = "CFC"
SQL_TABLE = "cfc_timed_gags"a

local GaggedPlayers = {}

local function createTable()
    if sql.TableExists( SQL_TABLE ) then return end

    local createTableQuery = string.format("CREATE TABLE %s(steam_id TEXT, expiration BIGINT)", SQL_TABLE)

    sql.Query(createTableQuery)
end

local function initializeGaggedPlayers()
    local query = string.format( "SELECT * FROM %s", SQL_TABLE)

    GaggedPlayers = sql.Query(query)
end


local function init()
    createTable()

    initializeGaggedPlayers()
end


local function removeExpiredGag(steamId)
    GaggedPlayers[steamId] = nil

    local query = string.format("REMOVE FROM %s WHERE steam_id='%s'", SQL_TABLE, steamID)
    sql.Query(query)
end

local function playerIsAlreadyGagged(steamId)
    return GaggedPlayers[steamId]
end

local function updatePlayerGag(steamId, expirationTime)
    local query = string.format("UPDATE %s SET expiration=%d WHERE steam_id='%s'",
                                SQL_TABLE,
                                expirationTime,
                                steamId)
                                
    local succeeded = sql.Query(query)
    if succeeded == false then
        print("Failed to update time gag for SteamID "..steamId.."!")
        return false
    end

    return true
end


local function newPlayerGag(steamid, expirationTime)
    local query = string.format("INSERT INTO %s(steam_id, expiration) VALUES('%s', %d)", 
                                SQL_TABLE,
                                steamid,
                                expirationTime)

    local succeeded = sql.Query( query )
    if succeeded == false then
        print("Failed to create time gag for SteamID "..steamId.."!")
        return false
    end

    return true
end


local function getExpirationTime(timeToGag)
    local timeInSeconds = timeToGag * 60
    local expirationTime = os.time() + timeInSeconds

    return expirationTime
end


local function gagPlayerForTime(steamId, timeToGag)
    local expirationTime = getExpirationTime(timeToGag)
    

end


local function timeGag( callingPlayer, timeToGag, targetPlayers )
    for _, ply in pairs( targetPlayers ) do
        steamId = ply:SteamID()

        gagPlayerForTime(steamId, timeToGag)    
    end
end

local timegag = ulx.command( CATEGORY_NAME, "ulx timegag", timeGag, "!tgag" )
timegag:addParam{ type=ULib.cmds.NumArg, min=0, ULib.cmds.allowTimeString }
timegag:addParam{ type=ULib.cmds.PlayersArg }
timegag:defaultAccess( ULib.ACCESS_ADMIN )
timegag:help( "Gags a user for a set amount of time")
