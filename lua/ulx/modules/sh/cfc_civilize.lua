local transformations = {
    ["hello"] = "greetings",
    ["hi"] = "salutations",
    ["hey"] = "good day",
    ["friend"] = "dear acquaintance",
    ["buddy"] = "esteemed companion",
    ["pal"] = "cherished confidant",
    ["house"] = "manor",
    ["home"] = "estate",
    ["school"] = "institution of higher learning",
    ["work"] = "professional endeavors",
    ["job"] = "occupation",
    ["great"] = "splendid",
    ["good"] = "exquisite",
    ["nice"] = "delightful",
    ["cool"] = "marvelous",
    ["awesome"] = "magnificent",
    ["amazing"] = "astonishing",
    ["wow"] = "good heavens",
    ["okay"] = "acceptable",
    ["fine"] = "satisfactory",
    ["toilet"] = "lavatory",
    ["skibidi"] = "lavatory creature",
    ["ohio"] = "the US state of Ohio",
    ["sigma"] = "person of elevated charisma",
    ["rizz"] = "charisma",
    ["gyatt"] = "posterior",
    ["bathroom"] = "powder room",
    ["beautiful"] = "ravishing",
    ["pretty"] = "comely",
    ["handsome"] = "dashing",
    ["charisma"] = "charm",
    ["charm"] = "allure",
    ["awesome"] = "magnificent",
    ["amazing"] = "astonishing",
    ["wow"] = "good heavens",
    ["you"] = "thou",
    ["your"] = "thy",
    ["yours"] = "thine",
    ["for"] = "on behalf of",
    ["and"] = "as well as",
    ["are"] = "art",
    ["what"] = "pardon",
    ["why"] = "for what reason",
    ["with"] = "alongside",
    ["have"] = "possess",
    ["has"] = "possesses",
    ["doing"] = "engaging in",
    ["today"] = "this fine day",
    ["tonight"] = "this splendid evening",
    ["tomorrow"] = "the morrow",
    ["yesterday"] = "the day prior",
    ["money"] = "currency",
    ["cash"] = "legal tender",
    ["food"] = "cuisine",
    ["drink"] = "beverage",
    ["car"] = "automobile",
    ["bike"] = "bicycle",
    ["phone"] = "telephone",
    ["computer"] = "electronic device",
    ["game"] = "pastime",
    ["fun"] = "amusement",
    ["lol"] = "I am thoroughly amused",
    ["lmao"] = "I am in stitches",
    ["rofl"] = "I am rolling on the floor in delight",
    ["brb"] = "I shall return momentarily",
    ["gtg"] = "I must take my leave",
    ["omg"] = "oh my goodness",
    ["wtf"] = "what on earth",
    ["idk"] = "I am uncertain",
    ["smh"] = "I am shaking my head in disbelief",
    ["tbh"] = "to be perfectly honest",
    ["imo"] = "in my esteemed opinion",
    ["btw"] = "by the way",
    ["fyi"] = "for your information",
    ["irl"] = "in the real world",
    ["afk"] = "away from the keyboard",
    ["np"] = "it is no trouble at all",
    ["thx"] = "many thanks",
    ["pls"] = "if you would be so kind",
    ["please"] = "if you would be so kind",
    ["sorry"] = "I humbly apologize",
    ["thanks"] = "I extend my gratitude",
    ["thank you"] = "I am deeply grateful",
    ["yes"] = "indeed",
    ["no"] = "certainly not",
    ["maybe"] = "perhaps",
    ["later"] = "at a more convenient time",
    ["soon"] = "in the near future",
    ["never"] = "under no circumstances",
    ["always"] = "without fail",
    ["everyone"] = "all present",
    ["someone"] = "a certain individual",
    ["anyone"] = "any given person",
    ["everything"] = "all that exists",
    ["something"] = "a particular thing",
    ["anything"] = "any given thing",
    ["nothing"] = "absolutely nothing",
    ["here"] = "in this location",
    ["there"] = "in that location",
    ["everywhere"] = "in all locations",
    ["somewhere"] = "in a certain location",
    ["anywhere"] = "in any location",
    ["nowhere"] = "in no location",
    ["because"] = "due to the fact that",
    ["so"] = "therefore",
    ["but"] = "however",
    ["if"] = "should it be the case that",
    ["then"] = "at that time",
    ["when"] = "at the time that",
    ["where"] = "in the place that",
    ["why"] = "for what reason",
    ["how"] = "in what manner",
    ["who"] = "which individual",
    ["what"] = "which thing",
    ["which"] = "which particular one",
    ["whose"] = "to whom does it belong",
    ["whom"] = "to which individual",
    ["whose"] = "to whom does it belong",
    ["mine"] = "my own",
    ["yours"] = "your own",
    ["his"] = "his own",
    ["hers"] = "her own",
    ["theirs"] = "their own",
    ["ours"] = "our own",
    ["me"] = "my own person",
    ["myself"] = "my own person",
    ["yourself"] = "your own person",
    ["himself"] = "his own person",
    ["herself"] = "her own person",
    ["themselves"] = "their own persons",
    ["ourselves"] = "our own persons",
    ["everybody"] = "all individuals",
    ["somebody"] = "a certain individual",
    ["anybody"] = "any given individual",
    ["nobody"] = "no individual",
    ["everything"] = "all that exists",
    ["something"] = "a particular thing",
    ["anything"] = "any given thing",
    ["nothing"] = "absolutely nothing",
    ["everywhere"] = "in all locations",
    ["somewhere"] = "in a certain location",
    ["anywhere"] = "in any location",
    ["nowhere"] = "in no location",
    ["everyday"] = "each and every day",
    ["sometimes"] = "on occasion",
    ["anytime"] = "at any given time",
    ["never"] = "under no circumstances",
    ["always"] = "without fail",
    ["forever"] = "for all eternity",
    ["soon"] = "in the near future",
    ["later"] = "at a more convenient time",
    ["now"] = "at this very moment",
    ["then"] = "at that time",
    ["today"] = "this fine day",
    ["tonight"] = "this splendid evening",
    ["tomorrow"] = "the morrow",
    ["yesterday"] = "the day prior",
    ["week"] = "a period of seven days",
    ["month"] = "a period of thirty days",
    ["year"] = "a period of three hundred and sixty-five days",
    ["time"] = "the indefinite continued progress of existence",
    ["life"] = "the condition that distinguishes animals and plants from inorganic matter",
    ["death"] = "the cessation of life",
    ["love"] = "an intense feeling of deep affection",
    ["hate"] = "feel an intense feeling of dislike",
    ["happy"] = "feeling or showing pleasure or contentment",
    ["sad"] = "feeling or showing sorrow",
    ["angry"] = "feeling or showing strong annoyance",
    ["excited"] = "feeling or showing enthusiasm",
    ["bored"] = "feeling weary because one is unoccupied",
    ["tired"] = "in need of sleep or rest",
    ["hungry"] = "feeling the need to eat",
    ["thirsty"] = "feeling the need to drink",
    ["hot"] = "having a high degree of heat",
    ["cold"] = "having a low degree of heat",
    ["big"] = "of considerable size",
    ["small"] = "of a size that is less than normal",
    ["large"] = "of considerable size",
    ["tiny"] = "very small",
    ["huge"] = "extremely large",
    ["enormous"] = "very large",
    ["gigantic"] = "extremely large",
    ["massive"] = "exceptionally large",
    ["little"] = "small in size",
    ["few"] = "a small number of",
    ["many"] = "a large number of",
    ["several"] = "more than a few but not many",
    ["some"] = "an unspecified amount or number of",
    ["any"] = "one or some of a thing",
    ["all"] = "the whole quantity of",
    ["no clue"] = "the faintest idea",
    ["help"] = "provide assistance",
    ["like"] = "as it were",
    ["sucks"] = "is rather dissapointing",
    ["literally"] = "quite exactly",
    ["well"] = "it has come to my attention",
    ["can't"] = "am unable to",
    ["talk"] = "communicate",
    ["speak"] = "express thyself",
    ["1984"] = "George Orwell's Ninteen Eighty-Four",
    ["abuse"] = "quite overreaching",
    ["guys"] = "fellows",
    ["kidding"] = "pulling letgs",
    ["chat"] = "speaking method",
    ["die"] = "ceace your continued existence",
    ["admin"] = "person of elevated privilieges",
    ["admins"] = "persons of elevated privilieges",
    ["demote"] = "reduce to lower priviliges",
    ["demoted"] = "reduced to lower priviliges",
    ["staff"] = "persons of elevated priviliges",
    ["stop"] = "cease at once",
    ["kill"] = "bring upon their end",
    ["killing"] = "bringing upon the end of one's existance",
    ["bruh"] = "my good fellow",
    ["bro"] = "my brother",
    ["dude"] = "my fellow individual",
    -- Savage insults and vulgarities
    ["hell"] = "brimstone",
    ["balls"] = "round spheroids",
    ["idiot"] = "intellectually challenged individual",
    ["stupid"] = "lacking in cognitive fortitude",
    ["dumb"] = "mentally unencumbered",
    ["noob"] = "novice enthusiast",
    ["rekt"] = "thoroughly outmaneuvered",
    ["kill yourself"] = "I suggest you reconsider your life choices",
    ["stfu"] = "kindly cease your verbal emissions",
    ["shut up"] = "I humbly request your silence",
    ["tf"] = "the fumpernickle",
    ["fuck"] = "fornicate",
    ["shit"] = "excrement",
    ["damn"] = "drat",
    ["crap"] = "unfortunate circumstance",
    ["ass"] = "posterior",
    ["bitch"] = "unpleasant individual",
    ["bastard"] = "person of questionable lineage",
    ["whore"] = "individual of negotiable affection",
    ["slut"] = "person with a liberated lifestyle",
    ["dick"] = "male anatomical reference",
    ["pussy"] = "individual lacking fortitude",
    ["wanker"] = "self-indulgent individual",
    ["cunt"] = "person of disagreeable demeanor",
    ["fag"] = "individual of alternative persuasion",
    ["nigger"] = "person of African descent",
    ["niggers"] = "people of African descent",
    ["retard"] = "person with developmental challenges",
    ["retarded"] = "of developmental challenges",
    ["ugly"] = "aesthetically unremarkable",
    ["fat"] = "gravitationally gifted",
    ["skinny"] = "svelte",
    ["gay"] = "homosexually inclined",
    ["lesbian"] = "same-gender loving individual",
    ["tranny"] = "transgender individual",
    ["kys"] = "I urge you to seek professional assistance",
    ["goon"] = "henchman",
    ["sex"] = "reproduction",
}

local randomPhrases = {
    "indubitably", "quite so", "indeed", "precisely", "absolutely", "certainly", "of course", "by all means",
    "most assuredly", "without a doubt", "undoubtedly", "positively", "naturally", "clearly", "obviously",
    "evidently", "apparently", "seemingly", "presumably", "supposedly", "allegedly", "reportedly", "ostensibly",
    "I dare say", "I must confess", "if I may be so bold", "if you would be so kind", "as it were", "as one might expect",
    "as the saying goes", "in any case", "in point of fact", "in all likelihood", "in the grand scheme of things",
    "to be perfectly frank", "to put it mildly", "to say the least", "to my utmost delight", "to my great astonishment",
    "it seems to be", "quite assuredly", "undoubtably", "yes, of course", "unexpectedly",
}

local function transform( sentence )
    sentence = string.lower( sentence )

    local replaceCount = 0

    for word, replacement in pairs( transformations ) do
        local amountFound
        sentence, amountFound = string.gsub( sentence, "%f[%g]" .. word .. "%f[%G]", replacement )

        replaceCount = replaceCount + amountFound
    end

    local minAddCount = 0
    local randomAddChance = 0.05
    if replaceCount <= 1 then -- if no replacements were found, add lots of crap
        randomAddChance = 0.5
        minAddCount = 1 -- always add ONE thing
    end

    local addCount = 0
    local transformedWords = {}
    for word in sentence:gmatch( "%S+" ) do
        table.insert( transformedWords, word )

        if math.random() < randomAddChance or addCount < minAddCount then
            addCount = addCount + 1
            table.insert( transformedWords, randomPhrases[math.random( #randomPhrases )] )
        end
    end

    return table.concat( transformedWords, " " )
end

local targetedPlayers = {}
hook.Add( "PlayerSay", "CFC_PoshSpeech", function( ply, msg )
    if not targetedPlayers[ply] then return end
    return transform( msg )
end )

local function setPosh( caller, targetPlayers, unSet )
    local shouldSet = not unSet
    for _, ply in ipairs( targetPlayers ) do
        if shouldSet then
            targetedPlayers[ply] = true
        else
            targetedPlayers[ply] = nil
        end
    end

    local message = shouldSet and "#A bestowed sophistication upon #T" or "#A returned #T to a more primitive state"

    ulx.fancyLogAdmin( caller, message, targetPlayers )
end

local civilize = ulx.command( "Fun", "ulx civilize", setPosh, "!civilize" )
civilize:defaultAccess( ULib.ACCESS_ADMIN )
civilize:addParam( { type = ULib.cmds.PlayersArg } )
civilize:addParam( { type = ULib.cmds.BoolArg, invisible = true } )
civilize:help( "Bestows the affected user with sophistication" )
civilize:setOpposite( "ulx uncivilize", { nil, nil, true }, "!uncivilize" )
