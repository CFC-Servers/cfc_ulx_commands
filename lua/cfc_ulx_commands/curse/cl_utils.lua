----- SETUP ----

net.Receive( "CFC_ULXCommands_Curse_StartEffect", function()
    local effectName = net.ReadString()
    local effectData = CFCUlxCurse.GetEffectByName( effectName )
    if not effectData then return end

    local duration = net.ReadFloat()

    local ply = LocalPlayer()
    local curseEffects = CFCUlxCurse.GetCurrentEffects( ply )

    curseEffects[effectName] = {
        effectData = effectData,
        expireTime = CurTime() + duration,
    }

    ProtectedCall( function()
        effectData.onStart( ply, duration )
    end )
end )

net.Receive( "CFC_ULXCommands_Curse_EndEffect", function()
    local effectName = net.ReadString()
    local effectData = CFCUlxCurse.GetEffectByName( effectName )
    if not effectData then return end

    local ply = LocalPlayer()
    local curseEffects = CFCUlxCurse.GetCurrentEffects( ply )

    curseEffects[effectName] = nil

    ProtectedCall( function()
        effectData.onEnd( ply )
    end )

    CFCUlxCurse.RemoveEffectHooks( ply, effectName )
    CFCUlxCurse.RemoveEffectTimers( ply, effectName )
end )
