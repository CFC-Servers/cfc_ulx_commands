CFCUlxCommands.constrainChecker = CFCUlxCommands.constrainChecker or {}
local cmd = CFCUlxCommands.constrainChecker
local CATEGORY_NAME = "Utility"
local IsValid = IsValid

-- Returns the owner of the entity if it is checkable, otherwise returns false
local function getOwnerIfCheckable( ent )
    if not IsValid( ent ) then return false end
    if ent.IsConstraint and ent:IsConstraint() then return false end

    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
    if not IsValid( owner ) then return false end

    return owner
end

-- Returns a lookup table from players to the entities they own
local function getCheckableEnts( plys )
    local allEnts = ents.GetAll()
    local perPlyEnts = {}

    for i = 1, #plys do
        local ply = plys[i]
        perPlyEnts[ply] = {}
    end

    for i = 1, #allEnts do
        local ent = allEnts[i]
        local owner = getOwnerIfCheckable( ent )

        if owner then
            local ownedEnts = perPlyEnts[owner]

            if ownedEnts then
                ownedEnts[#ownedEnts + 1] = ent
            end
        end
    end

    return perPlyEnts
end

local function countConstraintsForPly( ownedEnts )
    local constraintCounts = {}
    local totalConstraints = 0

    for i2 = 1, #ownedEnts do
        local ent = ownedEnts[i2]
        local entConstraints = ent.Constraints or {}

        for _, constr in pairs( entConstraints ) do
            local constrType = constr.Type or "UNKNOWN_CONSTRAINT"

            -- Add by 0.5 to compensate for double-counting, as each constraint exists on two entities
            constraintCounts[constrType] = ( constraintCounts[constrType] or 0 ) + 0.5
            totalConstraints = totalConstraints + 0.5
        end
    end

    constraintCounts.Total = totalConstraints

    return constraintCounts
end

--[[
    - Returns a table that shows, per player, the amount of constraints per type they own
    - ex:
        {
            ply1 = {
                Total = 7,
                Weld = 5,
                Axis = 2,
            },
            ply2 = {
                Total = 3,
                Weld = 3,
            },
        }
--]]
local function countConstraints( plys )
    local perPlyEnts = getCheckableEnts( plys )
    local perPlyConstraints = {}

    for i = 1, #plys do
        local ply = plys[i]
        local ownedEnts = perPlyEnts[ply]

        perPlyConstraints[ply] = countConstraintsForPly( ownedEnts )
    end

    return perPlyConstraints
end

local function printConstraintResults( caller, ply, constraintCounts )
    caller:PrintMessage( 2, "\n=======================" )
    caller:PrintMessage( 2, ply:Name() .. "'s constraints:" )
    caller:PrintMessage( 2, "-----------------------" )

    -- Print the tocal count first
    local totalConstraints = constraintCounts.Total
    constraintCounts.Total = nil
    caller:PrintMessage( 2, "TOTAL : " .. totalConstraints )

    -- Print the rest of the counts
    for constrType, count in pairs( constraintCounts ) do
        caller:PrintMessage( 2, constrType .. " : " .. count )
    end

    caller:PrintMessage( 2, "=======================" )
    constraintCounts.Total = totalConstraints -- Preserve original status of the table. Technically not necessary for this system, but doing it by convention.
end


function cmd.checkConstraints( caller, targetPlys )
    local perPlyConstraints = countConstraints( targetPlys )

    ulx.fancyLogAdmin( caller, true, "#A checked the constraints of #T", targetPlys ) -- Alert staff console of the command being used

    for _, ply in pairs( targetPlys ) do
        local constraintCounts = perPlyConstraints[ply]

        printConstraintResults( caller, ply, constraintCounts )
    end
end

local constraintCheckerCommand = ulx.command( CATEGORY_NAME, "ulx constraints", cmd.checkConstraints, "!constraints" )
constraintCheckerCommand:addParam{ type = ULib.cmds.PlayersArg }
constraintCheckerCommand:defaultAccess( ULib.ACCESS_ADMIN )
constraintCheckerCommand:help( "Prints out the number of constraints the player(s) have." )
