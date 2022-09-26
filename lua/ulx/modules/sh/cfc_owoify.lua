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
    "~"
}
local PHRASES_TO_REPLACE = {
    { "oo", "ew" },
    { "O", "owo" },
    { "U", "uwu" },
    { "lol", "uwu" },
    { "lmao", "uwu" },
    { "lmfao", "uwu" },
    { "l", "w" },
    { "na", "nya" },
    { "ne", "nye" },
    { "ni", "nyi" },
    { "no", "nyo" },
    { "nu", "nyu" },
    { "ove", "uv" },
    { "r", "w" },
    { "that", "dat" },
    { "tion", "shun" },
    { "wha", "wa" },
    { "whe", "we" },
    { "whi", "wi" },
    { "you", "nyu" }
}
local ID_OWO = 3

local function owoifyMessage( message )
    local owoifiedMessage = message

    for _, item in pairs( PHRASES_TO_REPLACE ) do
        local old = item[1]
        local new = item[2]
        owoifiedMessage = string.Replace( owoifiedMessage, old, new )
    end
    owoifiedMessage = owoifiedMessage .. PHRASES_TO_APPEND[math.random( 1, #PHRASES_TO_APPEND )]

    return owoifiedMessage
end

local function onPlayerSay( ply, message )
    if ply.gimp ~= ID_OWO then return end

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
owoifyCommand:setOpposite( "ulx unowoify", { _, _, true }, { "!unowoify", "!unowo" } )
