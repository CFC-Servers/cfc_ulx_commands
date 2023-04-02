CFCUlxCommands.vacban = CFCUlxCommands.timegag or {}
local SILENT = true
local CATEGORY_NAME = "Fun"
local PUNISHMENT = "vacban"
local HELP = "Mock VAC-bans the target(s) for the given time"

if SERVER then
    local function vacban( steamID64 )
        -- Check that the SteamID is valid
        local steamID = util.SteamIDFrom64( steamID64 )
        assert( steamID64 ~= "STEAM_0:0:0", "Invalid SteamID" )

        local command = string.format( "kickid %s #VAC_ConnectionRefusedDetail\n", steamID )
        game.ConsoleCommand( command )
    end

    local function enable( ply )
        vacban( ply:SteamID64() )
    end

    local function disable()
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )

    -- Runs on CheckPassword
    hook.Add( "CFC_TimedPunishments_PunishmentNotify", "CFC_TimedPunishments_VACBan", function( steamID64, punishments )
        local expiration = punishments[PUNISHMENT]
        if not expiration then return end

        if expiration > 0 and expiration > os.time() then
            return "##VAC_ConnectionRefusedDetail"
        end
    end )
end

local action = "vac banned ##"
local inverseAction = "un vac-banned ##"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP, SILENT )

