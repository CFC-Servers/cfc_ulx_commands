CFCUlxCurse = CFCUlxCurse or {}

local configData


local function loadServerConfig()
    if file.Exists( "cfc_ulx_commands/curse/sv_config.json", "DATA" ) then
        configData = file.Read( "cfc_ulx_commands/curse/sv_config.json", "DATA" )
    else
        configData = file.Read( "cfc_ulx_commands/curse/sv_config_default.json", "LUA" )
    end

    if not configData then
        ErrorNoHalt( "CFCUlxCommands - Failed to load curse config file!\n" )
        configData = {}

        return
    end

    configData = util.JSONToTable( configData )
    configData.disabledEffects = configData.disabledEffects or {}

    CFCUlxCurse.EFFECT_DURATION_MIN = configData.effectDurationMin or 10
    CFCUlxCurse.EFFECT_DURATION_MAX = configData.effectDurationMax or 30
    CFCUlxCurse.EFFECT_DURATION_ONETIME_MULT = configData.effectDurationOnetimeMult or 3
    CFCUlxCurse.EFFECT_GAP_MIN = configData.effectGapMin or 10
    CFCUlxCurse.EFFECT_GAP_MAX = configData.effectGapMax or 300 -- 5 minutes
end

local function isEffectEnabled( fileName )
    if not SERVER then return true end

    local fileNameStripped = string.StripExtension( fileName )

    return not configData.disabledEffects[fileNameStripped]
end


do -- Load curse effects
    AddCSLuaFile( "cfc_ulx_commands/curse/sh_utils.lua" )
    AddCSLuaFile( "cfc_ulx_commands/curse/cl_utils.lua" )

    include( "cfc_ulx_commands/curse/sh_utils.lua" )

    if SERVER then
        include( "cfc_ulx_commands/curse/sv_utils.lua" )
        loadServerConfig()
    else
        include( "cfc_ulx_commands/curse/cl_utils.lua" )
    end

    local effects_modules = file.Find( "cfc_ulx_commands/curse/effects/*.lua", "LUA" )

    for _, fileName in ipairs( effects_modules ) do
        if isEffectEnabled( fileName ) then
            AddCSLuaFile( "cfc_ulx_commands/curse/effects/" .. fileName )
            include( "cfc_ulx_commands/curse/effects/" .. fileName )
        end
    end
end
