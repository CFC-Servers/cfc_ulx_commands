local EFFECT_NAME = "ModelShuffle"
local SHUFFLE_INTERVAL = 0.1
local SHUFFLE_CHANCE_MIN = 0.003
local SHUFFLE_CHANCE_MAX = 0.05
local SHUFFLE_CHANCE_EASE = math.ease.InQuart
local ALLOWED_CLASSES = { -- Only apply to some classes because there's who knows how many that error when their model is messed with.
    -- For instance, changing a prop_door_rotating results in render errors stating the following:
        -- ERROR:  Can't draw studio model models/dav0r/hoverball.mdl because CBaseDoor is not derived from C_BaseAnimating

    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true,
    ["player"] = true,
    ["starfall_processor"] = true,
    ["starfall_component"] = true,
    ["gmod_wire_gate"] = true,
    ["gmod_wire_expression_2"] = true,
    ["acf_ammo"] = true,
    ["gmod_wire_hologram"] = true,
}


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

globals.MODELS = globals.MODELS or {}
globals.MODEL_LOOKUP = globals.MODEL_LOOKUP or {}

local MODELS = globals.MODELS
local MODEL_LOOKUP = globals.MODEL_LOOKUP

local ogModelsPerEnt = {}


-- Also returns true/false whether the model is invalid (doesn't check actual util.IsValidModel())
local function trackNewModel( model )
    if not model or type( model ) ~= "string" then return false end
    if model == "" then return false end

    if MODEL_LOOKUP[model] then return true end
    if model == "error.mdl" then return true end -- Allow error.mdl to be used, but don't track it.

    table.insert( MODELS, model )
    MODEL_LOOKUP[model] = true

    return true
end



CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local entityMeta = FindMetaTable( "Entity" )
        local shuffleChance = Lerp( SHUFFLE_CHANCE_EASE( math.Rand( 0, 1 ) ), SHUFFLE_CHANCE_MIN, SHUFFLE_CHANCE_MAX )

        -- Wrap :SetModel() to track more models and revert ents correctly if their model is changed after creation.
        globals.Entity_SetModel = globals.Entity_SetModel or entityMeta.SetModel
        local _SetModel = globals.Entity_SetModel
        function entityMeta:SetModel( model )
            if not trackNewModel( model ) then return end

            ogModelsPerEnt[self] = model

            return _SetModel( self, model )
        end

        -- Wrap :GetModel() to return the original model so that we don't break addons or e2/sf scripts that check models on client
        globals.Entity_GetModel = globals.Entity_GetModel or entityMeta.GetModel
        local _GetModel = globals.Entity_GetModel
        function entityMeta:GetModel()
            return ogModelsPerEnt[self] or _GetModel( self )
        end


        local function tryShuffleModel( ent )
            if not IsValid( ent ) then return end
            if not ent.SetModel then return end
            if not ALLOWED_CLASSES[ent:GetClass()] and not ent:IsWeapon() and not ent:IsNPC() then return end

            if not ogModelsPerEnt[ent] then
                local model = _GetModel( ent )

                trackNewModel( model )
                ogModelsPerEnt[ent] = model
            end

            if SHUFFLE_CHANCE ~= 1 and math.Rand( 0, 1 ) >= shuffleChance then return end

            local model = MODELS[math.random( 1, #MODELS )]

            if ent:IsPlayer() or ent:IsNPC() then
                local isMapModel = string.StartsWith( model, "*" )

                if isMapModel then return end -- Otherwise spams 'Attached [weapon model name] (mod_studio) to *[number]'
            end

            _SetModel( ent, model )
        end


        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "OnEntityCreated", "TrackModels", function( ent )
            timer.Simple( 0, function() -- In case the model is set directly after creation, for whatever reason
                if not IsValid( ent ) then return end
                if not ent.GetModel then return end

                trackNewModel( _GetModel( ent ) )
            end )
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "ShuffleModels", SHUFFLE_INTERVAL, 0, function()
            for _, ent in ipairs( ents.GetAll() ) do
                tryShuffleModel( ent )
            end
        end )
    end,

    onEnd = function()
        if SERVER then return end

        local entityMeta = FindMetaTable( "Entity" )
        local _SetModel = globals.Entity_SetModel

        for ent, model in pairs( ogModelsPerEnt ) do
            if IsValid( ent ) then
                _SetModel( ent, model )
            end

            ogModelsPerEnt[ent] = nil
        end

        entityMeta.SetModel = globals.Entity_SetModel
        entityMeta.GetModel = globals.Entity_GetModel
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {},
    groups = {
        "Wrap:Entity:SetModel()",
        "Wrap:Entity:GetModel()",
    },
    incompatibleGroups = {
        "Wrap:Entity:SetModel()",
        "Wrap:Entity:GetModel()",
    },
} )
