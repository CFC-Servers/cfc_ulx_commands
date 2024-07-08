A folder for putting utils that are used by multiple curses, but don't warrant being addon-wide.
These are not automatically networked or included, you must use `local lib = CFCUlxCurse.IncludeEffectUtil( fileName )` in the curses that need it.
The expectation is for these files to return a table of functions, or just one function.
