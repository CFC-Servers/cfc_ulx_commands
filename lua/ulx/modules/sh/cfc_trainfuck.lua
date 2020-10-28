CATEGORY_NAME = "Trainfuck"

local function trainFuck( callingPlayer, targetPlayers )
	local Y = 1
	for I,ply in pairs(targetPlayers) do
		local train = ents.Create("prop_physics")
		train:SetModel("models/props_trainstation/train001.mdl")
		train:SetPos(ply:GetPos()+Vector(0,-1000,300))
		train:Spawn()
		
		local phys = train:GetPhysicsObject()
		
		if (IsValid(phys)) then
			if ply:GetMoveType(MOVETYPE_NOCLIP) then
				ply:SetMoveType(MOVETYPE_WALK)
			end
			ply:ExitVehicle()
			phys:ApplyForceCenter((ply:GetPos()-train:GetPos())*1000000000)
			timer.Create("trainFuckTimer"..Y,1.5,1,function()
				train:Remove()
			end)
		end
		Y = Y + 1
	end
	ulx.fancyLogAdmin( callingPlayer, "#A trainfucked #T", targetPlayers )
end

local trainfuckCMD = ulx.command( CATEGORY_NAME, "ulx trainfuck", trainFuck, "!trainfuck" )
trainfuckCMD:addParam{ type = ULib.cmds.PlayersArg }
trainfuckCMD:defaultAccess( ULib.ACCESS_ADMIN )
trainfuckCMD:help( "Trainfucks target( s )" )
