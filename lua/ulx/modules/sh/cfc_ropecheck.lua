if engine.ActiveGamemode() == "terrortown" then return end

CFCUlxCommands.ropecheck = CFCUlxCommands.ropecheck or {}
local cmd = CFCUlxCommands.ropecheck
local CATEGORY_NAME = "Utility"
local IsValid = IsValid
local rawget = rawget
local rawset = rawset

function cmd.ropecheck( callingPlayer )
    local ropes = ents.FindByClass( "keyframe_rope" )
    local ropeCount = #ropes

    if ropeCount == 0 then
        ulx.fancyLogAdmin( callingPlayer, true, "#A checked the ropecount: There are currently no ropes on the map" )
        return
    end

    local players = player.GetHumans()
    local playerRopes = {}

    for i = 1, ropeCount do
        local rope = rawget( ropes, i )
        local owner = rope.CPPIGetOwner and rope:CPPIGetOwner()

        if IsValid( owner ) then
            local plyCount = rawget( playerRopes, owner )
            local new = ( plyCount or 0 ) + 1
            rawset( playerRopes, owner, new )
        end
    end

    for _, ply in ipairs( players ) do
        local plyCount = rawget( playerRopes, ply )

        if plyCount then
            callingPlayer:ChatPrint( ply:GetName() .. " owns: " .. plyCount .. " ropes" )
        end
    end

    ulx.fancyLogAdmin( callingPlayer, true, "#A checked the ropecount: There are currently " .. ropeCount .. " ropes on the map" )
end

local ropecheckCommand = ulx.command( CATEGORY_NAME, "ulx ropecheck", cmd.ropecheck, "!ropecheck" )
ropecheckCommand:defaultAccess( ULib.ACCESS_ADMIN )
ropecheckCommand:help( "Clear all the ropes currently on the ground." )
