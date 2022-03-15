local IsValid = IsValid
local istable = istable
local isentity = isentity
local concat = table.concat

local defaultArgIndices = {
    targets = 2,
    duration = 3,
    reason = 4
}

local enabledCommands = {
    -- Timegag
    ["ulx timegag"] = { skipEmptyReason = true },
    ["ulx timegagid"] = {},

    -- Timemute
    ["ulx timemute"] = { skipEmptyReason = true },
    ["ulx timemuteid"] = {},

    -- PvPBan
    ["ulx pvpban"] = { skipEmptyReason = true },
    ["ulx pvpbanid"] = {},

    -- Chipban
    ["ulx chipban"] = { skipEmptyReason = true },
    ["ulx chipbanid"] = {},

    -- Ban
    ["ulx ban"] = {},
    ["ulx banid"] = {}
}

local function buildReason( reason, commandName, duration )
    local info = commandName

    if duration then
        info = info .. " " .. ULib.secondsToStringTime( duration * 60 )
    end

    info = "(" .. info .. ")"
    reason = reason .. " " .. info

    return reason
end

local function quoteWrap( s )
    return '"' .. s .. '"'
end

local function warn( caller, target, reason )
    if isentity( target ) then
        target = target:SteamID()
    end

    awarn_warnplayerid( caller, target, reason )
end

local function getTargets( indices, args )
    local targets = args[indices.targets]

    if not istable( targets ) then
        targets = { targets }
    end

    return targets
end

local function shouldWarn( cmd, duration, reason )
    if cmd.skipEmptyReason then
        if not reason then return false end
        if reason == "" then return false end
        if reason == "No reason specified" then return false end
    end

    if cmd.minDuration then
        if reason > cmd.minDuration then return false end
    end

    return true
end

local function parseCommand( cmd, args )
    local indices = cmd.indices or defaultArgIndices

    local duration = args[indices.duration]
    local reason = args[indices.reason]
    local targets = getTargets( indices, args )

    return duration, reason, targets
end

hook.Add( "ULibPostTranslatedCommand", "CFC_AutoWarn_WarnOnCommands", function( caller, commandName, args )
    if not ULib.ucl.query( caller, commandName ) then return end

    local cmd = enabledCommands[commandName]
    if not cmd then return end

    local duration, reason, targets = parseCommand( cmd, args )

    if not shouldWarn( cmd, duration, reason ) then return end

    for _, target in ipairs( targets ) do
        reason = buildReason( reason, commandName, duration )
        warn( caller, target, reason )
    end
end )
