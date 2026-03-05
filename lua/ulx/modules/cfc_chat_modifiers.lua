CFCUlxCommands.chatmodifiers = CFCUlxCommands.chatmodifiers or {}
local chatModifModule = CFCUlxCommands.chatmodifiers

chatModifModule.modifiers = chatModifModule.modifiers or {}
local modifiers = chatModifModule.modifiers

local ID_GIMP = 1
local ID_MUTE = 2


---@alias ChatTransform fun(msg: string, ply:Player): string

--- Registers a chat modifier.
--- Note that ulx mute and ulx gimp are special cases that always go first.
--- In the case of mute, it will also not run any modifiers, simply returning early.
---
--- @param name string The name of the modifier.
--- @param priority number Low priority runs first, high priority runs last.
--- @param func ChatTransform The string manipulation function.
function chatModifModule.register( name, priority, func )
    -- Remove the old one, in case modifiers are being re-registered for dev testing.
    for i = 1, #modifiers do
        if modifiers[i].name == name then
            table.remove( modifiers, i )
            break
        end
    end

    local modifier = {
        name = name,
        priority = priority,
        func = func,
    }

    -- Insert in ascending order by priority.
    for i = 1, #modifiers do
        if priority <= modifiers[i].priority then
            table.insert( modifiers, i, modifier )
            return
        end
    end

    modifiers[#modifiers + 1] = modifier
end

function chatModifModule.apply( ply, modifierName )
    ply.cfcUlxChatModifiers = ply.cfcUlxChatModifiers or {}
    ply.cfcUlxChatModifiers[modifierName] = true
end

function chatModifModule.remove( ply, modifierName )
    local modifs = ply.cfcUlxChatModifiers
    if not modifs then return end

    modifs[modifierName] = nil

    if not next( modifs ) then
        ply.cfcUlxChatModifiers = nil
    end
end

function chatModifModule.setApplied( ply, modifierName, enable )
    if enable then
        chatModifModule.apply( ply, modifierName )
    else
        chatModifModule.remove( ply, modifierName )
    end
end

function chatModifModule.hasModifier( ply, modifierName )
    local modifs = ply.cfcUlxChatModifiers
    if not modifs then return end
    return modifs[modifierName] or false
end


local function gimpCheck( ply )
    local gimpID = ply.gimp
    if gimpID == ID_MUTE then return "" end

    if gimpID == ID_GIMP then
        local gimpSays = ulx.gimpSays or {}
        if #gimpSays < 1 then return "I have no mouth and I must scream!" end

        return gimpSays[math.random( #gimpSays )]
    end
end


hook.Add( "PlayerSay", "CFCUlxCommands_ChatModifiers", function( ply, msg )
    -- Check gimp/mute. If muted, mute the message; otherwise, replace message with the gimp and check modifiers.
    local gimp = gimpCheck( msg )
    if gimp then
        if gimp == "" then return "" end
        msg = gimp
    end

    local modifs = ply.cfcUlxChatModifiers
    if not modifs then return gimp end

    for _, modifier in ipairs( modifiers ) do
        if modifs[modifier.name] then
            msg = modifier.func( msg, ply )
        end
    end

    return msg
end, HOOK_LOW )

hook.Add( "Initialize", "CFCUlxCommands_ChatModifiers", function()
    hook.Remove( "PlayerSay", "ULXGimpCheck" ) -- Remove ulx gimp/mute hook, we replace it.
end )
