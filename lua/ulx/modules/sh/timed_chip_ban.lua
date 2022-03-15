CFCUlxCommands.e2ban = CFCUlxCommands.e2ban or {}
local cmd = CFCUlxCommands.e2ban
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "chipban"
local HELP = "Bans the target for a certain time from using E2/Starfall"

if SERVER then
    local chips = {
        gmod_wire_expression2 = true,
        starfall_processor = true
    }

    local function enable( ply )
        ply.isChipBanned = true

        for _, ent in ipairs( ents.GetAll() ) do
            local entClass = ent:GetClass()

            if entClass == "gmod_wire_expression2" then
                if ent.player == ply then
                    ent:Remove()
                end
            end

            if entClass == "starfall_processor" then
                if ent.owner == ply then
                    ent:Remove()
                end
            end
        end
    end

    local function disable( ply )
        ply.isChipBanned = false
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )
end

local action = "banned ## from E2/Starfall"
local inverseAction = "unbanned ## from E2/Starfall"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )

if SERVER then
    local function setupE2()
        local e2Meta = scripted_ents.GetStored( "gmod_wire_expression2" ).t
        e2Meta._ChipBan_Setup = e2Meta._ChipBan_Setup or e2Meta.Setup

        e2Meta.Setup = function( chip, ... )
            local ply = chip.player

            if ply.isChipBanned then
                ply:ChatPrint( "You can't spawn E2s while Chip Banned!" )
                chip:Remove()
                return false
            end

            return e2Meta:_ChipBan_Setup( chip, ... )
        end
    end

    local function setupStarfall()
        local starfall = scripted_ents.GetStored( "starfall_processor" ).t
        starfall._ChipBan_SetupFiles = starfall._ChipBan_SetupFiles or starfall.SetupFilers

        starfall.SetupFiles = function( chip, sfdata )
            local ply = sfdata.owner

            if ply.isChipBanned then
                ply:ChatPrint( "You can't spawn Starfalls while Chip Banned!" )
                chip:Remove()
                return false
            end

            return starfall:_ChipBan_SetupFiles( chip, sfdata )
        end
    end

    local function setup()
        setupE2()
        setupStarfall()
    end

    hook.Add( "InitPostEntity", "CFC_ULXCommands_ChipBanSetup", function()
        -- Slight delay so we're (probably) the last thing wrapping the setup functions
        timer.Simple( 5, setup )
    end )
end
