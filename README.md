# cfc_ulx_commands
Repo for CFC's custom ULX commands (that aren't separate)


## Dependencies:
- [ulx](https://github.com/TeamUlysses/ulx) and [ulib](https://github.com/TeamUlysses/ulib), obviously
- [gm_logger](https://github.com/CFC-Servers/gm_logger) for timed punishments
- [gm_playerload](https://github.com/CFC-Servers/gm_playerload) for timed punishments
- [cfc_notifications](https://github.com/CFC-Servers/cfc_notifications) for `ulx tpa`
- [Falco's Prop Protection](https://github.com/FPtje/Falcos-Prop-protection) for `ulx forcebuddy`
- Any CPPI system (such as [FPP](https://github.com/FPtje/Falcos-Prop-protection)) for commands that interact with player-spawned entities, such as `ulx freezeprops`
- [Wiremod](https://github.com/wiremod/wire) and [StarfallEX](https://github.com/thegrb93/StarfallEx) for `ulx chipban`
- `ulx pvpban` and `ulx buildban` require CFC's private pvp addon, and will silently remove itself without it

## Curse Effect Config:
A serverside config for curse effects can be made by creating `cfc_ulx_commands/curse/sv_config.json` in the server's `data/` folder.
Default/example settings can be found [here](/lua/cfc_ulx_commands/curse/sv_config_default.json).
Any live edits made to the config will apply after a changelevel (e.g. using the `ulx map` command).

