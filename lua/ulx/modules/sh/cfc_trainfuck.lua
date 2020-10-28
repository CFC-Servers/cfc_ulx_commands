local plys = player.GetAll()

function trainFuck()
	local Y = 1
	for I,ply in pairs(plys) do
		local train = ents.Create("prop_physics")
		train:SetModel("models/props_trainstation/train001.mdl")
		train:SetPos(ply:GetPos()+Vector(0,-1000,300))
		train:Spawn()
		
		local phys = train:GetPhysicsObject()
		
		if (IsValid(phys)) then
			phys:ApplyForceCenter((ply:GetPos()-train:GetPos())*1000000000)
			
			timer.Create("trainFuckTimer"..Y,1.5,1,function()
				train:Remove()
			end)
		end
		Y = Y + 1
	end
end

trainFuck()