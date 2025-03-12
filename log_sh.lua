--[[
  da_log - Logging Library for RedM

  A lightweight, flexible logging system with log levels, pretty printing,
  and runtime configuration.

  Version: 0.1.0
  Author: daggre_actual
  License: MIT
]]

-- Ensure no global namespace collision
assert(log == nil, "Global namespace collision 'log' is previously defined: Aborting @da_log resource setup")

-----------------------------------------------------------
-- Formatting Functions
-----------------------------------------------------------

---Format a single value for display, handling different types
---@param val any The value to format
---@param indent number? Optional indentation level for nested tables
---@return string Formatted string representation
local function _formatValue(val, indent)
    indent = indent or 0
    local t = type(val)

    -- Handle basic types
    if t == "nil" then return "nil"
    elseif t == "string" and indent == 0 then return val
    elseif t == "string" then return '"' .. val .. '"'
    elseif t == "number" then return tostring(val)
    elseif t == "boolean" then return tostring(val)
    elseif t == "function" then return tostring(val)
    elseif t == "userdata" then return "userdata: " .. tostring(val)

    -- Handle table type with recursive formatting
    elseif t == "table" then
        local fTable = {}
        local indentStr = string.rep("  ", indent)
        table.insert(fTable, "{\n")
        for key, subVal in pairs(val) do
            local fKey = _formatValue(key)
            local fVal = _formatValue(subVal, indent + 1)
            table.insert(fTable, indentStr .. "  [" .. fKey .. "] = " .. fVal .. ",\n")
        end
        table.insert(fTable, indentStr .. "}")
        return table.concat(fTable)

    -- Handle vector types with precision formatting
    elseif t == "vector2" then
        return ("vec2(%.3f, %.3f)"):format(val.x, val.y)
    elseif t == "vector3" then
        return ("vec3(%.3f, %.3f, %.3f)"):format(val.x, val.y, val.z)
    elseif t == "vector4" then
        return ("vec4(%.3f, %.3f, %.3f, %.3f)"):format(val.x, val.y, val.z, val.w)

    -- Unknown type fallback
    else
        return "unknown type"
    end
end

---Format multiple values, concatenating them with tabs
---@param ... any Values to format
---@return string Formatted string with all values
local function _formatValues(...)
    local args = {...}
    local fStrings = {}
    for _, val in ipairs(args) do
        table.insert(fStrings, _formatValue(val))
    end
    return table.concat(fStrings, "\t")
end

-----------------------------------------------------------
-- Log Level Configuration
-----------------------------------------------------------

-- Define log levels in order of increasing verbosity
-- Each level can have:
--   name: string identifier
--   prefixColor: color code for the prefix
--   prefix: text to display before the message
--   color: color code for the message text
local LogLevels = {
    { name = "error", prefixColor = 8, prefix = "ERROR: ", color = 8, },  -- Red
    { name = "warn", prefixColor = 3, prefix = "WARN: " },                -- Yellow
    { name = "info" },                                                    -- Default color
    { name = "verbose" },                                                 -- Default color
    { name = "debug", color = 3, },                                       -- Yellow
    { name = "spam", prefixColor = 5, prefix = "+ ", color = 3, },        -- Magenta prefix
}

-- Create lookup table for level names and numbers
local LevelLookup = {}
for i, v in ipairs(LogLevels) do
    LevelLookup[v.name] = i  -- Allow lookup by name (e.g. "debug" -> 5)
    LevelLookup[i] = i       -- Allow lookup by number (e.g. 5 -> 5)
end

-----------------------------------------------------------
-- Logger Implementation
-----------------------------------------------------------

-- Create the Log object with metatable for dynamic log level functions
local Log = setmetatable({
        -- Default log level is based on the debug convar (debug=1 enables debug level)
        level = GetConvarInt("debug", 0) == 1 and "debug" or "info",

        -- Get current source file and line number for debugging
        ---@param stackLevel number Optional stack level to examine (default: 1)
        ---@return string Source file and line information
        line = function(stackLevel)
            stackLevel = stackLevel or 1
            local nfo = debug.getinfo(stackLevel+1, "Sl")
            return nfo.short_src .. ":" .. nfo.currentline
        end,

        -- Format values for output
        format = _formatValues
    }, {
        -- Dynamic creation of log.<level> functions
        __index = function(self, logType)
            return setmetatable({}, {
                __call = function(_, ...)
                    -- Get numeric values for current log level and requested log type
                    local logLevel = LevelLookup[self.level]
                    local levelNumber = LevelLookup[logType]

                    -- Skip logging if the requested level is more verbose than current setting
                    if levelNumber and levelNumber > logLevel then
                        return
                    end

                    -- Validate the log type
                    local logData = LogLevels[levelNumber]
                    if not logData then
                        print(("^1ERROR:^7 Invalid log type (%s)"):format(logType))
                        return
                    end

                    -- Format and print the log message with appropriate colors
                    print(
                        (logData.prefixColor and "^"..logData.prefixColor or "") ..   -- Prefix color
                        (logData.prefix or "") ..                                     -- Prefix text
                        (not logData.color and logData.prefixColor and "^7" or "") .. -- Reset color if needed
                        (logData.color and "^"..logData.color or "") ..               -- Message color
                        _formatValues(...) ..                                         -- Formatted message
                        (logData.color and "^7" or "")                                -- Reset color if needed
                    )
                end
            })
        end
})

-- Create global log object
_ENV.log = Log

-----------------------------------------------------------
-- Event Handlers for Runtime Configuration
-----------------------------------------------------------

-- Handler to set log level at runtime
AddEventHandler("da_log:setLevel", function(resource, level)
    -- Only apply to current resource or 'all'
    if resource == GetCurrentResourceName() or resource == "all" then
        -- Convert numeric levels to their name equivalent
        if tonumber(level) then
            level = tonumber(level)
            level = LogLevels[level] and LogLevels[level].name or level
        end

        -- Validate the log level
        if not LevelLookup[level] then
            Log.error(("Invalid log level: %s"):format(level))
            return
        end

        -- Update the log level and report the change
        local previousLevel = Log.level
        Log.level = level
        print(("%s -> %s"):format(previousLevel, Log.level))
    end
end)

-- Handler to get current log level
AddEventHandler("da_log:getLevel", function(resource)
    if resource == GetCurrentResourceName() or resource == "all" then
        print(Log.level)
    end
end)

-----------------------------------------------------------
-- Command Registration (only when running as main resource)
-----------------------------------------------------------

if GetCurrentResourceName() == "da_log" then
    Log.debug("Registering log commands")

    -- Register the 'log' command
    RegisterCommand("log", function(source, args, rawCommand)
        -- Set log level: log set <resource> <level>
        if args[1] == "set" then
            TriggerEvent("da_log:setLevel", args[2], args[3])
        end

        -- Get log level: log get <resource>
        if args[1] == "get" then
            TriggerEvent("da_log:getLevel", args[2])
        end

        -- List available log levels: log list
        if args[1] == "list" then
            for i, v in ipairs(LogLevels) do
                print(("%s: %s"):format(i, v.name))
            end
        end
    end, false)
end
