CFCUlxCommands.weprem = CFCUlxCommands.weprem or {}
local cmd = CFCUlxCommands.weprem
local CATEGORY_NAME = "Utility"

function cmd.weprem( callingPlayer, targetPlayers )
    local count = 0

    for _, entity in ipairs( ents.GetAll() ) do
        if IsValid( entity ) then
            local isUnownedWeapon = entity:IsWeapon() and not IsValid( entity.Owner )

            if isUnownedWeapon then
                count = count + 1
                entity:Remove()
            end
        end
    end

    ulx.fancyLogAdmin( callingPlayer, "#A removed " .. count .. " weapons from the ground.", targetPlayers )
end

local wepremCommand = ulx.command( CATEGORY_NAME, "ulx weprem", cmd.weprem, "!weprem" )
wepremCommand:defaultAccess( ULib.ACCESS_ADMIN )
wepremCommand:help( "Clear all the weapons currently on the ground." )
