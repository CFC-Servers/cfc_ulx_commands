local EFFECT_NAME = "RandomSounds"
local POOL_SIZE = 100 -- Smaller pool sizes help reduce lag from loading new sounds on the fly (most notable with footsteps).
local POOL_BATCH_SIZE = 10 -- Builds up the pool in batches over time, since it requires sounds to be loaded to see if they're good.
local POOL_BATCH_INTERVAL = 1


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local libGetAllSounds = CFCUlxCurse.IncludeEffectUtil( "get_all_sounds" )

local poolSounds = {}
local poolSoundsLength = nil
local poolSoundsTargetLength = nil
local entityMeta = FindMetaTable( "Entity" )

local math_random = math.random


local function getSound()
    return poolSounds[math_random( 1, poolSoundsLength )]
end

local function addBatchToPool()
    local i = poolSoundsLength + 1
    local max = math.min( i + POOL_BATCH_SIZE - 1, poolSoundsTargetLength )

    while i <= max do
        poolSounds[i] = libGetAllSounds.SampleSound()
        i = i + 1
    end

    poolSoundsLength = max
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local allSounds = libGetAllSounds.GetSounds()
        local allSoundsLength = #allSounds

        poolSoundsLength = 0
        poolSoundsTargetLength = math.min( POOL_SIZE, allSoundsLength )
        addBatchToPool() -- Add an initial batch so we can start playing sounds right away.

        local passes = math.ceil( POOL_SIZE / POOL_BATCH_SIZE ) - 1 -- -1 because we already added the first batch.

        if passes > 0 then
            CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "FillPool", POOL_BATCH_INTERVAL, passes, addBatchToPool )
        end

        globals.CreateSound = globals.CreateSound or CreateSound
        globals.EmitSound = globals.EmitSound or EmitSound
        globals.EntityEmitSound = globals.EntityEmitSound or entityMeta.EmitSound
        globals.soundPlay = globals.soundPlay or sound.Play
        globals.surfacePlaySound = globals.surfacePlaySound or surface.PlaySound

        CreateSound = function( ent, _snd, ... )
            globals.CreateSound( ent, getSound(), ... )
        end

        EmitSound = function( _snd, ... )
            globals.EmitSound( getSound(), ... )
        end

        entityMeta.EmitSound = function( self, _snd, ... )
            globals.EntityEmitSound( self, getSound(), ... )
        end

        sound.Play = function( _snd, ... )
            globals.soundPlay( getSound(), ... )
        end

        surface.PlaySound = function()
            globals.surfacePlaySound( getSound() )
        end

        -- Footsteps are played at the engine level, need to block them and call from lua for the wrap to apply.
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerFootstep", "OverrideSound", function( ply, _, _, snd, volume )
            ply:EmitSound( snd, nil, nil, volume )

            return true
        end )
    end,

    onEnd = function()
        if SERVER then return end

        CreateSound = globals.CreateSound
        EmitSound = globals.EmitSound
        entityMeta.EmitSound = globals.EntityEmitSound
        sound.Play = globals.soundPlay
        surface.PlaySound = globals.surfacePlaySound

        RunConsoleCommand( "stopsound" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true, -- More overwhelming sensory-wise compared to SoundShuffle, and has lag at the start.
    incompatibileEffects = {},
    groups = {
        "Wrap:Sound",
    },
    incompatibleGroups = {
        "Wrap:Sound",
    },
} )
