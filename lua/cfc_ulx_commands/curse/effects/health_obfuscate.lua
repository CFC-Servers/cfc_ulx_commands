local EFFECT_NAME = "HealthObfuscate"
local HOOK_PREFIX = "CFC_ULXCommands_Curse_" .. EFFECT_NAME .. "_"

--[[
    - Randomizes displayed health every frame by drawing a fake HUD element.
    - Unfortunately, using :SetMaxHealth() on CLIENT only lingers for a split second.
        - It also does nothing in Think hook, timer.Create(), and various other places.
    - Furthermore, the health element is drawn by HL2 internally, and glua can only block it, not modify it.
--]]


local COLOR_BACKGROUND = Color( 0, 0, 0, 76 )
local HEALTH_LABEL_FONT = HOOK_PREFIX .. "HealthLabel"
local HEALTH_NUMBER_FONT = HOOK_PREFIX .. "HealthNumbers"

if CLIENT then
    --[[
        - HL2 text rendering auto-scales fonts to the screen resolution, while glua rendering does not.
        - As such, we have to create our own fonts with the correct scaling factor.
    --]]
    surface.CreateFont( HEALTH_LABEL_FONT, {
        font = "Verdana",
        size = ScreenScaleH( 9 ),
        weight = 1000,
        antialias = true,
    } )

    surface.CreateFont( HEALTH_NUMBER_FONT, {
        font = "HalfLife2",
        size = ScreenScaleH( 32 ),
        weight = 0,
        antialias = true,
        additive = true,
    } )
end


CFCUlxCurse.RegisterEffect( {
    name = EFFECT_NAME,

    onStart = function()
        if SERVER then return end

        hook.Add( "HUDShouldDraw", HOOK_PREFIX .. "HideBaseHealthDisplay", function( name )
            if name == "CHudHealth" then return false end
        end )

        hook.Add( "HUDPaint", HOOK_PREFIX .. "FakeHealthDisplay", function()
            if not LocalPlayer():Alive() then return end

            local fakeHealth = math.random( 1, LocalPlayer():GetMaxHealth() )
            local scale = ScreenScaleH( 1 )

            -- Background
            draw.RoundedBox( 4 * scale, 16 * scale, 432 * scale, 102 * scale, 36 * scale, COLOR_BACKGROUND )

            -- "HEALTH" Text
            surface.SetFont( HEALTH_LABEL_FONT )
            surface.SetTextColor( 255, 236, 12, 255 )
            surface.SetTextPos( ( 16 + 8 ) * scale, ( 432 + 20 ) * scale )
            surface.DrawText( "HEALTH", false )

            -- Health Number
            surface.SetFont( HEALTH_NUMBER_FONT )
            surface.SetTextColor( 255, 236, 12, 255 )
            surface.SetTextPos( ( 16 + 50 ) * scale, ( 432 + 2 ) * scale )
            surface.DrawText( tostring( fakeHealth ), true )
        end )
    end,

    onEnd = function()
        if SERVER then return end

        hook.Remove( "HUDShouldDraw", HOOK_PREFIX .. "HideBaseHealthDisplay" )
        hook.Remove( "HUDPaint", HOOK_PREFIX .. "FakeHealthDisplay" )
    end,

    minDuration = nil,
    maxDuration = nil,
    onetimeDurationMult = nil,
    excludeFromOnetime = true,
} )
