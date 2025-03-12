# Daggre Actual's Log Levels (da_log)

## Version & Status
v0.1

## Description
`da_log` is a lightweight and powerful logging library for RedM that provides consistent, level-based logging across client and server-side scripts. It features pretty-printing of complex data structures, colored output, and runtime configuration of log levels.

The library is designed to help developers debug their code more effectively by providing different levels of verbosity that can be adjusted based on the environment (development vs. production).

## Features
- Six customizable log levels with colored output
- Pretty-printing of complex data structures (including tables, vectors)
- Runtime configuration of log levels per resource
- Source line information for easier debugging
- Environment-aware default configuration (DEV vs LIVE)
- Shared client and server-side implementation

## Log Levels

The library provides six log levels in order of increasing verbosity:

| Level | Description | Default Color | Use Case |
|-------|-------------|--------------|----------|
| `error` | Critical errors | Red | Application crashes, unrecoverable errors |
| `warn` | Warnings | Yellow | Deprecated features, potential issues |
| `info` | General information | White | Important events, user actions |
| `verbose` | Detailed information | White | Step-by-step operations |
| `debug` | Debugging information | Yellow | Values of variables, function calls |
| `spam` | High-frequency debug | Magenta | Loop iterations, frequent events |

The default log level is `info` in production environments and `debug` when the `debug` convar is set to `1`.

## API Reference

### Log Functions

Each log level has a corresponding function:

```lua
log.error(...) -- Critical errors that require immediate attention
log.warn(...)  -- Warnings that don't stop execution but indicate potential issues
log.info(...)  -- General information about application operation
log.verbose(...) -- More detailed information
log.debug(...) -- Information useful for debugging
log.spam(...)  -- Extremely verbose information for fine-grained debugging
```

All log functions accept any number of arguments of any type. Complex types like tables are pretty-printed.

### Log Level Configuration

```lua
-- Get current log level
local currentLevel = log.level

-- Set log level in code
log.level = "debug"  -- Can be "error", "warn", "info", "verbose", "debug", or "spam"
log.level = 5        -- Can also use numeric values (1-6)
```

### Utility Functions

#### log.line([stackLevel])
Returns the current source file and line number for debugging.

```lua
log.warn("Unexpected value encountered: " .. log.line())
-- Output: WARN: Unexpected value encountered: @resources/my_script/client.lua:42
```

Parameters:
- `stackLevel` (optional): Integer indicating which stack frame to examine (default: 1)

#### log.format(...)
Formats values for output, converting complex types to readable strings.

```lua
local formattedString = log.format({name = "Player", health = 100})
print(formattedString)
```

## Runtime Configuration

### Console Commands

The following console commands can be used to configure logging at runtime:

```
log set <resource_name> <log_level>  -- Set log level for a specific resource
log set all <log_level>              -- Set log level for all resources
log get <resource_name>              -- Get current log level for a resource
log list                             -- List all available log levels
```

### Server Configuration

To enable debug logging by default, add the following to your `server.cfg`:

```
setr debug 1
```

## Integration Guide

### Basic Integration

1. Import the logger in your `fxmanifest.lua`:

```lua
shared_scripts {
    '@da_log/log_sh.lua',
}
```

2. Use the logger in your code:

```lua
-- Simple logging
log.info("Player connected:", playerName)

-- Debug information with tables
log.debug("Player state:", {
    id = player.id,
    health = player.health,
    position = player.position
})

-- Error reporting
log.error("Failed to load resource:", resourceName, "Error:", errorMessage)
```

### Environment-Specific Configuration


If not using convar debug, you can set up the specific environment level:

```lua
-- Production setup
if not IsDebug() then
    log.level = "info"  -- Only show info and above in production
end

-- Development setup
if IsDebug() then
    log.level = "debug"  -- Show more detailed logs in development
end
```

### Best Practices

- Use appropriate log levels based on message importance
- Include contextual information in log messages
- Use tables to log complex data structures
- Add log.line() to error messages to pinpoint locations
- Use string formatting for cleaner log messages:
  ```lua
  log.info(("Player %s connected from %s"):format(playerName, playerIP))
  ```

## Installation

Clone the **da_log** repository into your server's resources folder:
```bash
cd resources
git clone https://github.com/daggre/da_log.git
```

Add `ensure da_log` to your preferred resource config (usually `server.cfg`).

## Support and Contribution

- Discord: daggre
- Discord Server: [da_dev](https://discord.com/invite/JgteBpXGaA)
- GitHub: [da_log](https://github.com/daggre/da_log)

## Authors and Acknowledgment
- daggre_actual

## License
[MIT License](LICENSE)
