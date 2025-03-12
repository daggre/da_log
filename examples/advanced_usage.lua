--[[
  da_log Advanced Usage Example

  This example demonstrates more advanced features and integration patterns:
  - Environment-specific configuration
  - Integration with resource events
  - Performance considerations
  - Error tracking
]]

-- Environment-aware configuration
local function IsDebug()
    return GetConvarInt('debug', 0) == 1
end

-- Configure log level based on environment
if IsDebug() then
    log.level = "debug"  -- Development environment: show detailed logs
else
    log.level = "info"   -- Production environment: show only important information
end

-- System integration example
local function InitializeResource()
    log.info("Initializing inventory system...")

    -- Register event handlers
    AddEventHandler("playerDropped", function(reason)
        local playerId = source
        log.debug("Player dropped", playerId, "Reason:", reason)
        -- Handle inventory cleanup
    end)

    -- Resource startup reporting
    local resourceName = GetCurrentResourceName()
    log.info("Resource started:", resourceName, "Environment:", IsDebug() and "DEV" or "PROD")
end

-- Conditional logging for performance
local playerPositions = {}
local lastPositionLog = 0

local function UpdatePlayerPosition(playerId, position)
    playerPositions[playerId] = position

    -- Only log positions every 5 seconds to avoid spam
    local now = GetGameTimer()
    if now - lastPositionLog > 5000 then
        log.spam("Player positions:", log.format(playerPositions))
        lastPositionLog = now
    end
end

-- Error tracking with context
local errors = {}

local function TrackError(component, message, data)
    table.insert(errors, {
        component = component,
        message = message,
        data = data,
        stackTrace = log.line(2)  -- Capture caller's location
    })

    -- Log the error
    log.error("[" .. component .. "]", message, data)

    -- If we have too many errors, log a summary and clear
    if #errors > 100 then
        log.warn("Excessive errors detected!", #errors, "errors since startup")

        -- Count errors by component
        local errorCounts = {}
        for _, err in ipairs(errors) do
            errorCounts[err.component] = (errorCounts[err.component] or 0) + 1
        end

        log.warn("Error distribution:", errorCounts)
        errors = {} -- Reset error tracking
    end
end

-- Performance timing helper
local function TimeExecution(name, func, ...)
    local startTime = GetGameTimer()
    local result = {func(...)}
    local endTime = GetGameTimer()

    -- Only log slow operations
    local duration = endTime - startTime
    if duration > 10 then -- Log operations taking more than 10ms
        log.debug("Performance", name, "took", duration, "ms")
    end

    return table.unpack(result)
end

-- Example usage of advanced patterns
local function ProcessPlayerInventory(playerId, items)
    log.debug("Processing inventory for player", playerId)

    return TimeExecution("ProcessInventory", function()
        for _, item in ipairs(items) do
            -- Process each item
            if not item.id then
                TrackError("INVENTORY", "Invalid item in player inventory", {
                    playerId = playerId,
                    item = item
                })
            else
                log.spam("Processing item", item.id)
            end
        end

        log.verbose("Inventory processed for player", playerId, "#items:", #items)
        return true
    end)
end

-- Simulate some activity
InitializeResource()
UpdatePlayerPosition(1, vector3(100, 200, 30))
ProcessPlayerInventory(1, {
    {id = "item_1", name = "Revolver"},
    {id = "item_2", name = "Rifle"},
    {name = "Invalid Item"} -- This will trigger an error
})

-- Dynamic log level adjustment based on server load
local function AdjustLogLevelForLoad()
    local resourceCount = GetNumResources()
    local playerCount = GetNumPlayerIndices()

    -- Under high load, reduce logging verbosity
    if playerCount > 30 or resourceCount > 100 then
        if log.level ~= "warn" then
            log.warn("High server load detected, reducing log verbosity",
                "Players:", playerCount, "Resources:", resourceCount)
            log.level = "warn"
        end
    else
        -- Restore normal logging under normal load
        if IsDebug() and log.level ~= "debug" then
            log.info("Normal server load, restoring debug log level")
            log.level = "debug"
        elseif not IsDebug() and log.level ~= "info" then
            log.info("Normal server load, restoring info log level")
            log.level = "info"
        end
    end
end

-- This would typically be called periodically
AdjustLogLevelForLoad()
