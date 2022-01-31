CFCUlxCommands.buildCheck = CFCUlxCommands.buildCheck or {}
local cmd = CFCUlxCommands.buildCheck
local CATEGORY_NAME = "Utility"
local IsValid = IsValid
local rawget = rawget
local rawset = rawset
local IsValid = IsValid

if SERVER then
    util.AddNetworkString( "CFC_ULX_BuildCheckResults" )
end

if CLIENT then
    local MsgC = MsgC
    -- TODO: Choose the colors
    local INTRO_COLOR = Color( 175, 175, 235 )
    local HEADER_COLOR = Color( 175, 235, 175 )
    local CLASS_COLOR = Color( 235, 235, 175 )

    -- These are vectors so we can lerp them
    local MOST_COUNT_COLOR = Vector( 255, 0, 0 ) -- If a single count makes up 100% of the total count
    local LEAST_COUNT_COLOR = Vector( 0, 255, 0 ) -- If a single count make sup 0% of the total count

    -- Returns a dynamic color between MOST_COUNT and
    -- LEAST_COUNT colors based on how much of the total is
    -- made up by the given count
    local function getCountColor( total, count )
        return LerpVector( count / total, LEAST_COUNT_COLOR, MOST_COUNT_COLOR ):ToColor()
    end

    -- MsgC with prefix and auto-newlining
    local consolePrint = function( prefix, ... )
        MsgC( prefix, ... , "\n" )
    end

    -- consolePrint with no prefix
    local msg = function( ... )
        consolePrint( "", ... )
    end

    -- consolePrint with indentation
    local subPrefix = "    "
    local subMsg = function( ... )
        consolePrint( subPrefix, ... )
    end

    -- Writes a table of <identifier>=<count>
    local function writeCountData( header, data )
        msg( HEADER_COLOR, header, ":")

        local total = data.total

        for identifier, count in pairs( SortedPairsByValue( data.items, true ) ) do
            local color = getCountColor( total, count )
            subMsg( CLASS_COLOR, identifier, ": ", COUNT_COLOR, count )
        end

        subMsg( TOTAL_COLOR, "Total: ", COUNT_COLOR, total, "\n" )
    end

    local function writePlayerData( plyName, data )
        -- Padded with newlines for surround spacing
        msg( "\n\n", INTRO_COLOR, "Building summary for: '" .. plyName .. "'", "\n" )

        writeCountData( "Props by model", data.props )
        writeCountData( "Constraints by class", data.constraints )
        writeCountData( "Ents by class", data.ents )
        writeCountData( "Alerts", data.alerts )
    end

    net.Receive( "CFC_ULX_BuildCheckResults", function()
        local json = util.Decompress( net.ReadData() )
        local data = util.JSONToTable( json )

        for plyName, data in pairs( data.players ) do
            writePlayerData( plyName, data )
        end

        -- Write the unknown data last
        writePlayerData( "Unowned", data.unknown )
    end )
end

-- TODO: alerts is a countTable ( { total = 0, items = { <alert> = <count>} )
local function addEntAlerts( ent, alerts )
end

-- TODO: plyData.alerts is a countTable ( { total = 0, items = { <alert> = <count>} )
local function plyAlerts( plyData )
end

-- Returns <category>,<identifier>
-- i.e. a prop returns "props",<model name>
-- a constraint returns "constraints",<class name>
-- TODO: Rename this to indicate it returns the identifier too
local function entCategory( ent )
    local class = ent:GetClass()

    if class == "prop_physics" then
        return "props", ent:GetModel()
    end

    if ent:IsConstraint() then
        return "constraints", class
    end

    return "ents", class
end

local function tallyEnt( ent, trackedPlayers, playerData, unknownData )
    local ent = rawget( allEnts, i )
    -- TODO: Make a more robust method to get owners (i.e. for wire holograms, npcs, grenades, etc.)
    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner()
    local validOwner = IsValid( owner )

    if not validOwner and trackedPlayers[owner] then return end

    local plyData = validOwner and rawget( playerData, owner ) or unknownData
    local category, identifier = entCategory( ent )

    local categoryData = rawget( plyData, category )
    local categoryTotal = rawget( categoryData, "total" )
    local itemData = rawget( categoryData, "items" )

    local count = rawget( itemData, identifier ) or 0
    rawset( itemData, identifier, count + 1 )
    rawset( categoryData, "total", categoryTotal + 1 )

    local alerts = rawget( plyData, "alerts" )
    addEntAlerts( ent, alerts )
end

local function countTable()
    return {
        total = 0,
        items = {}
    }
end

local function categoryTable()
    return {
        constraints = countTable(),
        props = countTable(),
        ents = countTable(),
        alerts = countTable()
    }
end

function cmd.buildCheck( caller, targets )
    if not caller:IsAdmin() then
        local now = CurTime()
        local lastcall = caller.lastBuildCheck or 0
        if lastCall > ( now - 5 ) then
            return -- TODO: Hey nerd that's too soon, chill will ya'
        end

        caller.lastBuildCheck = now
    end

    local targetsCount = #targets
    local buildData = {
        unknown = categoryTable(),
        players = {}
    }

    for i = 1, targets do
        local ply = rawget( targets, i )
        buildData.players[ply] = categoryTable()
    end

    local allEnts = ents.GetAll()
    local entsCount = #allEnts

    local unknownData = buildData.unknown
    local playerData = buildData.players

    for i = 1, entsCount do
        local ent = rawget( allEnts, i )
        tallyEnt( ent, targets, playerData, unknownData )
    end

    for ply, data in pairs( playerData ) do
        -- Check for player alerts
        addPlyAlerts( data )

        -- Convert keys to the player's name and steamid
        local plyString = ply:Nick() .. "<" .. ply:SteamID() .. ">"
        playerData[plyString] = data
        playerData[ply] = nil
    end

    local json = util.TableToJSON( buildData )
    local compress = util.Compress( json )

    net.Start( "CFC_ULX_BuildCheckResults" )
    net.WriteData( compress )
    net.Send( caller )

    -- TODO: Fancylogadmin some highlights from the data here
end

local command = ulx.command( CATEGORY_NAME, "ulx buildcheck", cmd.buildCheck, "!buildcheck" )
command:addParam{ type = ULib.cmds.PlayersArg }
command:defaultAccess( ULib.ACCESS_ADMIN )
command:help( "Returns building information about the target player(s)" )
