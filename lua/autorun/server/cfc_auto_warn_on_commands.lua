local IsValid = IsValid
local istable = istable
local isentity = isentity
local concat = table.concat

local defaultArgIndices = {
    targets = 2,
    duraiton = 3,
    reason = 4
}

local enabledCommands = {
    ["ulx timegag"] = {
        dontWarnOnEmptyReason = true
    },
    ["ulx timemute"] = {},
    ["ulx pvpban"] = {},
    ["ulx ban"] = {},
    ["ulx banid"] = {}
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
    if cmd.dontWarnOnEmptyReason then
        if not reason or reason == "" then return false end
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
    local cmd = enabledCommands[commandName]
    if not cmd then return end

    local duration, reason, targets = parseCommand( cmd, args )

    if not shouldWarn( cmd, duration, reason ) then return end

    for _, target in ipairs( targets ) do
        reason = buildReason( target, reason, commandName, duration )
        warn( caller, target, reason )
    end
end )
