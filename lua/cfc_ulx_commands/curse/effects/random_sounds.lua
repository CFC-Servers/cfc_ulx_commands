local EFFECT_NAME = "RandomSounds"
local POOL_SIZE = 100 -- Smaller pool sizes help reduce lag from loading new sounds on the fly (most notable with footsteps).
local POOL_BATCH_SIZE = 10 -- Builds up the pool in batches over time, since it requires sounds to be loaded to see if they're good.
local POOL_BATCH_INTERVAL = 1
local SOUND_DURATION_MAX = 5


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local allSounds = nil
local allSoundsLength = nil
local poolSounds = {}
local poolSoundsLength = nil
local poolSoundsTargetLength = nil
local entityMeta = FindMetaTable( "Entity" )

local mathRandom = math.random
local stringFind = string.find
local soundDuration = SoundDuration


local function getSound()
    return poolSounds[mathRandom( 1, poolSoundsLength )]
end

local function getSoundForPool()
    local attempts = 10
    local snd = nil

    while attempts > 0 do
        snd = allSounds[mathRandom( 1, allSoundsLength )]

        -- Not perfect, but covers a lot of cases.
        local isBad =
            stringFind( snd, "loop" ) or
            soundDuration( snd ) > SOUND_DURATION_MAX

        if isBad then
            attempts = attempts - 1
        else
            break
        end
    end

    return snd
end

local function addBatchToPool()
    local i = poolSoundsLength + 1
    local max = math.min( i + POOL_BATCH_SIZE - 1, poolSoundsTargetLength )

    while i <= max do
        poolSounds[i] = getSoundForPool()
        i = i + 1
    end

    poolSoundsLength = max
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        allSounds = CFCUlxCurse.MarchFolderCached( "sound", "GAME", false, true )
        allSoundsLength = #allSounds

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
    excludeFromOnetime = nil,
    incompatibileEffects = {},
    groups = {
        "Wrap:Sound",
    },
    incompatibleGroups = {
        "Wrap:Sound",
    },
} )
