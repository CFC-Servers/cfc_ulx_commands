if engine.ActiveGamemode() == "terrortown" then return end

CFCUlxCommands.tpa = CFCUlxCommands.tpa or {}
local cmd = CFCUlxCommands.tpa
local CATEGORY_NAME = "Teleport"

local DECLINE_COLOR = Color( 0, 255, 0 )
local ACCEPT_COLOR = Color( 255, 0, 0 )

CreateConVar( "cfc_tpa_decline_cooldown", 10, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "The time a person can't receive teleports from a player after declining.", 0 )
CreateConVar( "cfc_tpa_cooldown", 5, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "The cooldown between tpa request for any player.", 0 )
CreateConVar( "cfc_tpa_teleport_delay", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "The delay for someone to teleport after getting accepted.", 0 )

local function setDeclineCooldown( caller, target )
    target.cfcTpaCooldownDecline = target.cfcTpaCooldownDecline or {}
    target.cfcTpaCooldownDecline[ caller ] = CurTime() + GetConVar( "cfc_tpa_decline_cooldown" ):GetInt()
end

function cmd.tpa( callingPlayer, targetPlayers )
    local target = targetPlayers[1]
    local curtime = CurTime()

    if target:GetInfoNum( "cfc_tpa_disable", 0 ) == 1 then
        CFCNotifications.sendSimple( "tpaNotAllowed", "TPA", "This player has tpa requests disabled.", callingPlayer )
        return
    end

    local decline = target.cfcTpaCooldownDecline
    local callerDecline = decline and decline[callingPlayer]
    local callerDeclineTime = callerDecline or 0

    if callerDeclineTime > curtime then
        CFCNotifications.sendSimple( "tpaDeclineCooldown", "TPA", "You cannot request a TPA to that player yet.", callingPlayer )
        return
    end

    if ( callingPlayer.cfcTpaCooldown or 0 ) > curtime then
        CFCNotifications.sendSimple( "tpaCooldown", "TPA", "You cannot send another teleport request yet.", callingPlayer )
        return
    end

    callingPlayer.cfcTpaCooldown = curtime + GetConVar( "cfc_tpa_cooldown" ):GetInt()

    CFCNotifications.sendSimple( "tpaNotifCaller", "TPA", "Send teleport request.", callingPlayer )

    local notif = CFCNotifications.new( "tpaRequest", "Buttons", true )

    notif:SetTitle( "TPA" )
    notif:SetText( "Teleport request from " .. callingPlayer:GetName() )

    notif:AddButton( "Accept", DECLINE_COLOR, 1 )
    notif:AddButton( "Deny", ACCEPT_COLOR, 2 )

    notif:SetDisplayTime( 10 )
    notif:SetTimed( true )

    function notif:OnButtonPressed( _, ind )
        if ind ~= 1 then
            CFCNotifications.sendSimple( "tpaClose", "TPA", "The recipient has denied your teleport request.", callingPlayer )
            setDeclineCooldown( callingPlayer, target )
            return
        end

        local delay = GetConVar( "cfc_tpa_teleport_delay" ):GetInt()

        local acceptNotif = CFCNotifications.new( "tpaClose", "Text", true )
        acceptNotif:SetTitle( "TPA" )
        acceptNotif:SetText( "Teleport request was accepted, teleporting shortly." )
        acceptNotif:SetDisplayTime( delay )
        acceptNotif:Send( callingPlayer )

        timer.Simple( delay, function()
            CFCNotifications.sendSimple( "tpaClose", "TPA", "Successfully teleported.", callingPlayer )
            ulx.goto( callingPlayer, target )
        end)
    end

    function notif:OnClose( wasTimeout )
        if wasTimeout then
            CFCNotifications.sendSimple( "tpaTimeout", "TPA", "The recipient didn't accept within the given time.", callingPlayer )
            return
        end

        CFCNotifications.sendSimple( "tpaClose", "TPA", "The recipient has denied your teleport request.", callingPlayer )
        setDeclineCooldown( callingPlayer, target )
    end

    notif:Send( target )
end

local tpaCommand = ulx.command( CATEGORY_NAME, "ulx tpa", cmd.tpa, "!tpa" )
tpaCommand:addParam{ type = ULib.cmds.PlayersArg }
tpaCommand:defaultAccess( ULib.ACCESS_ADMIN )
tpaCommand:help( "Requests a teleport to other players." )

-- Q menu disable checkbox
if CLIENT then
    CreateClientConVar( "cfc_tpa_disable", 0, true, true, "Disables ulx tpa request from being shown." )

    hook.Add( "AddToolMenuCategories", "CFC_TPA_AddToolMenuCategories", function()
        spawnmenu.AddToolCategory( "Options", "CFC", "#CFC" )
    end)

    hook.Add( "PopulateToolMenu", "CFC_TPA_PopulateToolMenu", function()
        spawnmenu.AddToolMenuOption( "Options", "CFC", "cfc_tpa", "#TPA", "", "", function( panel )
            panel:CheckBox( "Disable tpa's from all players", "cfc_tpa_disable" )
        end)
    end)
end
