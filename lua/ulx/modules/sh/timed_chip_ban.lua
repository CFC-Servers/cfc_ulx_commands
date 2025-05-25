CFCUlxCommands.e2ban = CFCUlxCommands.e2ban or {}
local CATEGORY_NAME = "Utility"
local PUNISHMENT = "chipban"
local HELP = "Bans the target for a certain time from using E2/Starfall"

if SERVER then
    local function enable( ply )
        ply.isChipBanned = true

        for _, ent in ipairs( ents.GetAll() ) do
            local entClass = ent:GetClass()

            if entClass == "gmod_wire_expression2" and ent.player == ply then
                ent:Remove()
            end

            if entClass == "starfall_processor" and ent.owner == ply then
                ent:Remove()
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
        if not WireAddon then return end

        hook.Add( "Expression2_CanCompile", "CFC_ULXCommands_ChipBan", function( ply )
            if not ply.isChipBanned then return end

            ply:ChatPrint( "You can't spawn E2 chips while Chip Banned!" )
            return false
        end )
    end

    local function setupStarfall()
        hook.Add( "StarfallCanCompile", "CFC_ULXCommands_ChipBan", function( _, _, ply )
            if not ply.isChipBanned then return end

            ply:ChatPrint( "You can't spawn Starfall chips while Chip Banned!" )
            return false
        end )
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
