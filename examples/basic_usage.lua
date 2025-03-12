--[[
  da_log Basic Usage Example

  This example demonstrates the key features of da_log, including:
  - Using different log levels
  - Logging various data types
  - Changing log levels at runtime
  - Using utility functions (line & format)
]]

-- Import da_log in your fxmanifest.lua:
-- shared_scripts {
--   '@da_log/log_sh.lua',
-- }

-- Basic usage of log levels
log.error("This is an error message")
log.warn("This is a warning message")
log.info("This is an info message")
log.verbose("This is a verbose message")
log.debug("This is a debug message")
log.spam("This is a spam message")

-- Logging multiple values
log.info("Player", 42, "connected from", "127.0.0.1")

-- Logging tables with nested data
local playerData = {
  id = 42,
  name = "John",
  position = vector3(100.5, 200.3, 30.0),
  inventory = {
    weapons = {"WEAPON_REVOLVER", "WEAPON_RIFLE"},
    items = {
      food = 5,
      medicine = 3
    }
  }
}
log.debug("Player data:", playerData)

-- Logging vectors
local position = vector3(123.45, 678.90, 25.0)
log.info("Current position:", position)

-- Using log.line() to track code execution
function ComplexFunction()
  -- Some code here
  log.verbose("Executing at " .. log.line())
  -- More code here
end
ComplexFunction()

-- Using log.format() to convert complex data to string
local entityData = {
  type = "horse",
  model = "A_C_Horse_Arabian_White",
  position = vector3(500.0, 600.0, 50.0)
}
local dataString = log.format(entityData)
print("Formatted entity data: " .. dataString)

-- Changing log level at runtime
log.level = "warn"  -- Only warnings and errors will show
log.error("This error will be visible")
log.warn("This warning will be visible")
log.info("This info message will be hidden")

-- Using numeric log levels
log.level = 3  -- Set to info level
log.info("This info message is now visible again")

-- Demonstrate filtering for specific debugging
function DebugSpecificFeature()
  local previousLevel = log.level
  log.level = "debug"  -- Temporarily increase verbosity

  log.debug("Feature debugging - Step 1")
  -- Code for step 1

  log.debug("Feature debugging - Step 2")
  -- Code for step 2

  log.level = previousLevel  -- Restore previous log level
end
DebugSpecificFeature()

-- Example of clean error reporting with contextual data
function ProcessTransaction(txData)
  if not txData.amount then
    log.error("Transaction failed: Missing amount", txData, log.line())
    return false
  end

  -- Process the transaction...
  log.info("Transaction processed", txData.id, "Amount:", txData.amount)
  return true
end

ProcessTransaction({id = "TX123"})  -- Will fail
ProcessTransaction({id = "TX124", amount = 500.0})  -- Will succeed
