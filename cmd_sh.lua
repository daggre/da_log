-----------------------------------------------------------
-- Command Registration (only when running as main resource)
-----------------------------------------------------------

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
