--[[
  da_log Integration Example

  This example demonstrates how to integrate da_log with other RedM resources
  and common patterns for various use cases.
]]

-- Example fxmanifest.lua for your resource
--[[
fx_version 'cerulean'
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Your Name'
description 'My Resource'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@da_log/log_sh.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}
]]

-- In your config.lua, define log level
--[[
Config = {}
Config.LogLevel = GetConvarInt("debug", 0) == 1 and "debug" or "info"
]]

-- At the top of your main script files, set the log level from config
--[[
-- Apply configuration
log.level = Config.LogLevel
]]

-- Resource initialization logging
local function InitResource()
    log.info("Starting resource:", GetCurrentResourceName(), "Version:", "1.0.0")

    -- Log configuration details at verbose level
    log.verbose("Configuration:", {
        debugMode = GetConvarInt("debug", 0) == 1,
        logLevel = log.level,
        usingDatabase = true,
        maxPlayers = 32
    })

    -- Log successful initialization
    log.info("Resource initialized successfully")
end

-- Error handling with detailed reporting
local function HandleError(err, location, data)
    log.error("Error in", location, ":", err)

    if data then
        log.debug("Error context:", data)
    end

    -- Log stack trace
    log.debug("Stack trace:", debug.traceback())

    -- You might want to trigger an event to notify admins or monitoring systems
    -- TriggerEvent("myResource:errorOccurred", location, err)
end

-- Safe function execution with error handling
local function SafeExecute(functionName, func, ...)
    local args = {...}

    log.spam("Executing function:", functionName)

    local success, result = pcall(function()
        return func(table.unpack(args))
    end)

    if not success then
        HandleError(result, functionName, args)
        return nil
    end

    log.spam("Function completed:", functionName)
    return result
end

-- Example: Database operations with logging
local function FetchPlayerData(playerId)
    log.debug("Fetching player data for ID:", playerId)

    -- Simulate database operation
    local startTime = GetGameTimer()

    -- Simulate data retrieval
    local playerData = {
        id = playerId,
        name = "Player" .. playerId,
        inventory = {},
        money = 500
    }

    -- Log performance metrics for expensive operations
    local endTime = GetGameTimer()
    local duration = endTime - startTime

    if duration > 100 then
        log.warn("Database query took", duration, "ms - Consider optimization")
    else
        log.verbose("Database query completed in", duration, "ms")
    end

    log.debug("Player data fetched:", playerData)
    return playerData
end

-- Example: Event handling with logging
-- In a real script, you'd register this with AddEventHandler
local function OnPlayerJoin(playerId)
    log.info("Player joined:", playerId)

    SafeExecute("FetchPlayerData", function()
        local playerData = FetchPlayerData(playerId)

        if not playerData then
            log.error("Failed to load player data for ID:", playerId)
            return
        end

        log.verbose("Player joined with data:", {
            id = playerData.id,
            name = playerData.name
        })

        -- Process player join logic...
    end)
end

-- Example: Admin command logging
local function ExecuteAdminCommand(adminId, target, commandName, args)
    -- Log all admin actions for audit purposes
    log.info("Admin command executed", {
        admin = adminId,
        target = target,
        command = commandName,
        arguments = args
    })

    -- Log more details at debug level
    log.debug("Admin command details:", {
        adminIdentifiers = {"steam:123", "license:abc"},
        targetIdentifiers = target and {"steam:456", "license:def"} or nil,
    })

    -- Execute the command...
end

-- Example: Integration with timer systems
local function StartPeriodicTask(taskName, interval)
    log.debug("Starting periodic task:", taskName, "Interval:", interval, "ms")

    -- Simulate setting up a timer
    -- In RedM, you might use SetTimeout or similar

    -- This function would be called periodically
    local function ExecuteTask()
        log.spam("Executing periodic task:", taskName)

        -- Task logic here...

        -- Log completion at verbose level
        log.verbose("Completed periodic task:", taskName)

        -- Schedule next execution...
    end

    -- Execute task immediately and schedule recurring
    ExecuteTask()
    log.debug("Periodic task started:", taskName)
end

-- Simulate resource startup
InitResource()

-- Simulate some typical resource operations
OnPlayerJoin(123)
ExecuteAdminCommand(1, 123, "give_money", {amount = 500})
StartPeriodicTask("cleanupTask", 60000)

-- Example error case
SafeExecute("ProcessInvalidData", function()
    -- This will cause an error
    local data = nil
    return data.property -- Will throw an error
end)
