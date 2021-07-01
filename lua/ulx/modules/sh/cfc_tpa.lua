CFCUlxCommands.tpa = CFCUlxCommands.tpa or {}
local cmd = CFCUlxCommands.tpa
local CATEGORY_NAME = "Teleport"

function cmd.tpa( callingPlayer, targetPlayers )
    local target = targetPlayers[1]

    CFCNotifications.sendSimple( "tpaNotifCaller", "TPA", "Send teleport request.", callingPlayer )

    local notif = CFCNotifications.new( "tpaRequest", "Buttons", true )

    notif:SetTitle( "TPA" )
    notif:SetText( "Teleport request from " .. callingPlayer:GetName() )

    notif:AddButton( "Accept", Color( 0, 255, 0 ), 1 )
    notif:AddButton( "Deny", Color( 255, 0, 0 ), 2 )

    notif:SetDisplayTime( 10 )
    notif:SetTimed( true )

    function notif:OnButtonPressed( _, ind )
        if ind == 1 then
            ulx.goto( callingPlayer, target )
            CFCNotifications.sendSimple( "tpaClose", "TPA", "Teleport request was accepted.", callingPlayer )
        else
            CFCNotifications.sendSimple( "tpaClose", "TPA", "The recipient has denied your teleport request.", callingPlayer )
        end
        -- Do stuff based on ind being 1 or 2
    end

    function notif:OnClose( wasTimeout )
        if wasTimeout then
            CFCNotifications.sendSimple( "tpaTimeout", "TPA", "The recipient didn't accept within the given time.", callingPlayer )
        elseif not wasTimeout then
            CFCNotifications.sendSimple( "tpaClose", "TPA", "The recipient has denied your teleport request.", callingPlayer )
        end
        -- Do stuff
    end

    notif:Send( target )

    -- for _, ply in ipairs( targetPlayers ) do
    --     -- do code
    -- end

    --ulx.fancyLogAdmin( callingPlayer, "#A requested teleportation to #T", targetPlayers )
end

local tpaCommand = ulx.command( CATEGORY_NAME, "ulx tpa", cmd.tpa, "!tpa" )
tpaCommand:addParam{ type = ULib.cmds.PlayersArg }
tpaCommand:defaultAccess( ULib.ACCESS_ADMIN )
tpaCommand:help( "Requests a teleport to other players." )
