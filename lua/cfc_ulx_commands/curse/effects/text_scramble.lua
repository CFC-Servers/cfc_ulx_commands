local EFFECT_NAME = "TextScramble"

--[[
    - Scrambles text drawn with surface.DrawText().
    - Doesn't modify chat.AddText(), print(), Msg(), etc. because they are all one-time functions and not for continuous rendering.
        - Otherwise, chat would stay scrambled even after the effect ends.
        - vgui (and in turn the spawn menu) is also unaffected due to being drawn at source-level.
--]]


-- Create global table
local EFFECT_NAME_LOWER = string.lower( EFFECT_NAME )
CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER] or {}
local globals = CFCUlxCurse.EffectGlobals[EFFECT_NAME_LOWER]

local scrambleText

if CLIENT then
    local alphabet = string.Split( "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "" )
    local alphabetLookup = {}
    local alphabetSize = #alphabet

    local numerals = string.Split( "1234567890", "" )
    local numeralLookup = {}
    local numeralCount = #numerals

    for _, letter in ipairs( alphabet ) do
        alphabetLookup[letter] = true
    end

    for _, numeral in ipairs( numerals ) do
        numeralLookup[numeral] = true
    end

    local stringSplit = string.Split
    local mathRandom = math.random


    scrambleText = function( text )
        local textNew = ""
        local chars = stringSplit( text, "" )

        for _, char in ipairs( chars ) do
            if alphabetLookup[char] then
                textNew = textNew .. alphabet[mathRandom( 1, alphabetSize )]
            elseif numeralLookup[char] then
                textNew = textNew .. numerals[mathRandom( 1, numeralCount )]
            else
                textNew = textNew .. char
            end
        end

        return textNew
    end
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        globals.surfaceDrawText = globals.surfaceDrawText or surface.DrawText

        surface.DrawText = function( text, ... )
            globals.surfaceDrawText( scrambleText( text ), ... )
        end
    end,

    onEnd = function()
        if SERVER then return end

        surface.DrawText = globals.surfaceDrawText
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
