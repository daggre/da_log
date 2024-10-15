assert(log == nil, "Global namespace collision 'log' is previously defined: Aborting @da_log resource setup")

local function _formatValue(val, indent)
    indent = indent or 0
    local t = type(val)
    if t == "nil" then return "nil"
    elseif t == "string" and indent == 0 then return val
    elseif t == "string" then return '"' .. val .. '"'
    elseif t == "number" then return tostring(val)
    elseif t == "boolean" then return tostring(val)
    elseif t == "function" then return tostring(val)
    elseif t == "userdata" then return "userdata: " .. tostring(val)
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
    elseif t == "vector2" then
        return ("vec2(%.3f, %.3f)"):format(val.x, val.y)
    elseif t == "vector3" then
        return ("vec3(%.3f, %.3f, %.3f)"):format(val.x, val.y, val.z)
    elseif t == "vector4" then
        return ("vec4(%.3f, %.3f, %.3f, %.3f)"):format(val.x, val.y, val.z, val.w)
    else
        return "unknown type"
    end
end

local function _formatValues(...)
    local args = {...}
    local fStrings = {}
    for _, val in ipairs(args) do
        table.insert(fStrings, _formatValue(val))
    end
    return table.concat(fStrings, "\t")
end

local LogLevels = {
    { name = "error", prefixColor = 8, prefix = "ERROR: ", color = 8, },
    { name = "warn", prefixColor = 3, prefix = "WARN: " },
    { name = "info" },
    { name = "verbose" },
    { name = "debug", color = 3, },
    { name = "spam", prefixColor = 5, prefix = "+ ", color = 3, },
}

local LevelLookup = {}
for i, v in ipairs(LogLevels) do
    LevelLookup[v.name] = i
    LevelLookup[i] = i
end

local Log = setmetatable(
    {
        level = GetConvarInt("debug", 0) == 1 and "debug" or "info",
        line = function(f)
            f = f or 1
            local nfo = debug.getinfo(f+1, "Sl")
            return nfo.short_src .. ":" .. nfo.currentline
        end,
        format = _formatValues
    }, {
        __index = function(self, logType)
            return setmetatable({}, {
                __call = function(_, ...)
                    local logLevel = LevelLookup[self.level]
                    local levelNumber = LevelLookup[logType]

                if levelNumber and levelNumber > logLevel then
                    return
                end

                local logData = LogLevels[levelNumber]
                if not logData then print(("^1ERROR:^7 Invalid log type (%s)"):format(logType))
                    return
                end

                print(
                    (logData.prefixColor and "^"..logData.prefixColor or "") ..
                    (logData.prefix or "") ..
                    (not logData.color and logData.prefixColor and "^7" or "") ..
                    (logData.color and "^"..logData.color or "") ..
                    _formatValues(...) ..
                    (logData.color and "^7" or "")
                )
            end
        })
    end
})

_ENV.log = Log

AddEventHandler("da_log:setLevel", function(resource, level)
    if resource == GetCurrentResourceName() or resource == "all" then
        if tonumber(level) then
            level = tonumber(level)
            level = LogLevels[level] and LogLevels[level].name or level
        end
        if not LevelLookup[level] then
            Log.error(("Invalid log level: %s"):format(level))
            return
        end
        local previousLevel = Log.level
        Log.level = level
        print(("%s -> %s"):format(previousLevel, Log.level))
    end
end)

AddEventHandler("da_log:getLevel", function(resource)
    if resource == GetCurrentResourceName() or resource == "all" then
        print(Log.level)
    end
end)

if GetCurrentResourceName() == "da_log" then
    Log.debug("Registering log commands")
    RegisterCommand("log", function(source, args, rawCommand)
        if args[1] == "set" then
            TriggerEvent("da_log:setLevel", args[2], args[3])
        end
        if args[1] == "get" then
            TriggerEvent("da_log:getLevel", args[2])
        end
        if args[1] == "list" then
            for i, v in ipairs(LogLevels) do
                print(("%s: %s"):format(i, v.name))
            end
        end
    end, false)
end

