local CATEGORY_TYPE = "Chat"
    local OWOIFY_DICT = {
    O = "owo",
    U = "uwu",
    l = "w",
    na = "nya",
    ne = "nye",
    ni = "nyi",
    no = "nyo",
    nu = "nyu",
    ove = "uv",
    r = "w",
    tion = "shun",
    wha = "wa",
    whe = "we",
    whi = "wi"  
}

local function owoifyMessage( message )
    local owoifiedMessage = message
    
    for k, v in pairs( OWOIFY_DICT ) do
        owoifiedMessage = string.Replace( owoifiedMessage, k, v )
    end
    
    return owoifiedMessage
end

local function onPlayerSay( ply, message )
    if not ply.isOwoified then return end

    return owoifyMessage( message )
end

local function owoifyOn( caller, targets )
    for _, ply in pairs( targets ) do
        ply.isOwoified = true
    end
    ulx.fancyLogAdmin( caller, "#A owoified #T", targets )
end

local function owoifyOff( caller, targets )
    for _, ply in pairs( targets ) do
        ply.isOwoified = nil
    end
    ulx.fancyLogAdmin( caller, "#A unowoified #T", targets )
end

hook.Add( "PlayerSay", "CFC_ULX_OwoifyString", onPlayerSay )

local owoifyCommand = ulx.command( CATEGORY_TYPE, "ulx owoify", owoifyOn, "!owoify" )
owoifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
owoifyCommand:help( "Owoifies target(s) so they are unable to chat normally. (say: !owoify) (opposite: ulx unowoify)" )
owoifyCommand:addParam{ type = ULib.cmds.PlayersArg }

local unOwoifyCommand = ulx.command( CATEGORY_TYPE, "ulx unowoify", owoifyOff, "!unowoify" )
unOwoifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
unOwoifyCommand:addParam{ type = ULib.cmds.PlayersArg }
