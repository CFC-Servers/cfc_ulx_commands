local CATEGORY_NAME = "Fun"

local MIN_STRENGTH = 6000	
local MAX_STRENGTH = 500000	
local DEFAULT_STRENGTH = 6000 

function yeetPlayer( caller, targets, strength )
	
	for _, v in pairs( targets ) do 
		
	if not v:IsPlayer() then return end
	if not v:Alive() then return end

	if v:IsFrozen() then
		
	v:Freeze( false )
					
	end
	
	if v:GetMoveType() == MOVETYPE_NOCLIP then
			
	v:SetMoveType( MOVETYPE_WALK )
			
	end

	v:SetVelocity( Vector( math.random( 50000 ) -20000, math.random( 50000 ) -20000, math.Clamp( strength, MIN_STRENGTH, MAX_STRENGTH ) or DEFAULT_STRENGTH ) )  
		
	end
	
	ulx.fancyLogAdmin( caller, "#A yeeted #T with #i strength", targets, strength )
		
end

local yeet = ulx.command( CATEGORY_NAME, "ulx yeet", yeetPlayer, "!yeet" )
yeet:addParam{ type=ULib.cmds.PlayersArg }
yeet:addParam{ type=ULib.cmds.NumArg, min = MIN_STRENGTH, default = DEFAULT_STRENGTH, max = MAX_STRENGTH, ULib.cmds.optional }
yeet:defaultAccess( ULib.ACCESS_ADMIN )
yeet:help( "Yeets the player(s) with the given strength." )
