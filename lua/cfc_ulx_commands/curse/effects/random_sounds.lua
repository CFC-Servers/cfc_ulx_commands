local EFFECT_NAME = "RandomSounds"
local POOL_SIZE = 100 -- Smaller pool sizes help reduce lag from loading new sounds on the fly (most notable with footsteps).
local SOUND_DURATION_MAX = 5


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local poolSounds = {}
local poolSoundsLength = nil
local entityMeta = FindMetaTable( "Entity" )

local mathRandom = math.random
local stringFind = string.find
local SoundDuration = SoundDuration


local function getSound()
    return poolSounds[mathRandom( 1, poolSoundsLength )]
end

local function getSoundForPool( allSounds, allSoundsLength )
    local attempts = 10
    local snd = nil

    while attempts > 0 do
        snd = allSounds[mathRandom( 1, allSoundsLength )]

        -- Not perfect, but covers a lot of cases.
        local isBad =
            stringFind( snd, "loop" ) or
            SoundDuration( snd ) > SOUND_DURATION_MAX

        if isBad then
            attempts = attempts - 1
        else
            break
        end
    end

    return snd
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        local allSounds = CFCUlxCurse.MarchFolderCached( "sound", "GAME", false, true )
        local allSoundsLength = #allSounds

        poolSoundsLength = math.min( #allSounds, POOL_SIZE )

        for i = 1, poolSoundsLength do
            poolSounds[i] = getSoundForPool( allSounds, allSoundsLength )
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
