local function escapeArg( arg )
    if arg == SQL_NULL then
        return "NULL"
    elseif type( arg ) == "number" then
        return arg
    else
        return sql.SQLStr( arg )
    end
end

local function queryFormat( query, ... )
    local args = {}
    for i, arg in ipairs{ ... } do
        args[i] = escapeArg( arg )
    end

    query = string.format( query, unpack( args ) )
    return sql.Query( query )
end

local Data = {}

function Data:setupTables()
    sql.Begin()

    queryFormat( [[
        CREATE TABLE IF NOT EXISTS cfc_timed_punishments(
        id          INTEGER       PRIMARY KEY,
        steamid64   TEXT          NOT NULL,
        expiration  BIGINT        NOT NULL,
        issuer      TEXT          NOT NULL,
        punishment  TEXT          NOT NULL,
        reason      TEXT
    )
    ]] )

    queryFormat( [[
        CREATE UNIQUE INDEX IF NOT EXISTS
            player_punishments
        ON
            cfc_timed_punishments (steamid64, punishment)
    ]] )

    sql.Commit()
end

function Data:removeExpired()
    local now = os.time()
    local expired = queryFormat( [[
        SELECT
            punishment, COUNT(*)
        FROM
            cfc_timed_punishments
        WHERE
            expiration <= %u
        GROUP BY
            punishment
    ]], now )

    for _, p in ipairs( expired ) do
        self.logger:debug( "Deleting " .. p["COUNT(*)"] .. " expired punishments of type '" .. p.punishment .. "'" )
    end

    queryFormat( [[
        DELETE FROM
            cfc_timed_punishments
        WHERE
            expiration < %u
    ]], now )
end

function Data:createPunishment( punishment, steamID64, expiration, issuer, reason )
    queryFormat( [[
        INSERT OR REPLACE INTO
            cfc_timed_punishments (steamid64, expiration, issuer, punishment, reason )
        VALUES
            (%s, %s, %s, %s %s)
    ]], steamID64, expiration, issuer, punishment, reason )
end

function Data:removePunishment( punishment, steamID64 )
    queryFormat( [[
        DELETE FROM
            cfc_timed_punishments
        WHERE
            steamid64 = %s
        AND
            punishment = %s
    ]], steamID64, punishment )
end

function Data:getPunishments( steamID64 )
    local result = queryFormat( [[
        SELECT
            expiration, punishment
        FROM
            cfc_timed_punishments
        WHERE
            steamid64 = %s
    ]], steamID64 )

    local punishments = {}
    if result == nil then return punishments end
    if result == false then return ErrorNoHaltWithStack( steamID64 ) end

    for _, p in ipairs( result ) do
        punishments[p.punishment] = tonumber( p.expiration )
    end

    return punishments
end

return function( logger )
    Data.logger = logger:scope( "storage" )
    Data:setupTables()
    Data:removeExpired()

    return Data
end
