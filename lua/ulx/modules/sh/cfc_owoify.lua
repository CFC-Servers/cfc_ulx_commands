local OWOIFYDICT = { na = "nya", ne = "nye", ni = "nyi", no = "nyo", nu = "nyu", ove = "uv", r = "w", l = "w", U = "uwu" }
local owoifyTargets = {}

local function owoifyString( inputStr )
    for k, v in pairs( OWOIFYDICT ) do
        inputStr = string.Replace( inputStr, k, v )
    end

    return inputStr
end

local function onPlayerSay( ply, inputStr )
    if not table.HasValue( owoifyTargets, ply ) then return end
    
    return owoifyString( inputStr )
end

local function owoifyOn( caller, targets )
    table.Add( owoifyTargets, targets )
    hook.Add( "PlayerSay", "CFC_ULX_OwoifyString", onPlayerSay )
    ulx.fancyLogAdmin( caller, "#A owoified #T", targets )
end

local function owoifyOff( caller, targets )
    for k, v in pairs( owoifyTargets ) do
        owoifyTargets[k] = nil
    end

    if table.Count( owoifyTargets ) == 0 then
        hook.Remove( "PlayerSay", "CFC_ULX_OwoifyString" )
    end
    
    ulx.fancyLogAdmin( caller, "#A unowoified #T", targets )
end

local owoifyCommand = ulx.command( "Fun", "ulx owoify", owoifyOn, "!owoify" )
owoifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
owoifyCommand:help( "Owoifies target(s) so they are unable to chat normally." )
owoifyCommand:addParam{ type = ULib.cmds.PlayersArg }

local unOwoifyCommand = ulx.command( "Fun", "ulx unowoify", owoifyOff, "!unowoify" )
unOwoifyCommand:defaultAccess( ULib.ACCESS_ADMIN )
unOwoifyCommand:help( "Unowoifies target(s) so they are able to chat normally." )
unOwoifyCommand:addParam{ type = ULib.cmds.PlayersArg }