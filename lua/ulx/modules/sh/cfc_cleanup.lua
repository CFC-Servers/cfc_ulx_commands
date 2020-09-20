CATEGORY_NAME = "Cleanup"

local function cleanupPlayerEnts( callingPlayer, targetPlayers, targetEntities )
    targetEntities = targetEntities or "*"

    local isTarget = {}
    for _, ply in pairs( targetPlayers ) do
        isTarget[ply] = true
    end

    local count = 0

    local isWildcardMatch = targetEntities == "*"

    for _, ent in ipairs( ents.GetAll() ) do
        if not ent:IsWeapon() then
            local isModelMatch = targetEntities == ent:GetModel()
            local isClassMatch = targetEntities == ent:GetClass()
            local isMatch = isWildcardMatch or isModelMatch or isClassMatch

            if isMatch then
                local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
                if isTarget[owner] then
                    ent:Remove()
                    count = count + 1
                end
            end
        end
    end

    ulx.fancyLogAdmin( callingPlayer,  "#A removed " .. count .. " entities owned by #T", targetPlayers )
end

local cleanup = ulx.command( CATEGORY_NAME, "ulx cleanup", cleanupPlayerEnts, "!cleanup" )
cleanup:addParam{ type = ULib.cmds.PlayersArg }
cleanup:addParam{ type = ULib.cmds.StringArg, hint = "class/model, * for all", ULib.cmds.optional }
cleanup:defaultAccess( ULib.ACCESS_ADMIN )
cleanup:help( "Remove entities owned by target" )
