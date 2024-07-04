CFCUlxCurse = CFCUlxCurse or {}
CFCUlxCurse._marchFolderCache = CFCUlxCurse._marchFolderCache or {}
CFCUlxCurse._marchFolderCacheDroppedRoot = CFCUlxCurse._marchFolderCacheDroppedRoot or {}


local marchFolderCache = CFCUlxCurse._marchFolderCache
local marchFolderCacheDroppedRoot = CFCUlxCurse._marchFolderCacheDroppedRoot

local fileFind = file.Find
local tableInsert = table.insert
local stringSub = string.sub


--- Recursively gathers a list of all files in a given directory
--- (Includes the full file path and extension for each file)
---
--- @param folder string The folder to match, excluding the trailing slash (e.g. "sound", "models", etc.)
--- @param path string Search Path (e.g. "GAME", "DATA", etc.)
--- @param out? table The table to append the file paths to
--- @returns string[] out The collected file paths
function CFCUlxCurse.MarchFolder( folder, path, out )
    folder = folder .. "/"
    out = out or {}

    local fileNames, folderNames = fileFind( folder .. "*", path )

    for _, fileName in ipairs( fileNames ) do
        tableInsert( out, folder .. fileName )
    end

    for _, folderName in ipairs( folderNames ) do
        CFCUlxCurse.MarchFolder( folder .. folderName, path, out )
    end

    return out
end

--- Recursively gathers a list of all files in a given directory and caches the result
--- @param folder string The folder to match, excluding the trailing slash (e.g. "sound", "models", etc.)
--- @param path string Search Path (e.g. "GAME", "DATA", etc.)
--- @param forceRecache boolean? Whether or not to skip the cache (default: false)
--- @param dropRoot boolean? Whether or not to drop the first folder from each file path
--- @return string[] out The collected file paths
function CFCUlxCurse.MarchFolderCached( folder, path, forceRecache, dropRoot )
    local mainCache = dropRoot and marchFolderCacheDroppedRoot or marchFolderCache
    local perPathCache = mainCache[path]

    if not perPathCache then
        perPathCache = {}
        mainCache[path] = perPathCache
    end

    local cached = perPathCache[folder]
    if cached and not forceRecache then return cached end

    local out = CFCUlxCurse.MarchFolder( folder, path )

    perPathCache[folder] = out

    if dropRoot then
        local subStart = #folder + 2

        for i = 1, #out do
            out[i] = stringSub( out[i], subStart )
        end
    end

    return out
end


----- SETUP -----

net.Receive( "CFC_ULXCommands_Curse_StartEffect", function()
    local effectName = net.ReadString()
    local effectData = CFCUlxCurse.GetEffectByName( effectName )
    if not effectData then return end

    local startTime = net.ReadFloat()
    local duration = net.ReadFloat()

    local ply = LocalPlayer()
    local curseEffects = CFCUlxCurse.GetCurrentEffects( ply )

    curseEffects[effectName] = {
        effectData = effectData,
        expireTime = startTime + duration,
    }

    ProtectedCall( function()
        effectData.onStart( ply, startTime, duration )
    end )
end )

net.Receive( "CFC_ULXCommands_Curse_EndEffect", function()
    local effectName = net.ReadString()
    local effectData = CFCUlxCurse.GetEffectByName( effectName )
    if not effectData then return end

    local ply = LocalPlayer()
    local curseEffects = CFCUlxCurse.GetCurrentEffects( ply )

    curseEffects[effectName] = nil

    ProtectedCall( function()
        effectData.onEnd( ply )
    end )

    CFCUlxCurse.RemoveEffectHooks( ply, effectName )
    CFCUlxCurse.RemoveEffectTimers( ply, effectName )
end )
