CFCUlxCommands.timedDarkRP = CFCUlxCommands.timedDarkRP or {}
local CATEGORY_NAME = "Fun"
local PUNISHMENT = "timeddarkrp"
local HELP = "Prevents the target(s) from spawning anything at all"

if SERVER then
    local function enable( ply )
        ply.isInULXDarkRP = true

        ply:StripWeapons()
        cleanup.CC_Cleanup( ply, "gmod_cleanup", {} )
    end

    local function disable( ply )
        ply.isInULXDarkRP = nil
    end

    local function blockAction( ply )
        if not ply or not ply:IsValid() then return end
        if ply.isInULXDarkRP then return false end
    end

    TimedPunishments.Register( PUNISHMENT, enable, disable )

    -- Block spawning and noclip while in darkrp mode.
    -- Has to be done manually to prevent ulib's :DisallowSpawning() and etc from interfering, such as when a player unragdolls.
    hook.Add( "PlayerNoClip", "ULibNoclipCheck", noclip, HOOK_HIGH )
    hook.Add( "CanTool", "CFC_ULX_DarkRP_blockActioning", blockAction, HOOK_HIGH )
    hook.Add( "PlayerSpawnObject", "CFC_ULX_DarkRP_blockActioning", blockAction )
    hook.Add( "PlayerSpawnEffect", "CFC_ULX_DarkRP_blockActioning", blockAction )
    hook.Add( "PlayerSpawnProp", "CFC_ULX_DarkRP_blockActioning", blockAction )
    hook.Add( "PlayerSpawnNPC", "CFC_ULX_DarkRP_blockActioning", blockAction )
    hook.Add( "PlayerSpawnVehicle", "CFC_ULX_DarkRP_blockActioning", blockAction )
    hook.Add( "PlayerSpawnRagdoll", "CFC_ULX_DarkRP_blockActioning", blockAction )
    hook.Add( "PlayerSpawnSENT", "CFC_ULX_DarkRP_blockActioning", blockAction )
    hook.Add( "PlayerGiveSWEP", "CFC_ULX_DarkRP_blockActioning", blockAction )
end

local action = "forced ## into DarkRP Mode"
local inverseAction = "removed ## from DarkRP Mode"
TimedPunishments.MakeULXCommands( PUNISHMENT, action, inverseAction, CATEGORY_NAME, HELP )
