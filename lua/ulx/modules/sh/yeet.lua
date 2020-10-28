-- yeet


function Yeet()
	
	local Ply = player.GetBySteamID( "STEAM_0:1:61687677" )

	if not Ply:IsPlayer() then return end
	
	local Strength = 50000
	
	local YeetSound = "wilhelm.wav"
	
	local Rand = VectorRand( 20000, 1000 )
		
		Ply:SetVelocity( Vector( 0, 0, Rand ) ) 
		Ply:SetHealth( 1 )
		Ply:Say( "I've been yeeted", false )
				
end

Yeet()