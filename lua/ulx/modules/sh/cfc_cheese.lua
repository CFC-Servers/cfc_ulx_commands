CFCUlxCommands.cheese = CFCUlxCommands.cheese or {}
local cmd = CFCUlxCommands.cheese

local CATEGORY_NAME = "Fun"
local BASE_CHEESE_MODELS = {
    "models/hunter/triangles/025x025.mdl",
    "models/hunter/triangles/05x05x05.mdl",
    "models/hunter/triangles/1x05x05.mdl",
    "models/props_c17/playgroundtick-tack-toe_block01a.mdl"
}

function cmd.cheese( caller, targets, shouldUncheese )
    local prop = CFCUlxCommands.propify.propify( caller, targets, BASE_CHEESE_MODELS[ math.random( #BASE_CHEESE_MODELS ) ], shouldUncheese )
    
    if not prop then return end
    
    prop:SetMaterial( "models/XQM/Rails/gumball_1" )
    prop:SetColor( Color( 255, math.Rand( 150, 221 ), 6, 255 )  )
    prop:GetPhysicsObject():SetMaterial( "dirt" )
end

local cheeseCommand = ulx.command( CATEGORY_NAME, "ulx cheese", cmd.cheese, "!cheese" )
cheeseCommand:addParam{ type = ULib.cmds.PlayersArg }
cheeseCommand:addParam{ type = ULib.cmds.BoolArg, invisible = true }
cheeseCommand:defaultAccess( ULib.ACCESS_ADMIN )
cheeseCommand:help( "Turns the target(s) into cheese." )
cheeseCommand:setOpposite( "ulx uncheese", { _, _, true }, "!uncheese" )
