CFCUlxCommands.ropecheck = CFCUlxCommands.ropecheck or {}
local cmd = CFCUlxCommands.ropecheck
local CATEGORY_NAME = "Utility"
local IsValid = IsValid

function cmd.ropecheck( callingPlayer )
    local ropeCount = {}
    local totalRopeCount = 0
    local entities = ents.GetAll()
    local players = player.GetHumans()

    for _, ply in ipairs( players ) do
        ropeCount[ply] = 0
    end

    for _, ent in ipairs( entities ) do
        if ent:GetClass() == "keyframe_rope" then
            local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
            if owner and ropeCount[owner] then
                ropeCount[owner] = ropeCount[owner] + 1
                totalRopeCount = totalRopeCount + 1
            end
        end
    end
    if ropeCount == 0 then
        ulx.fancyLogAdmin( callingPlayer, true, "#A checked the copecount there are currently, no ropes on the map" )
        return
    end

    for _, ply in pairs( players ) do
        if not ropeCount[ply] or ropeCount[ply] < 0 then return end
        callingPlayer:ChatPrint( ply:GetName() .. " owns: " .. ropeCount[ply] .. " ropes." )
    end

    ulx.fancyLogAdmin( callingPlayer, true, "#A checked the copecount there are currently, " .. totalRopeCount .. " ropes in total on the map" )
end

local ropecheckCommand = ulx.command( CATEGORY_NAME, "ulx ropecheck", cmd.ropecheck, "!ropecheck" )
ropecheckCommand:defaultAccess( ULib.ACCESS_ADMIN )
ropecheckCommand:help( "Clear all the ropes currently on the ground." )
