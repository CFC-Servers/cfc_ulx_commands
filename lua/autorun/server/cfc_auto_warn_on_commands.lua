local istable = istable
local isentity = isentity

local defaultArgIndices = {
    targets = 2,
    duration = 3,
    reason = 4
}

-- Available keys for each command
--  - indices
--    - table
--    - explain the index of targets, duration, and reason for the given command
--
--  - skipEmptyReason
--    - boolean
--
--  - minDuration
--    - int
--
--  - usesSeconds
--    - bool
--    - set to true if the command uses seconds for its duration
--
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
    ["ulx banid"] = {},

    -- Kick
    ["ulx kick"] = {
        skipEmptyReason = true,
        indices = {
            targets = 2,
            reason = 3
        }
    },
    ["ulx kickid"] = {
        indices = {
            targest = 2,
            reason = 3
        }
    }
}

local function buildReason( reason, commandName, duration )
    local info = commandName

    if duration then
        info = info .. " " .. ULib.secondsToStringTime( duration )
    end

    info = "(" .. info .. ")"
    reason = reason .. " " .. info

    return reason
end

local function warn( caller, target, reason )
    if isentity( target ) then
        target = target:SteamID64()
    else
        target = util.SteamIDTo64( target )
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
        if reason == "reason" then return false end
        if reason == "No reason specified" then return false end
    end

    if duration and duration < ( cmd.minDuration or 0 ) then return false end

    return true
end

local function parseCommand( cmd, args )
    local indices = cmd.indices or defaultArgIndices

    local duration = indices.duration and args[indices.duration] or nil
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
    if not cmd.usesSeconds then
        duration = duration and duration * 60
    end

    for _, target in ipairs( targets ) do
        reason = buildReason( reason, commandName, duration )
        warn( caller, target, reason )
    end
end )
