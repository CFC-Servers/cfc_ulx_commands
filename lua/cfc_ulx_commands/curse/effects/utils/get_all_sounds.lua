local lib = {}

local SOUND_DURATION_MAX = 4
local BAD_FOLDERS = {
    ["synth"] = true,
    ["music"] = true,
    ["alarms"] = true,
    ["ambience"] = true,
    ["atmosphere"] = true,
    ["chatter"] = true,
    ["explosions"] = true,
    ["fire"] = true,
    ["gas"] = true,
    ["intro"] = true,
    ["tones"] = true,
    ["wind"] = true,
    ["apache"] = true,
    ["commentary"] = true,
}

local allSounds = nil
local allSoundsLength = nil

local math_random = math.random
local string_find = string.find
local string_sub = string.sub
local G_SoundDuration = SoundDuration

local isSoundGood


-- Acquires all sounds from the sound folder and returns them. Uses caching.
-- Must be called at least once before any other functions in this library.
function lib.GetSounds()
    if allSounds then return allSounds end

    -- March folders and filter out bad sounds that can be identified without loading them.
    allSounds = CFCUlxCurse.MarchFolderFiltered(
        "sound",
        "GAME",
        function( _, fileName )
            if string_find( fileName, "loop" ) then return false end
            if string_find( fileName, "lp" ) then return false end
            if string_find( fileName, "idle" ) then return false end
            if string_find( fileName, "hum" ) then return false end

            return true
        end,
        function( _, folderName )
            if BAD_FOLDERS[folderName] then return false end

            return true
        end,
        out
    )

    -- Remove the leading "sound/" from each sound path.
    local subStart = string.len( "sound/" ) + 1

    for i = 1, #allSounds do
        allSounds[i] = string_sub( allSounds[i], subStart )
    end

    allSoundsLength = #allSounds

    return allSounds
end

-- Gets a random sound from the list, avoiding sounds that are too long.
-- Has to load sounds from disk to check the duration, so use carefully.
function lib.SampleSound( attemptLimit )
    attemptLimit = attemptLimit or 10
    local snd

    -- Must provide a sound every time, so allow bad sounds to be used if no good ones are found in the limit.
    -- Want to minimize hotloading tons of sound files, since it uses disk time.
    for _ = 1, attemptLimit do
        snd = allSounds[math_random( 1, allSoundsLength )]
        if isSoundGood( snd ) then break end
    end

    return snd
end


----- PRIVATE FUNCTIONS -----

-- Checks if a sound is good to use for the sound pool, loading the sound from disk.
isSoundGood = function( snd )
    if G_SoundDuration( snd ) > SOUND_DURATION_MAX then return false end

    return true
end


return lib
