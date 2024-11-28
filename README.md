# Daggre Actual's Log Levels (da_log)
## Version & Status
v0.1

## Description
da_log is a library that provides logging via log levels for RedM. The library
provides six log levels, which can be used to filter the output of the logging
in the console, both client and server side. Level defaults can be set for LIVE
and DEV environments, and the log level for each resource can be set at
runtime. The logger also uses pretty printing to make the output more readable,
printing table values recursively when possible.

### Levels
- Error
- Warn
- Info
- Verbose
- Debug
- Spam

### Level
Allows setting the log level for a resource in code.

Example:
```lua
log.level = "debug"
log.spam("This message will be hidden")
log.level = "spam"
log.spam("This message will be output")
```

### Line
Line will print the short source debug info for the current code line.

Example:
```lua
log.warn("Should not reach this line of code: " .. log.line())
```
Output:
```
[         script:test] WARN: Should not reach this line of code: @test/test_log.lua:30
```

### Format
Format will apply the print formatting and output data types to a string.
Example:
```lua
print(log.format({a="This",b="is",c="a",d="table"}))
```

Output:
```
[         script:test] format test:     {
[         script:test]   [c] = "a",
[         script:test]   [d] = "table",
[         script:test]   [a] = "This",
[         script:test]   [b] = "is",
[         script:test] }
```

Info is the default log level. If the debug convar is set in the server.cfg
then the Debug level will be the default.

## Usage
Import the logger into your script through the fxmanifest:
```lua
shared_scripts {
    '@da_log/log_sh.lua',
}
```

Use the logger in your script:
```lua
log.error('This is an error message')
log.warn('This is a warning message')
log.info('This is an info message')
log.verbose('This is a verbose message')
log.debug('This is a debug message')
log.spam('This is a spam message')
```

Set the log level for a resource at runtime:
```
log set <resource_name> <log_level>
```

Get the log level for a resource at runtime:
```
log get <resource_name>
```

## Installation
Clone the **da_log** repository into your servers resources folder:
```bash
cd resources
git clone git@github.com:daggre/da_log.git
```
Add `ensure da_log` to your preferred resource config. (Default: server.cfg)
If you want to enable debug logging by default, set a read only convar debug to 1 in server.cfg.
```
setr debug 1
```
## Support
- Discord: daggre
- Discord Server: [da_dev](https://discord.com/invite/JgteBpXGaA)

## Authors and Acknowledgment
- daggre_actual
