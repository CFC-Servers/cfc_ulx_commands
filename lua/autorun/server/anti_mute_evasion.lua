local ID_MUTE = 2

local isBannedWhileMuted = {
    ["ulx ungimp"] = true,
    ["ulx gimp"] = true,
    ["ulx unowoify"] = true,
    ["ulx owoify"] = true,
}

hook.Add( "ULibCommandCalled", "CFC_AntiUnmute_PreventUnmute", function( ply, commandName )
    if not isBannedWhileMuted[commandName] then return end
    if ply.gimp == ID_MUTE then
        ULib.tsayError( ply, "You can't do that while muted" )
        return false
    end
end )
