local autoWarnCommands = {
    ["ulx timegag"] = {
        targets = 2,
        duration = 3,
        reason = 4
    },
    ["ulx ban"] = {
        target = 2,
        duration = 3,
        reason = 4
    }	
}

hook.Add("ULibPostTranslatedCommand", "CFC_AutoWarn_WarnOnCommands", function( caller, commandName, args )
    local indexes = autoWarnCommands[commandName]
    if not indexes then return end
    
    local targets
    if indexes.targets then
        targets = args[indexes.targets]
    elseif indexes.target
        targets  = {args[indexes.target]}
    end
    
    local duration = args[3]
    local reason = args[4]

    for _, target in pairs(targets) do
        local command = string.format( 'awarn_warn \"%s" "%s (%s %s)" ', target:SteamID(), reason, commandName, ULib.secondsToStringTime( duration * 60 ) )
        caller:ConCommand( command )
    end
end)