local EFFECT_NAME = "Fish"
local MAIN_SOUND = "cfc_ulx_commands/curse/fish/fish.ogg"
local SPECIAL_SOUND = "cfc_ulx_commands/curse/fish/you_know_what_that_means.ogg"
local SPECIAL_SOUND_CHANCE = 0.01
local SPECIAL_SOUND_COOLDOWN = 10
local START_DELAY = 1.5


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local nextSpecialSoundTime = 0
local entityMeta = FindMetaTable( "Entity" )


local function getSound( _snd )
    local now = CurTime()

    if now > nextSpecialSoundTime and math.Rand( 0, 1 ) < SPECIAL_SOUND_CHANCE then
        nextSpecialSoundTime = now + SPECIAL_SOUND_COOLDOWN

        return SPECIAL_SOUND
    end

    return MAIN_SOUND
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        globals.CreateSound = globals.CreateSound or CreateSound
        globals.EmitSound = globals.EmitSound or EmitSound
        globals.SoundDuration = globals.SoundDuration or SoundDuration
        globals.EntityEmitSound = globals.EntityEmitSound or entityMeta.EmitSound
        globals.soundPlay = globals.soundPlay or sound.Play
        globals.soundPlayFile = globals.soundPlayFile or sound.PlayFile
        globals.surfacePlaySound = globals.surfacePlaySound or surface.PlaySound

        -- Stop everything and play the special sound first
        RunConsoleCommand( "stopsound" )
        timer.Simple( 0.1, function() -- Account for concmd delay
            globals.surfacePlaySound( SPECIAL_SOUND )
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "DelayTheFishening", START_DELAY, 0, function()
            CreateSound = function( ent, _snd, ... )
                return globals.CreateSound( ent, getSound(), ... )
            end

            EmitSound = function( _snd, ... )
                globals.EmitSound( getSound(), ... )
            end

            SoundDuration = function()
                return globals.SoundDuration( getSound() )
            end

            entityMeta.EmitSound = function( self, _snd, ... )
                globals.EntityEmitSound( self, getSound(), ... )
            end

            sound.Play = function( _snd, ... )
                globals.soundPlay( getSound( _snd ), ... )
            end

            sound.PlayFile = function( _snd, ... )
                -- sound.PlayFile() expects the leading "sound/"
                globals.soundPlayFile( "sound/" .. getSound(), ... )
            end

            surface.PlaySound = function()
                globals.surfacePlaySound( getSound() )
            end

            -- Footsteps are played at the engine level, need to block them and call from lua for the wrap to apply.
            CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerFootstep", "OverrideSound", function( ply, _, _, snd, volume )
                ply:EmitSound( snd, nil, nil, volume )

                return true
            end )
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
