local EFFECT_NAME = "SoundShuffle"


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local libGetAllSounds = CFCUlxCurse.IncludeEffectUtil( "get_all_sounds" )

local soundLookup = {}
local entityMeta = FindMetaTable( "Entity" )
local stringSubStartToRemoveSoundFolder = string.len( "sound/" ) + 1

local string_sub = string.sub


local function getSound( snd )
    local replacement = soundLookup[snd]
    if replacement then return replacement end -- Already shuffled, maintain the same replacement.

    -- Only shuffle sounds as needed, not all at once.
    replacement = libGetAllSounds.SampleSound()
    soundLookup[snd] = replacement

    return replacement
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        libGetAllSounds.GetSounds()

        globals.CreateSound = globals.CreateSound or CreateSound
        globals.EmitSound = globals.EmitSound or EmitSound
        globals.SoundDuration = globals.SoundDuration or SoundDuration
        globals.EntityEmitSound = globals.EntityEmitSound or entityMeta.EmitSound
        globals.soundPlay = globals.soundPlay or sound.Play
        globals.soundPlayFile = globals.soundPlayFile or sound.PlayFile
        globals.surfacePlaySound = globals.surfacePlaySound or surface.PlaySound

        CreateSound = function( ent, snd, ... )
            return globals.CreateSound( ent, getSound( snd ), ... )
        end

        EmitSound = function( snd, ... )
            globals.EmitSound( getSound( snd ), ... )
        end

        SoundDuration = function( snd )
            return globals.SoundDuration( getSound( snd ) )
        end

        entityMeta.EmitSound = function( self, snd, ... )
            globals.EntityEmitSound( self, getSound( snd ), ... )
        end

        sound.Play = function( snd, ... )
            globals.soundPlay( getSound( snd ), ... )
        end

        sound.PlayFile = function( snd, ... )
            -- sound.PlayFile() expects the leading "sound/"
            snd = string_sub( snd, stringSubStartToRemoveSoundFolder )
            globals.soundPlayFile( "sound/" .. getSound( snd ), ... )
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
        sound.PlayFile = globals.soundPlayFile
        surface.PlaySound = globals.surfacePlaySound

        RunConsoleCommand( "stopsound" )

        table.Empty( soundLookup )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
    incompatibileEffects = {},
    groups = {
        "Wrap:Sound",
    },
    incompatibleGroups = {
        "Wrap:Sound",
    },
} )
