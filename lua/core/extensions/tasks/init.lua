--[[
PLAN

- have a slqite.go adapter that manages the connection
- slqite.go adapter will connect, read, then output results in json
- connection might me kinda slow... unsure how I can best speed that up... can fix later
- will background all interactions with the adapter, keeping changes in memory
- adapter will accept a cmd string to execute against sqlite
- map results to a map / any and print out as json

]]
--
local M = {}
return M
