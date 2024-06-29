local EFFECT_NAME = "SoundShuffle"


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local allSounds = nil
local soundLookup = {}
local entityMeta = FindMetaTable( "Entity" )

local mathRandom = math.random


local function getSound( snd )
    return soundLookup[snd] or snd
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        allSounds = CFCUlxCurse.MarchFolderCached( "sound", "GAME", false, true )

        local allSoundsLength = #allSounds

        for i = 1, allSoundsLength do
            local snd = allSounds[i]
            soundLookup[snd] = allSounds[mathRandom( 1, allSoundsLength )]
        end

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
