CFCUlxCommands.tpa = CFCUlxCommands.tpa or {}
local cmd = CFCUlxCommands.tpa
local CATEGORY_NAME = "Teleport"

CreateConVar( "cfc_tpa_decline_cooldown", 10, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "The time a person can't receive teleports from a player after declining.", 0 )
CreateConVar( "cfc_tpa_cooldown", 5, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "The cooldown between tpa request for any player.", 0 )

local function setDeclineCooldown( caller, target )
    target.cfcTpaCooldownDecline = target.cfcTpaCooldownDecline or {}
    target.cfcTpaCooldownDecline[ caller ] = CurTime() + GetConVar( "cfc_tpa_decline_cooldown" ):GetInt()
end

function cmd.tpa( callingPlayer, targetPlayers )
    local target = targetPlayers[1]

    if target.cfcTpaCooldownDecline and target.cfcTpaCooldownDecline[ callingPlayer ] and target.cfcTpaCooldownDecline[ callingPlayer ] > CurTime() then
        CFCNotifications.sendSimple( "tpaDeclineCooldown", "TPA", "You cannot request a TPA to that player yet.", callingPlayer )
        return
    end

    if callingPlayer.cfcTpaCooldown and callingPlayer.cfcTpaCooldown > CurTime() then
        CFCNotifications.sendSimple( "tpaCooldown", "TPA", "You cannot send another teleport request yet.", callingPlayer )
        return
    end

    callingPlayer.cfcTpaCooldown = CurTime() + GetConVar( "cfc_tpa_cooldown" ):GetInt()

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
            setDeclineCooldown( callingPlayer, target )
        end
    end

    function notif:OnClose( wasTimeout )
        if wasTimeout then
            CFCNotifications.sendSimple( "tpaTimeout", "TPA", "The recipient didn't accept within the given time.", callingPlayer )
        elseif not wasTimeout then
            CFCNotifications.sendSimple( "tpaClose", "TPA", "The recipient has denied your teleport request.", callingPlayer )
            setDeclineCooldown( callingPlayer, target )
        end
    end

    notif:Send( target )
end

local tpaCommand = ulx.command( CATEGORY_NAME, "ulx tpa", cmd.tpa, "!tpa" )
tpaCommand:addParam{ type = ULib.cmds.PlayersArg }
tpaCommand:defaultAccess( ULib.ACCESS_ADMIN )
tpaCommand:help( "Requests a teleport to other players." )
