local EFFECT_NAME = "SoundShuffle"
local SOUND_DURATION_MAX = 5


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local soundLookup = {}
local allSounds = nil
local allSoundsLength = nil
local entityMeta = FindMetaTable( "Entity" )

local mathRandom = math.random
local stringFind = string.find
local soundDuration = globals.SoundDuration or SoundDuration


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

local function getSound( snd )
    local replacement = soundLookup[snd]

    -- Only shuffle sounds as needed, not all at once.
    if not replacement then
        replacement = getSoundForPool()
        soundLookup[snd] = replacement
    end

    return replacement
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        allSounds = CFCUlxCurse.MarchFolderCached( "sound", "GAME", false, true )
        allSoundsLength = #allSounds

        table.Empty( soundLookup )

        globals.CreateSound = globals.CreateSound or CreateSound
        globals.EmitSound = globals.EmitSound or EmitSound
        globals.SoundDuration = globals.SoundDuration or SoundDuration
        globals.EntityEmitSound = globals.EntityEmitSound or entityMeta.EmitSound
        globals.soundPlay = globals.soundPlay or sound.Play
        globals.surfacePlaySound = globals.surfacePlaySound or surface.PlaySound

        CreateSound = function( ent, snd, ... )
            globals.CreateSound( ent, getSound( snd ), ... )
        end

        EmitSound = function( snd, ... )
            globals.EmitSound( getSound( snd ), ... )
        end

        SoundDuration = function( snd )
            globals.SoundDuration( getSound( snd ) )
        end

        entityMeta.EmitSound = function( self, snd, ... )
            globals.EntityEmitSound( self, getSound( snd ), ... )
        end

        sound.Play = function( snd, ... )
            globals.soundPlay( getSound( snd ), ... )
        end

        surface.PlaySound = function( snd )
            globals.surfacePlaySound( getSound( snd ) )
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
        SoundDuration = globals.SoundDuration
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
