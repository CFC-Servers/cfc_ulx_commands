CFCUlxCommands.constrainChecker = CFCUlxCommands.constrainChecker or {}
local cmd = CFCUlxCommands.constrainChecker
local CATEGORY_NAME = "Utility"
local IsValid, Clamp, Remap = IsValid, math.Clamp, math.Remap
local HSV_RED_ANGLE, HSV_GREEN_ANGLE = 0, 120
local WHITE = Color( 255, 255, 255 )
local CONSTRAINT_THRESHOLD = 500
local NETWORK_NAME = "CFC_ulx-constraint_checker"
if SERVER then
    util.AddNetworkString( NETWORK_NAME )
end

-- Returns the owner of the entity if it is checkable, otherwise returns false
local function getAbsoluteOwner( ent )
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

    for _, ply in ipairs( plys ) do
        perPlyEnts[ply] = {}
    end

    for _, ent in ipairs( allEnts ) do
        local owner = getAbsoluteOwner( ent )

        if owner then
            local ownedEnts = perPlyEnts[owner]

            if ownedEnts then
                table.insert( ownedEnts, ent )
            end
        end
    end

    return perPlyEnts
end

local function countConstraintsForPly( ownedEnts )
    local constraintCounts = {}
    local totalConstraints = 0

    for _, ent in ipairs( ownedEnts ) do
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

    for _, ply in ipairs( plys ) do
        local ownedEnts = perPlyEnts[ply]

        perPlyConstraints[ply] = countConstraintsForPly( ownedEnts )
    end

    return perPlyConstraints
end

local function printConstraintResults( caller, ply, constraintCounts )
    local decorLength = 25
    local nl = "\n"
    local divider = string.rep( "=", decorLength ) .. nl
    local nameDivider = string.rep( "-", decorLength ) .. nl
    --[[
    local totalCount = "TOTAL: " .. constraintCounts.Total
    local topBlock = nl .. divider .. nl .. ply:Name() .. "'s constraints:" .. nl .. nameDivider .. nl .. totalCount
    caller:PrintMessage( 2, topBlock )

    -- Print the rest of the counts
    for constrType, count in pairs( constraintCounts ) do
        if constrType ~= "Total" then
            caller:PrintMessage( 2, constrType .. ": " .. count )
        end
    end

    caller:PrintMessage( 2, divider )
    ]]
    local totalCount = constraintCounts.Total
    local totalLabel = "TOTAL: " .. totalCount .. nl
    local plyTeamColor = team.GetColor( ply:Team() )

    local valueInThreshold = Clamp( totalCount, 0, CONSTRAINT_THRESHOLD )
    local severity = Remap( valueInThreshold, CONSTRAINT_THRESHOLD, 0, HSV_RED_ANGLE, HSV_GREEN_ANGLE )
    local colorSeverity = HSVToColor( severity, 1, 0.8 )
    if totalCount == 0 then colorSeverity = WHITE end

    local blockData = {
        WHITE, nl .. divider,
        plyTeamColor, ply:Name(), WHITE, " | ", colorSeverity, totalLabel, WHITE,
        nameDivider,
        divider
    }

    for constrType, count in pairs( constraintCounts ) do
        if constrType ~= "Total" then
            local data = constrType .. ": " .. count .. nl
            table.insert( blockData, #blockData, data )
        end
    end

    --[[
    net.Start( NETWORK_NAME )
    net.WriteTable( blockData )
    net.Send( caller )
    ]]
    return blockData
end


function cmd.checkConstraints( caller, targetPlys, showPlysWithNoConstraints )
    local perPlyConstraints = countConstraints( targetPlys )
    local dataBlocks = {}

    ulx.fancyLogAdmin( caller, true, "#A checked the constraints of #T", targetPlys ) -- Alert staff console of the command being used
    caller:ChatPrint( "Open your console to see the results." )
    --[[
    for _, ply in pairs( targetPlys ) do
        local constraintCounts = perPlyConstraints[ply]
        if constraintCounts.Total > 0 then
            printConstraintResults( caller, ply, constraintCounts )
        end
    end
    ]]
    for _, ply in pairs( targetPlys ) do
        local constraintCounts = perPlyConstraints[ply]
        if showPlysWithNoConstraints or constraintCounts.Total > 0 then
            local block = printConstraintResults( caller, ply, constraintCounts )
            table.Add( dataBlocks, block )
        end
    end

    net.Start( NETWORK_NAME )
    net.WriteTable( dataBlocks )
    net.Send( caller )
end

local constraintCheckerCommand = ulx.command( CATEGORY_NAME, "ulx constraints", cmd.checkConstraints, "!constraints" )
constraintCheckerCommand:addParam{ type = ULib.cmds.PlayersArg }
constraintCheckerCommand:addParam{ type = ULib.cmds.BoolArg, default = "false", ULib.cmds.optional }
constraintCheckerCommand:defaultAccess( ULib.ACCESS_ADMIN )
constraintCheckerCommand:help( "Prints out the number of constraints the player(s) have." )
