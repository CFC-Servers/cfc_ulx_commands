----- SETUP ----

hook.Add( "Think", "CFC_ULXCommands_Curse_EffectTick", function()
    local ply = LocalPlayer()
    local effect = CFCUlxCurse.GetCurrentEffect( ply )

    if effect then
        effect.onTick( ply )
    end
end )


net.Receive( "CFC_ULXCommands_Curse_StartEffect", function()
    local effectName = net.ReadString()
    local effect = CFCUlxCurse.GetEffectByName( effectName )
    if not effect then return end

    local ply = LocalPlayer()

    ply.CFCUlxCurseEffect = effect
    effect.onStart( ply )
end )

net.Receive( "CFC_ULXCommands_Curse_EndEffect", function()
    local effectName = net.ReadString()
    local effect = CFCUlxCurse.GetEffectByName( effectName )
    if not effect then return end

    local ply = LocalPlayer()

    ply.CFCUlxCurseEffect = nil
    effect.onEnd( ply )
end )
