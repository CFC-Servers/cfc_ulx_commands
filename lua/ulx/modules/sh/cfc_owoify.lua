CFCUlxCommands.owoify = CFCUlxCommands.owoify or {}
local cmd = CFCUlxCommands.owoify

local CATEGORY_NAME = "Chat"
local PHRASES_TO_APPEND = {
    " ^w^",
    " :3",
    " :3c",
    " ;;w;;",
    " x3",
    " owo",
    " nya~",
    " uwu",
    "~",
    "~ nyah"
}
local PHRASES_TO_REPLACE = {
    { "the worst server", "the hottest server" },
    { "die furries", "i love furries" },
    { "cope seethe mald", "live laugh love" },
    { "stop cry", "im cry" },
    { "fuck me", "love me" },
    { "n word", "nice word" },
    { "george floyd", "cotton candy" },
    { "get on my cock", "i need a therapist" },
    { "oh my god", "oh my,, god??!" },
    { "scum suck", "best love" },
    { "what the fuck is this", "what is this, i love ittt" },
    { "what the fuck", "omg~ whaaat?" },
    { "doxxed you", "exposed~ you" },
    { "get a job", "ill give you a job, wink wink" },
    { "did nothing wrong", "did so much wrong ~w~" },
    { "turn this off", "keep this on, i love this." },
    { "turn it off", "nya~ keep it on" },
    { "im not saying this", "im saying all of this" },
    { "my chat is broken", "i love this" },
    { "shut the fuck", "open right, nya," },
    { "shut up", "oh no" },
    { "admin abuse", "great teasing" },
    { " of shit", " of doodoo" },
    -- recipies end here
    { "helicopter", "the whtwhtwhtwhtwhtwht machine" },
    { "cringiest", "coolest" },
    { "swastika", "big mean windmill" },
    { "annoying", "hello" },
    { "abusive", "teasing" },
    { "dumbass", "uwu, dummy!!!" },
    { "average", "best" },
    { "furries", "furries~" },
    { "fucking", "fuck, nya" },
    { "abusing", "teasing" },
    { "gayest", "g-g-ayest~ owo" },
    { "doxxed", "exposed" },
    { "faggot", "thick stick pile" },
    { "hitler", "the big meanie" },
    { "retard", "uwu wetawd" },
    { "virgin", "virgin? B3" },
    { "broken", "perfect" },
    { "cringe", "cool" },
    { "semen", "a swim team" },
    { "mommy", "guardian" },
    { "penis", "wee-wee" },
    { "daddy", "parent" },
    { "hell ", "heaven" },
    { "broke", "fixed" },
    { "bitch", "honey" },
    { "nigg", "wigg" },
    { "mald ", "happy" }, 
    { "lmfao", "uwu" },
    { "cunt", "fackin mate" },
    { "doxx", "reveal?? :3" },
    { " dox", " expose ~uwu" },
    { "nazi", "meanie" },
    { "dick", "dongie" },
    { "cock", "weewee" },
    { "suck", "nuzzle" },
    { "scum", "bewst" },
    { "kill", "adore" },
    { "fuck", "fuck~" },
    { "rape", "love" },
    { "hate", "love" },
    { "piss", "pass" },
    { "cope", "love" },
    { "lmao", "uwu" },
    { "that", "dat" },
    { "stfu", "uwa" },
    { "mald", "lov" }, 
    { "gay", "beautiful" },
    { "fag", "hottie" },
    { "ass", "ass~" },
    { "sex", "love" },
    { "the", "tha" },
    { "lol", "uwu" },
    { "you", "nyu" },
    { "wtf", "~w~" },
    { "cum", "syrup" },
    -- word replacements end here
    { "tch", "tchie" },
    { "iyst", "iwst" },
    { "ist", "isht" },
    { "ism", "isem" },
    { "  ", "~ " },
    { "oo", "ew" },
    { "l", "w" },
    { "na", "nya" },
    { "ne", "nye" },
    { "ni", "nyi" },
    { "no", "nyo" },
    { "nu", "nyu" },
    { "ove", "uv" },
    { "r", "w" },
    { "tion", "shun" },
    { "wha", "wa" },
    { "whe", "we" },
    { "whi", "wi" },
}
local EASTER_EGGS = {
    { "owo", "owo what IS this??" }, 
    { "im nyot a fuwwy", "Thank you, I know who I am now, I always knew I could've been more. I am a furry, you showed me, you have my endless gratitude." },
    { "witewawwy 1984", "1984?~ awa, more wike~ nyaa, 1969!!!!" },
    { "1984", "ninteen sixty nyne ~u~" },
    { "owo wats this", "I revel through this soup they call life. My life held no joy, no flavor. All that changed when i finally accepted, that i am, a furry." },
    { "among us", "It began when among us first released, i noticed them everywhere, cars, trashcans, mailboxes. My life, reduced to a sexy, red haze, nowhere is truly safe now, not even my mind." },
    { " ", "spwaces ownly uwu" }
}
local SPOILED_EGGS = {}
local ID_OWO = 3

local function isNovelEgg( message, item )
    if message ~= item[1] then return end
    if SPOILED_EGGS[message] then return end
    if math.random( 0, 100 ) < 75 then return end
    return item[2]
end

local function doEasterEgg( message )  
    local out = message
    for _, item in pairs( EASTER_EGGS ) do
        local novelEgg = isNovelEgg( message, item )
        if novelEgg then
            SPOILED_EGGS[message] = true
            out = novelEgg
        end
    end
    return out
end

local function owoifyMessage( message )
    local owoifiedMessage = message
    for _, item in pairs( PHRASES_TO_REPLACE ) do
        local old = item[1]
        local new = item[2]
        owoifiedMessage = string.Replace( owoifiedMessage, old, new )
        owoifiedMessage = string.Replace( owoifiedMessage, string.upper( old ), string.upper( new ) )
    end
    local owoifiedMessage = doEasterEgg( owoifiedMessage )
    local owoifiedMessage = owoifiedMessage .. PHRASES_TO_APPEND[math.random( 1, #PHRASES_TO_APPEND )]

    return owoifiedMessage
end

local function onPlayerSay( ply, message )
    if ply.gimp ~= ID_OWO then return end
    local nextMessage = ply.nextOwoifySameMessage or 0
    if ply.lastOwoifyMessageSent == message and nextMessage > CurTime() then -- dumb spam filter to prevent minges from just speedspamming nothing
        return ""
    end
    local scale = math.random( 0, 8 ) -- sometimes no delay to keep em on their toes
    local time = 1 * scale
    ply.lastOwoifyMessageSent = message
    ply.nextOwoifySameMessage = CurTime() + time

    return owoifyMessage( message )
end

function cmd.owoifyCommand( caller, targets, shouldUnowoify )
    local shouldOwoify = not shouldUnowoify

    for _, ply in ipairs( targets ) do
        if shouldOwoify then
            ply.gimp = ID_OWO
        else
            ply.gimp = nil
        end
    end

    if shouldOwoify then
        ulx.fancyLogAdmin( caller, "#A owoified #T", targets )
    else
        ulx.fancyLogAdmin( caller, "#A unowoified #T", targets )
    end
end

hook.Add( "PlayerSay", "CFC_ULX_OwoifyString", onPlayerSay, HOOK_LOW )

local owoifyCommand = ulx.command( CATEGORY_NAME, "ulx owoify", cmd.owoifyCommand, { "!owoify", "!owo" } )
owoifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
owoifyCommand:help( "Owoifies target(s) so they are unable to chat normally." )
owoifyCommand:addParam{ type = ULib.cmds.PlayersArg }
owoifyCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
owoifyCommand:setOpposite( "ulx unowoify", {_, _, true}, { "!unowoify", "!unowo" } )
