CFCUlxCommands.e2ban = CFCUlxCommands.e2ban or {}
local cmd = CFCUlxCommands.e2ban
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "e2ban"
local HELP = "Bans the target for a certain time from using E2"

if SERVER then
    local function enable( ply )
        ply.isE2Banned = true

        for _, ent in ipairs( ents.FindByClass( "gmod_wire_expression2" ) ) do
            if ent.player == ply then
                ent:Remove()
            end
        end
    end

    local function disable( ply )
        ply.isE2Banned = false
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "banned ## from E2"
local inverseAction = "unbanned ## from E2"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )

local function setup()
    if not MakeWireExpression2 then
        ErrorNoHalt( "Couldn't find MakeWireExpression2, E2 ban can't function")
        return
    end

    _MakeWireExpression2 = _MakeWireExpression2 or MakeWireExpression2

    MakeWireExpression2 = function( ply, ... )
        if ply.isE2Banned then
            ply:ChatPrint( "You can't spawn E2s because you're currently E2 banned" )
            return false
        end

        return _MakeWireExpression2( ply, ... )
    end
end

hook.Add( "Initialize", "E2BanSetup", setup )

