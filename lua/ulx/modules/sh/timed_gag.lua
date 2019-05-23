CATEGORY_NAME = "CFC"

SQL_TABLE = "cfc_timed_gags"

local GaggedPlayers = {}

local function createTable()
    if sql.TableExists( SQL_TABLE ) then return end

    local createTableQuery = string.format( "CREATE TABLE %s(steam_id TEXT, expiration BIGINT)", SQL_TABLE )

    sql.Query( createTableQuery )
end


GET_PLAYER_QUERY = "SELECT expiration FROM %s WHERE steam_id='%s'"
local function initializeGaggedPlayers()
    for _, ply in player.GetHumans() do
        local query = string.format( GET_PLAYER_QUERY, SQL_TABLE, ply:SteamID() )
        local expiration = sql.QueryValue( query )

        if expiration ~= nil then
            GaggedPlayers[ply] = expiration
        end
    end
end


REMOVE_GAG_QUERY = "REMOVE FROM %s WHERE steam_id='%s'"
local function removeExpiredGag(ply)
    GaggedPlayers[ply] = nil

    local query = string.format( REMOVE_GAG_QUERY, SQL_TABLE, ply:SteamID() )
    sql.Query( query )
end


local function gagIsExpired(expirationTime)
    return os.time() > expirationTime
end


local function playerIsAlreadyGagged(ply)
    return GaggedPlayers[ply] ~= nil
end


local UPDATE_QUERY = "UPDATE %s SET expiration=%d WHERE steam_id='%s'"
local function updatePlayerGag(steamId, expirationTime)
    local query = string.format(UPDATE_QUERY,
                                SQL_TABLE,
                                expirationTime,
                                steamId)
                                
    local succeeded = sql.Query( query )
    if succeeded == false then
        print( "Failed to update time gag for SteamID "..steamId.."!" )
        return false
    end

    return true
end


local NEW_GAG_QUERY = "INSERT INTO %s(steam_id, expiration) VALUES('%s', %d)"
local function newPlayerGag(steamId, expirationTime)
    local query = string.format(NEW_GAG_QUERY,
                                SQL_TABLE,
                                steamId,
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


local function gagPlayer(ply)
    -- This is how ulx gags someone
    ply.ulx_gagged = true
	ply:SetNWBool("ulx_gagged", ply.ulx_gagged)
end

local function ungagPlayer(ply)
    ply.ulx_gagged = false
    ply:SetNWBool("ulx_gagged", ply.ulx_gagged)
end


local function gagPlayerForTime(ply, timeToGag)
    local expirationTime = getExpirationTime( timeToGag )

    gagPlayer(ply)

    if GaggedPlayers[ply] == nil then
        newPlayerGag(ply:SteamID(), expirationTime)
    else
        updatePlayerGag(ply:SteamID(), expirationTime)
    end

    GaggedPlayers[ply] = expirationTime
end


local function timeGag( callingPlayer, targetPlayers, timeToGag )
	ulx.fancyLogAdmin( callingPlayer, "#A gagged #T for #i seconds!", targetPlayers, timeToGag * 60 )

    for _, ply in pairs( targetPlayers ) do
        gagPlayerForTime(ply, timeToGag)    
    end
end

local timegag = ulx.command( CATEGORY_NAME, "ulx timegag", timeGag, "!tgag" )
timegag:addParam{ type=ULib.cmds.PlayersArg }
timegag:addParam{ type=ULib.cmds.NumArg, min=0, ULib.cmds.allowTimeString }
timegag:defaultAccess( ULib.ACCESS_ADMIN )
timegag:help( "Gags a user for a set amount of time" )


function updateGags()
    for ply, expiration in pairs( GaggedPlayers ) do
        if gagIsExpired( expiration ) or ply:GetNWBool("ulx_gagged", false) == false then
            removeExpiredGag( ply )
            ungagPlayer( ply )
        end
    end
end

timer.Create("CFC_GagTimer", 1, 0, updateGags)

-- HOOKS --

local function getPlayerGagFromDatabase(ply)
    if not IsValid( ply ) and not ply:IsPlayer() then return end

    local playerSteamId = ply:SteamID()

    local query = string.format( GET_PLAYER_QUERY, SQL_TABLE, playerSteamId )

    local expiration = sql.Query( query )
    
    if expiration == nil then return end

    GaggedPlayers[playerSteamId] = expiration
end

hook.Remove( "PlayerInitialSpawn", "CFC_GagCheck" )
hook.Add( "PlayerInitialSpawn", "CFC_GagCheck", function( ply )
    -- Timer because the steamId isn't available yet
    timer.Simple(1, function()
        getPlayerGagFromDatabase( ply )
    end)
end)


local function removeDisconnectedPlayer(ply)
    local steamId = ply:SteamID()

    if not GaggedPlayers[steamId] then return end

    GaggedPlayers[steamId] = nil
end

hook.Remove( "PlayerDisconnected", "CFC_GagRemove" )
hook.Add( "PlayerDisconnected", "CFC_GagRemove", removeDisconnectedPlayer )

local function init()
    createTable()

    -- Wait a second before intializing players
    timer.Simple(1, function()
        initializeGaggedPlayers()
    end)
end

hook.Remove( "OnGamemodeLoaded", "CFC_GagInit" )
hook.Add( "OnGamemodeLoaded", "CFC_GagInit", init)
