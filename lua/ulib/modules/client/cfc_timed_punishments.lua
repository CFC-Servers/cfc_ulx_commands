local punishments = {}

local WHITE = Color( 255, 255, 255 )
local RED = Color( 177, 15, 46 )
local BLUE = Color( 51, 161, 253 )
local ORANGE = Color( 247, 152, 36 )

local function alert()
    if table.Count( punishments ) == 0 then
        chat.AddText( ORANGE, "[TimedPunishments] ", WHITE, "You have no active punishments" )
        return
    end

    chat.AddText( ORANGE, "[TimedPunishments] ", WHITE, "Current Punishments:" )

    for name, expiration in pairs( punishments ) do
        local timeLeft = expiration - os.time()

        if timeLeft <= 0 then
            punishments[name] = nil
        else
            local timeLeftStr = ULib.secondsToStringTime( timeLeft )
            chat.AddText( "  ", RED, name, WHITE, " for ", BLUE, timeLeftStr )
        end
    end
end

net.Receive( "CFC_TimedPunishments_Punishments", function()
    table.Empty( punishments )

    local count = net.ReadUInt( 8 )
    if count == 0 then return end

    for _ = 1, count do
        local name = net.ReadString()
        local expiration = net.ReadDouble()
        punishments[name] = expiration
    end

    alert()
end )

hook.Add( "OnPlayerChat", "CFC_TimedPunishments_Punishments", function( ply, text )
    if ply ~= LocalPlayer() then return end
    if text ~= "!punishments" then return end

    alert()
    return true
end )

hook.Add( "InitPostEntity", "CFC_TimedPunishments_GlobalizePunishments", function()
    LocalPlayer().TimedPunishments = punishments
end )
