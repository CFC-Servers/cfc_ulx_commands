include('shared.lua')
 
language.Add( "train_fucked" , "Train fucked!" )
killicon.Add( "train_fucked", "cfc_trainfuck_kill_icon", Color( 255, 255, 255, 255 ) )

function ENT:Draw()
    self.Entity:DrawModel()
end
