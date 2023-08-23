AddCSLuaFile( "cfc_ulx_commands/curse/sh_utils.lua" )

include( "cfc_ulx_commands/curse/sh_utils.lua" )


local effects_modules = file.Find( "cfc_ulx_commands/curse/effects/*.lua", "LUA" )

for _, fileName in ipairs( effects_modules ) do
    AddCSLuaFile( "cfc_ulx_commands/curse/effects/" .. fileName )
    include( "cfc_ulx_commands/curse/effects/" .. fileName )
end
