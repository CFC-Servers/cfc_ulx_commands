CFCUlxCommands.AutoWarner = {}
local AW = CFCUlxCommands.AutoWarner

AW.defaultArgIndices = {
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
AW.enabledCommands = {
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

function AW.buildReason( reason, commandName, duration )
    local info = commandName

    if duration then
        info = info .. " " .. ULib.secondsToStringTime( duration )
    end

    info = "(" .. info .. ")"
    reason = reason .. " " .. info

    return reason
end

function AW.warn( caller, target, reason )
    if isentity( target ) then
        target = target:SteamID64()
    else
        target = util.SteamIDTo64( target )
    end

    awarn_warnplayerid( caller, target, reason )
end

function AW.getTargets( indices, args )
    local targets = args[indices.targets]

    if not istable( targets ) then
        targets = { targets }
    end

    return targets
end

function AW.shouldWarn( cmd, duration, reason )
    if cmd.skipEmptyReason then
        if not reason then return false end
        if reason == "" then return false end
        if reason == "reason" then return false end
        if reason == "No reason specified" then return false end
    end

    if duration and duration < ( cmd.minDuration or 0 ) then return false end

    return true
end

function AW.parseCommand( cmd, args )
    local indices = cmd.indices or AW.defaultArgIndices

    local duration = indices.duration and args[indices.duration] or nil
    local reason = args[indices.reason]
    local targets = AW.getTargets( indices, args )

    return duration, reason, targets
end

function AW.CommandWatcher( caller, commandName, args )
    if not ULib.ucl.query( caller, commandName ) then return end

    local cmd = AW.enabledCommands[commandName]
    if not cmd then return end

    local duration, reason, targets = AW.parseCommand( cmd, args )

    if not AW.shouldWarn( cmd, duration, reason ) then return end
    if not cmd.usesSeconds then
        duration = duration and duration * 60
    end

    local warnReason = AW.buildReason( reason, commandName, duration )
    for _, target in ipairs( targets ) do
        AW.warn( caller, target, warnReason )
    end
end

hook.Add( "ULibPostTranslatedCommand", "CFC_AutoWarn_WarnOnCommands", AW.CommandWatcher )
