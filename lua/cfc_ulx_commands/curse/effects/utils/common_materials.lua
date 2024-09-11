
if SERVER then return {} end

return {
    gameMat = CreateMaterial( "cfc_ulx_commands_curse_game_rt", "UnlitGeneric", {
        ["$basetexture"] = "_rt_fullframefb",
    } ),

    gameMatIgnorez = CreateMaterial( "cfc_ulx_commands_curse_game_rt_ignorez", "UnlitGeneric", {
        ["$basetexture"] = "_rt_fullframefb",
        ["$ignorez"] = 1,
    } ),
}
