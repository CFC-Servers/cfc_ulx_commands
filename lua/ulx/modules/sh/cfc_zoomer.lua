local transformations = {
    ["hello"] = "yo",
    ["hi"] = "sup",
    ["friend"] = "homie",
    ["house"] = "crib",
    ["school"] = "skool",
    ["great"] = "lit",
    ["good"] = "dope",
    ["cool"] = "fire",
    ["okay"] = "aight",
    ["toilet"] = "skibbity toilet",
    ["Ohio"] = "Ohio meme central",
    ["beautiful"] = "gyatt",
    ["charisma"] = "rizz",
    ["awesome"] = "sick",
    ["amazing"] = "crazy",
    ["wow"] = "bruh",
    ["you"] = "u",
    ["your"] = "ur",
    ["for"] = "4",
    ["and"] = "n",
    ["are"] = "r",
    ["what"] = "wut",
    ["why"] = "y",
    ["this"] = "dis",
    ["that"] = "dat",
    ["with"] = "wit",
    ["have"] = "got",
    ["doing"] = "doin'",
    ["today"] = "2day"
}

local randomPhrases = {
    "skibbity", "toilet", "ohio", "gyatt", "rizz", "lit", "fam", "yeet", "sussy", "baka",
    "based", "cringe", "sus", "Livvy Dunne", "Baby Gronk", "rizzed up", "no cap", "on God",
    "vibe check", "frfr", "bet", "slaps", "drip", "cap", "fire", "savage", "lowkey", "highkey"
}

local function transform( sentence )
    sentence = string.lower( sentence )

    for word, replacement in pairs( transformations ) do
        sentence = string.gsub( sentence, "%f[%a]" .. word .. "%f[%A]", replacement )
    end

    sentence = string.gsub( sentence, "ing", "in'" )
    sentence = string.gsub( sentence, "er", "a" )
    sentence = string.gsub( sentence, "the", "da" )

    local transformedWords = {}
    for word in sentence:gmatch( "%S+" ) do
        table.insert( transformedWords, word )
        if math.random() < 0.4 then -- Adjust the probability for inserting random phrases
            table.insert( transformedWords, randomPhrases[math.random( #randomPhrases )] )
        end
    end

    return table.concat( transformedWords, " " )
end

local targettedPlayers = {}
hook.Add( "PlayerSay", "CFC_ZoomerSpeech", function( ply, msg )
    if not targettedPlayers[ply] then return end
    return transform( msg )
end )

local function setZoomer( caller, targetPlayers, unSet )
    local shouldSet = not unSet
    print( targetPlayers, type( targetPlayers ) )
    for _, ply in ipairs( targetPlayers ) do
        if shouldSet then
            targettedPlayers[ply] = true
        else
            targettedPlayers[ply] = nil
        end
    end

    ulx.fancyLogAdmin( caller, shouldSet and "#A gave brainrot to #T" or "#A removed brainrot from #T", targetPlayers )
end

local zoomer = ulx.command( "Fun", "ulx zoomer", setZoomer, "!zoomer" )
zoomer:defaultAccess( ULib.ACCESS_ADMIN )
zoomer:addParam( { type = ULib.cmds.PlayersArg } )
zoomer:addParam( { type = ULib.cmds.BoolArg, invisible = true } )
zoomer:help( "Gives the affected user brainrot" )
zoomer:setOpposite( "ulx unzoomer", { nil, nil, true }, "!unzoomer" )
