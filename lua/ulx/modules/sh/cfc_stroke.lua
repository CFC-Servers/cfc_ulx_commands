CFCUlxCommands.stroke = CFCUlxCommands.stroke or {}

local CATEGORY_NAME = "Fun"

local wordTransformations = {
    -- Will replace the word.
    -- If more than one word is returned, the additional words will be randomly inserted into the original sentence.
    function( word )
        -- Add "y" to the end of the word
        return word .. "y"
    end,
    function( word )
        -- Repeat last letter
        return word .. string.sub( word, -1 )
    end,
    function( word )
        -- Remove last letter
        return string.sub( word, 1, -2 )
    end,
    function( word )
        -- Add "ing" to the end of the word
        return word .. "ing"
    end,
    function( word )
        -- Duplicate random letter
        local rand = math.random( 1, #word )
        local ind = math.random( 1, #word - 1 )
        return string.sub( word, 1, ind ) .. string.sub( word, rand, rand ) .. string.sub( word, ind + 1 )
    end,
    function( word )
        -- Remove vowels
        word = string.gsub( word, "[AEIOUaeiou]", "" )
        return word
    end,
    function( word )
        -- Remove word
        return ""
    end,
    function( word )
        -- Uppercase
        return string.upper( word )
    end,
    function( word )
        -- Repeat word
        return word .. " " .. word
    end,
    function( word )
        -- Repeat word elsewhere in the sentence
        return word, word
    end,
    function( word )
        -- Replace word with "um" or "uh"
        return math.random() < 0.5 and "um" or "uh"
    end,
    function( word )
        -- Insert a question mark at the end of the word
        return word .. "?"
    end,
    function( word )
        -- Remove a random letter
        local rand = math.random( 1, #word )
        return string.sub( word, 1, rand - 1 ) .. string.sub( word, rand + 1 )
    end,
}

local wordStrokeChance = 0.5


local function getWordTransformation()
    return wordTransformations[math.random( 1, #wordTransformations )]
end

local function transform( sentence )
    local transformedWords = {}
    local words = string.Split( sentence, " " )

    while #words ~= 0 do
        local word = table.remove( words, 1 )
        local shouldStroke = math.random() < wordStrokeChance

        if shouldStroke then
            local transformationResult = { getWordTransformation()( word, transformedWords ) }
            local transformedWord = table.remove( transformationResult, 1 )

            if transformedWord ~= "" then
                table.insert( transformedWords, transformedWord )
            end

            for _, additionalWord in ipairs( transformationResult ) do
                -- Insert additional words at a random position in the original sentence
                local rand = math.random( 1, #words + 1 )
                table.insert( words, rand, additionalWord )
            end
        else
            table.insert( transformedWords, word )
        end
    end

    -- Shuffle a random amount of words
    for _ = 1, math.random( 0, math.floor( #transformedWords / 2 ) ) do
        local ind1 = math.random( 1, #transformedWords )
        local ind2 = math.random( 1, #transformedWords )

        transformedWords[ind1], transformedWords[ind2] = transformedWords[ind2], transformedWords[ind1]
    end

    return table.concat(  transformedWords, " " )
end

local targetedPlayers = {}
hook.Add( "PlayerSay", "CFC_StrokeSpeech", function( ply, msg )
    if not targetedPlayers[ply] then return end
    return transform( msg )
end )

local function setStroke( caller, targetPlayers, unSet )
    local shouldSet = not unSet

    for _, ply in ipairs( targetPlayers ) do
        if shouldSet then
            targetedPlayers[ply] = true
        else
            targetedPlayers[ply] = nil
        end
    end

    ulx.fancyLogAdmin( caller, shouldSet and "#A gave #T a stroke" or "#A cured #T's stroke", targetPlayers )
end


local stroke = ulx.command( CATEGORY_NAME, "ulx stroke", setStroke, "!stroke" )
stroke:defaultAccess( ULib.ACCESS_ADMIN )
stroke:addParam( { type = ULib.cmds.PlayersArg } )
stroke:addParam( { type = ULib.cmds.BoolArg, invisible = true } )
stroke:help( "Gives the affected user a stroke" )
stroke:setOpposite( "ulx unstroke", { nil, nil, true }, "!unstroke" )
