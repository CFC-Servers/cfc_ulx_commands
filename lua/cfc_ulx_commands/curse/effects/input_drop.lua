local EFFECT_NAME = "InputDrop"
local DROP_CHANCE = 0.95

--[[
    - Makes every input (except for aiming) have a chance to be ignored.
    - Unlike most other control-manipulating effects, this executes in both server and client realms.
--]]


local cmdsPerPly = {}


local function storeCommand( ply, cmd )
    cmdsPerPly[ply] = {
        Buttons = cmd:GetButtons(),
        ForwardMove = cmd:GetForwardMove(),
        SideMove = cmd:GetSideMove(),
        UpMove = cmd:GetUpMove(),
        Impulse = cmd:GetImpulse(),
        MouseX = cmd:GetMouseX(),
        MouseY = cmd:GetMouseY(),
        MouseWheel = cmd:GetMouseWheel(),
    }
end

local function applyCommand( ply, cmd )
    local prevCmd = cmdsPerPly[ply]
    if not prevCmd then return end

    cmd:SetButtons( prevCmd.Buttons )
    cmd:SetForwardMove( prevCmd.ForwardMove )
    cmd:SetSideMove( prevCmd.SideMove )
    cmd:SetUpMove( prevCmd.UpMove )
    cmd:SetImpulse( prevCmd.Impulse )
    cmd:SetMouseX( prevCmd.MouseX )
    cmd:SetMouseY( prevCmd.MouseY )
    cmd:SetMouseWheel( prevCmd.MouseWheel )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function( cursedPly )
        CFCUlxCurse.AddEffectHook( cursedPly, EFFECT_NAME, "StartCommand", "LBozo", function( ply, cmd )
            if ply ~= cursedPly then return end

            -- Use shared random and apply on both realms to fix special desyncs that would make it really easy to identify this effect.
            -- Most notably, the server dropping a new input to start firing a weapon causes the client to think it can shoot every frame until it stops getting dropped.
            if util.SharedRandom( cmd:CommandNumber(), 0, 1 ) <= DROP_CHANCE then
                applyCommand( ply, cmd )
            else
                storeCommand( ply, cmd )
            end
        end )
    end,

    onEnd = function( cursedPly )
        if cursedPly then
            cmdsPerPly[cursedPly] = nil
        end
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
    incompatabileEffects = {},
} )
