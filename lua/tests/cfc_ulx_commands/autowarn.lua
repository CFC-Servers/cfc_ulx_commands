return {
    groupName = "AutoWarn",
    cases = {
        {
            name = "buildReason should return the correct format with duration",
            func = function()
                local buildReason = CFCUlxCommands.AutoWarner.buildReason

                local expected = "Test Reason (ulx test 1 minute)"
                local actual = buildReason( "Test Reason", "ulx test", 60 )

                expect( actual ).to.equal( expected )
            end
        },
        {
            name = "buildReason should return the correct format with no duration",
            func = function()
                local buildReason = CFCUlxCommands.AutoWarner.buildReason

                local expected = "Test Reason (ulx test)"
                local actual = buildReason( "Test Reason", "ulx test" )

                expect( actual ).to.equal( expected )
            end
        },


        {
            name = "warn should use an entity's steamid64",
            func = function()
                local warn = CFCUlxCommands.AutoWarner.warn

                local steamID64 = "12345"
                local ent = {
                    SteamID64 = function()
                        return steamID64
                    end
                }

                local _isentity = isentity
                stub( _G, "isentity" ).with( function( o, ... )
                    if o == ent then return true end
                    return _isentity( o )
                end )

                stub( _G, "awarn_warnplayerid" ).with( function( _, target, _ )
                    expect( target ).to.equal( steamID64 )
                end )

                warn("ulx ban", nil, ent, nil )
            end
        },
        {
            name = "warn should take a non-64 steam ID",
            func = function()
                local warn = CFCUlxCommands.AutoWarner.warn

                local steamID = "STEAM_0:0:21170873"
                local steamID64 = "76561198002607474"

                stub( _G, "awarn_warnplayerid" ).with( function( _, target, _ )
                    expect( target ).to.equal( steamID64 )
                end )

                warn("ulx ban", nil, steamID, nil )
            end
        },


        {
            name = "getTargets should convert a single element into a table",
            func = function()
                local getTargets = CFCUlxCommands.AutoWarner.getTargets

                local indices = { targets = 1 }
                local args = { "example" }

                local result = getTargets( indices, args )
                expect( result ).to.beA( "table" )
                expect( result[1] ).to.equal( "example" )
            end
        },
        {
            name = "getTargets should return the given table",
            func = function()
                local getTargets = CFCUlxCommands.AutoWarner.getTargets

                local indices = { targets = 1 }
                local args = { { "example" } }

                local result = getTargets( indices, args )
                expect( result ).to.beA( "table" )
                expect( result ).to.equal( args[1] )
            end
        },


        {
            name = "shouldWarn should not warn",
            when = "skipEmptyOption is enabled",
            func = function()
                local shouldWarn = CFCUlxCommands.AutoWarner.shouldWarn

                local cmd =  { skipEmptyReason = true }

                expect( shouldWarn( cmd, nil, nil ) ).to.beFalse()
                expect( shouldWarn( cmd, nil, "" ) ).to.beFalse()
                expect( shouldWarn( cmd, nil, "reason" ) ).to.beFalse()
                expect( shouldWarn( cmd, nil, "No reason specified" ) ).to.beFalse()
            end
        },
        {
            name = "shouldWarn should not warn",
            when = "duration is less than minDuration",
            func = function()
                local shouldWarn = CFCUlxCommands.AutoWarner.shouldWarn

                local cmd = {
                    minDuration = 5
                }

                local duration = 1
                expect( shouldWarn( cmd, duration, nil ) ).to.beFalse()
            end
        },
        {
            name = "shouldWarn should warn",
            when = "no reason or duration is given and skipEmptyReason is disabled",
            func = function()
                local shouldWarn = CFCUlxCommands.AutoWarner.shouldWarn

                local cmd = {}

                expect( shouldWarn( cmd, nil, nil ) ).to.beTrue()
            end
        },


        {
            name = "parseCommand should retrieve the duration from the command indices",
            func = function()
                local parseCommand = CFCUlxCommands.AutoWarner.parseCommand
                stub( CFCUlxCommands.AutoWarner, "getTargets" ).returns( {} )

                local cmd = {
                    indices = {
                        duration = 1,
                        reason = 2
                    }
                }

                local args = { 5, "reason" }

                local parsedDuration = parseCommand( cmd, args )
                expect( parsedDuration ).to.equal( 5 )
            end
        },
        {
            name = "parseCommand should return no duration if none is given",
            func = function()
                local parseCommand = CFCUlxCommands.AutoWarner.parseCommand
                stub( CFCUlxCommands.AutoWarner, "getTargets" ).returns( {} )

                local cmd = {
                    indices = {
                        reason = 1
                    }
                }

                local args = { "reason" }

                local parsedDuration = parseCommand( cmd, args )
                expect( parsedDuration ).to.beNil()
            end
        },
        {
            name = "parseCommand should retrieve the reason from the command indices",
            func = function()
                local parseCommand = CFCUlxCommands.AutoWarner.parseCommand
                stub( CFCUlxCommands.AutoWarner, "getTargets" ).returns( {} )

                local cmd = {
                    indices = {
                        reason = 1
                    }
                }

                local args = { "reason" }

                local _, parsedDuration = parseCommand( cmd, args )
                expect( parsedDuration ).to.equal( "reason" )
            end
        },
    }
}
