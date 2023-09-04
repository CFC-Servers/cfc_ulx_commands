local EFFECT_NAME = "InputDelay"
local DELAY_AMOUNT_MIN = 10 -- Amount of cmd ticks to delay input by.
local DELAY_AMOUNT_MAX = 30 -- Amount of cmd ticks to delay input by.
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"


local tableInsert = table.insert
local tableRemove = table.remove


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        local delayAmount = math.random( DELAY_AMOUNT_MIN, DELAY_AMOUNT_MAX )
        local clientStack = {}
        local serverStack = {}
        local clientStackCount = 0
        local serverStackCount = 0
        local realAng

        hook.Add( "CreateMove", HOOK_PREFIX .. "LBozo", function( cmd )
            local isClient = cmd:CommandNumber() == 0
            local targetStack = isClient and clientStack or serverStack
            local targetStackCount = isClient and clientStackCount or serverStackCount

            tableInsert( targetStack, {
                Buttons = cmd:GetButtons(),
                ForwardMove = cmd:GetForwardMove(),
                SideMove = cmd:GetSideMove(),
                UpMove = cmd:GetUpMove(),
                Impulse = cmd:GetImpulse(),
                MouseX = cmd:GetMouseX(),
                MouseY = cmd:GetMouseY(),
                MouseWheel = cmd:GetMouseWheel(),
            } )

            if targetStackCount < delayAmount then
                if isClient then
                    clientStackCount = clientStackCount + 1
                else
                    serverStackCount = serverStackCount + 1
                end

                return
            end

            local newCmd = tableRemove( targetStack, 1 )

            cmd:SetButtons( newCmd.Buttons )
            cmd:SetForwardMove( newCmd.ForwardMove )
            cmd:SetSideMove( newCmd.SideMove )
            cmd:SetUpMove( newCmd.UpMove )
            cmd:SetImpulse( newCmd.Impulse )
            cmd:SetMouseX( newCmd.MouseX )
            cmd:SetMouseY( newCmd.MouseY )
            cmd:SetMouseWheel( newCmd.MouseWheel )

            if not realAng then
                realAng = cmd:GetViewAngles()
            end

            realAng.y = realAng.y - cmd:GetMouseX() * 0.022
            realAng.x = math.Clamp( realAng.x + cmd:GetMouseY() * 0.022, -89, 89 )
            realAng:Normalize()

            cmd:SetViewAngles( realAng )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "CreateMove", HOOK_PREFIX .. "LBozo" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = nil,
} )
