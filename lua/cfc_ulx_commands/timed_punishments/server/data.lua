local function escapeArg( arg )
    if arg == nil then
        return "NULL"
    elseif type( arg ) == "number" then
        return arg
    else
        return sql.SQLStr( arg )
    end
end

local function query( query, ... )
    local args = {}
    for i, arg in ipairs( { ... } ) do
        args[i] = escapeArg( arg )
    end

    query = string.format( query, unpack( args ) )
    return sql.Query( query )
end

local function formatPunishments( result )
    local punishments = {}
    if result == nil then return punishments end
    if result == false then return ErrorNoHaltWithStack( "Query failed when retrieving punishments!" ) end

    for _, p in ipairs( result ) do
        punishments[p.punishment] = tonumber( p.expiration )
    end

    return punishments
end

local Data = {}

function Data:setupTables()
    sql.Begin()

    query( [[
        CREATE TABLE IF NOT EXISTS cfc_timed_punishments(
        id          INTEGER       PRIMARY KEY,
        steamid64   TEXT          NOT NULL,
        expiration  INTEGER       NOT NULL,
        issuer      TEXT          NOT NULL,
        punishment  TEXT          NOT NULL,
        reason      TEXT
    )
    ]] )

    query( [[
        CREATE UNIQUE INDEX IF NOT EXISTS
            player_punishments
        ON
            cfc_timed_punishments (steamid64, punishment)
    ]] )

    sql.Commit()
end

function Data:removeExpired()
    local now = os.time()
    local expired = query( [[
        SELECT
            punishment, COUNT(*)
        FROM
            cfc_timed_punishments
        WHERE
            expiration <= %u
        AND
            expiration > 0
        GROUP BY
            punishment
    ]], now )

    if not expired then return end

    for _, p in ipairs( expired ) do
        self.logger:debug( "Deleting " .. p["COUNT(*)"] .. " expired punishments of type '" .. p.punishment .. "'" )
    end

    query( [[
        DELETE FROM
            cfc_timed_punishments
        WHERE
            expiration <= %u
        AND
            expiration > 0
    ]], now )
end

function Data:createPunishment( punishment, steamID64, expiration, issuer, reason )
    query( [[
        INSERT OR REPLACE INTO
            cfc_timed_punishments (steamid64, expiration, issuer, punishment, reason )
        VALUES
            (%s, %s, %s, %s, %s)
    ]], steamID64, expiration, issuer, punishment, reason )
end

function Data:removePunishment( punishment, steamID64 )
    query( [[
        DELETE FROM
            cfc_timed_punishments
        WHERE
            steamid64 = %s
        AND
            punishment = %s
    ]], steamID64, punishment )
end

function Data:getPunishments( steamID64 )
    local result = query( [[
        SELECT
            expiration, punishment
        FROM
            cfc_timed_punishments
        WHERE
            steamid64 = %s
    ]], steamID64 )

    return formatPunishments( result )
end

function Data:getActivePunishments( steamID64 )
    local now = os.time()

    local result = query( [[
        SELECT
            expiration, punishment
        FROM
            cfc_timed_punishments
        WHERE
            steamid64 = %s
        AND
            expiration > 0
        AND
            expiration > %u
    ]], steamID64, now )

    return formatPunishments( result )
end

return function( logger )
    Data.logger = logger:scope( "storage" )
    Data:setupTables()
    Data:removeExpired()

    return Data
end
