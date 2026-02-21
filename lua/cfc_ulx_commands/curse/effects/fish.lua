local EFFECT_NAME = "Fish"

local START_DELAY = 1.5

local MAIN_SOUND = "cfc_ulx_commands/curse/fish/fish.ogg"
local SPECIAL_SOUND = "cfc_ulx_commands/curse/fish/you_know_what_that_means.ogg"
local SPECIAL_SOUND_CHANCE = 0.01
local SPECIAL_SOUND_COOLDOWN = 10

local WORD_REPLACE_CHANCE = 0.1


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local nextSpecialSoundTime = 0
local wordLookup = { [""] = "", ["s"] = "s", ["S"] = "S", }
local entityMeta = FindMetaTable( "Entity" )
local playerMeta = FindMetaTable( "Player" )

local CurTime = CurTime
local mathRand = math.Rand
local stringGmatch = string.gmatch
local stringSub = string.sub
local stringFind = string.find
local stringUpper = string.upper
local tableConcat = table.concat
local languageGetPhrase = CLIENT and language.GetPhrase

local fishifyText
local fishifyTextAny = function( arg ) return fishifyText( tostring( arg ) ) end

local consoleWrappers = { -- true to leave arg unmodified, otherwise uses a function.
    Msg = {
        default = fishifyTextAny,
        string = fishifyText,
    },
    MsgN = {
        default = fishifyTextAny,
        string = fishifyText,
    },
    MsgC = {
        default = fishifyTextAny,
        string = fishifyText,
        table = true,
    },
    MsgAll = {
        default = fishifyTextAny,
        string = fishifyText,
    },
    print = {
        default = fishifyTextAny,
        string = fishifyText,
    },
    AddText = {
        default = fishifyTextAny,
        string = fishifyText,
        table = true,
        Player = true,

        _container = "chat",
    },
}


local function getSound( _snd )
    local now = CurTime()

    if now > nextSpecialSoundTime and mathRand( 0, 1 ) < SPECIAL_SOUND_CHANCE then
        nextSpecialSoundTime = now + SPECIAL_SOUND_COOLDOWN

        return SPECIAL_SOUND
    end

    return MAIN_SOUND
end

local function replaceWord( word )
    local replacement = wordLookup[word]
    if replacement ~= nil then return replacement end

    if mathRand( 0, 1 ) < WORD_REPLACE_CHANCE then
        local firstChar = stringSub( word, 1, 1 )

        -- Maintain capitalization of first letter, and use full caps if the first two are uppercase.
        if firstChar == stringUpper( firstChar ) then
            local lastChar = stringSub( word, #word, #word )

            if lastChar == stringUpper( lastChar ) then
                replacement = "FISH"
            else
                replacement = "Fish"
            end
        else
            replacement = "fish"
        end
    else
        replacement = word
    end

    wordLookup[word] = replacement

    return replacement
end

fishifyText = function( str, isRecursing )
    local fragments = {}
    local count = 0

    -- Respect language phrases.
    if not isRecursing then
        local hashInd = stringFind( str, "#", 1, true )
        local endInd

        while hashInd do
            -- Find the next # and the index of the last non-space, non-control character following it.
            -- (i.e. the start and end of the next untranslated language phrase)
            hashInd, endInd = stringFind( str, "#[^%s%c]*", hashInd, false )
            if not hashInd then break end

            -- Translate, fishify, and reinsert the phrase.
            local internalPhrase = stringSub( str, hashInd + 1, endInd )
            local newPhrase = fishifyText( languageGetPhrase( internalPhrase ), true )

            str = stringSub( str, 1, hashInd - 1 ) .. newPhrase .. stringSub( str, endInd + 1 )
        end
    end

    -- Replace words separated by punctuation, spaces, and/or control characters.
    for nonword, word in stringGmatch( str, "([%c%p%s]*)([^%c%p%s]*)" ) do
        if nonword ~= "" then
            count = count + 1
            fragments[count] = nonword
        end

        count = count + 1
        fragments[count] = replaceWord( word )
    end

    return tableConcat( fragments ) -- At scale, table.concat produces considerably less garbage than manual concatenation.
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        if SERVER then return end

        -- Sound Functions
        globals.CreateSound = globals.CreateSound or CreateSound
        globals.EmitSound = globals.EmitSound or EmitSound
        globals.SoundDuration = globals.SoundDuration or SoundDuration
        globals.EntityEmitSound = globals.EntityEmitSound or entityMeta.EmitSound
        globals.soundPlay = globals.soundPlay or sound.Play
        globals.soundPlayFile = globals.soundPlayFile or sound.PlayFile
        globals.surfacePlaySound = globals.surfacePlaySound or surface.PlaySound

        -- String Functions
        globals.surfaceDrawText = globals.surfaceDrawText or surface.DrawText
        globals.surfaceGetTextSize = globals.surfaceGetTextSize or surface.GetTextSize

        -- Chat/Console Functions
        globals.Msg = globals.Msg or Msg
        globals.MsgN = globals.MsgN or MsgN
        globals.MsgC = globals.MsgC or MsgC
        globals.MsgAll = globals.MsgAll or MsgAll
        globals.print = globals.print or print
        globals.chatAddText = globals.chatAddText or chat.AddText

        globals.PrintMessage = globals.PrintMessage or PrintMessage
        globals.playerChatPrint = globals.playerChatPrint or playerMeta.ChatPrint
        globals.playerPrintMessage = globals.playerPrintMessage or playerMeta.PrintMessage


        -- Stop everything and play the special sound first
        RunConsoleCommand( "stopsound" )
        timer.Simple( 0.1, function() -- Account for concmd delay
            globals.surfacePlaySound( SPECIAL_SOUND )
        end )

        CFCUlxCurse.CreateEffectTimer( cursedPly, EFFECT_NAME, "DelayTheFishening", START_DELAY, 0, function()
            -- Sound Wraps
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


            -- String Wraps
            surface.DrawText = function( text, ... )
                globals.surfaceDrawText( fishifyText( text ), ... )
            end

            surface.GetTextSize = function( text, ... )
                return globals.surfaceGetTextSize( fishifyText( text ), ... )
            end


            -- Chat/Console Wraps
            for funcName, wrapsByType in pairs( consoleWrappers ) do
                local containerName = wrapsByType._container
                local container = containerName and _G[containerName] or _G
                local ogFunc = globals[( containerName or "" ) .. funcName]
                local defaultFunc = wrapsByType.default

                container[funcName] = function( ... )
                    local args = { ... }

                    for i = 1, #args do
                        local arg = args[i]
                        local wrapFunc = wrapsByType[type( arg )] or defaultFunc

                        if wrapFunc ~= true then
                            args[i] = wrapFunc( arg )
                        end
                    end

                    return ogFunc( unpack( args ) )
                end
            end

            PrintMessage = function( msgType, msg, ... )
                return globals.PrintMessage( msgType, fishifyText( msg ), ... )
            end

            playerMeta.ChatPrint = function( self, msg, ... )
                return globals.playerChatPrint( self, fishifyText( msg ), ... )
            end

            playerMeta.PrintMessage = function( self, msgType, msg, ... )
                return globals.playerPrintMessage( self, msgType, fishifyText( msg, ... ) )
            end


            -- Footsteps are played at the engine level, need to block them and call from lua for the wrap to apply.
            CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "PlayerFootstep", "OverrideSound", function( ply, _, _, snd, volume )
                ply:EmitSound( snd, nil, nil, volume )

                return true
            end )

            -- Covers a lot of cases that ENTITY:EmitSound() doesn't.
            CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "EntityEmitSound", "OverrideSound", function( data )
                data.SoundName = getSound( data.SoundName )

                return true
            end )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        -- Sound Unwrap
        CreateSound = globals.CreateSound
        EmitSound = globals.EmitSound
        SoundDuration = globals.SoundDuration
        entityMeta.EmitSound = globals.EntityEmitSound
        sound.Play = globals.soundPlay
        sound.PlayFile = globals.soundPlayFile
        surface.PlaySound = globals.surfacePlaySound

        -- String Unwrap
        surface.DrawText = globals.surfaceDrawText
        surface.GetTextSize = globals.surfaceGetTextSize

        -- Chat/Console Unwrap
        Msg = globals.Msg
        MsgN = globals.MsgN
        MsgC = globals.MsgC
        MsgAll = globals.MsgAll
        print = globals.print
        chat.AddText = globals.chatAddText

        PrintMessage = globals.PrintMessage
        playerMeta.ChatPrint = globals.playerChatPrint
        playerMeta.PrintMessage = globals.playerPrintMessage

        -- Cleanup
        RunConsoleCommand( "stopsound" )
        wordLookup = { [""] = "", ["s"] = "s", ["S"] = "S", } -- Discard the old table so gc can clean it.
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
