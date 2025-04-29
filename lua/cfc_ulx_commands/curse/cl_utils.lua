CFCUlxCurse = CFCUlxCurse or {}

local file_Find = file.Find
local table_insert = table.insert


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

    local fileNames, folderNames = file_Find( folder .. "*", path )

    for _, fileName in ipairs( fileNames ) do
        table_insert( out, folder .. fileName )
    end

    for _, folderName in ipairs( folderNames ) do
        CFCUlxCurse.MarchFolder( folder .. folderName, path, out )
    end

    return out
end

--- Recursively gathers a list of all files in a given directory, filtered by functions
--- (Includes the full file path and extension for each file)
---
--- @param folder string The folder to match, excluding the trailing slash (e.g. "sound", "models", etc.)
--- @param path string Search Path (e.g. "GAME", "DATA", etc.)
--- @param fileFilter? function A function to filter files by (leadingPath, fileName) => boolean
--- @param folderFilter? function A function to filter folders by (leadingPath, folderName) => boolean
--- @param out? table The table to append the file paths to
--- @returns string[] out The collected file paths
function CFCUlxCurse.MarchFolderFiltered( folder, path, fileFilter, folderFilter, out )
    folder = folder .. "/"
    fileFilter = fileFilter or function() return true end
    folderFilter = folderFilter or function() return true end
    out = out or {}

    local fileNames, folderNames = file_Find( folder .. "*", path )

    -- It's best to filter things here rather than have scripts later do table.remove() on really long tables.
    for _, fileName in ipairs( fileNames ) do
        if fileFilter( folder, fileName ) then
            table_insert( out, folder .. fileName )
        end
    end

    for _, folderName in ipairs( folderNames ) do
        if folderFilter( folder, folderName ) then
            CFCUlxCurse.MarchFolderFiltered( folder .. folderName, path, fileFilter, folderFilter, out )
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

    hook.Run( "CFC_ULXCommands_Curse_StartEffect", ply, effectName, startTime, duration )
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

    hook.Run( "CFC_ULXCommands_Curse_EndEffect", ply, effectName )
end )
