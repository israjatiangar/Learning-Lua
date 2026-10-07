--- @type table<task>
local tasksTable = {}

--- @class task
--- @field label string
--- @field completed boolean

local function parseCommand()
    local label = {}
    for i = 2, #arg do
        table.insert(label, arg[i])
    end
    local labelToString = table.concat(label, " ")
    local command = string.upper(tostring(arg[1]))
    return { command, labelToString }
end

local function main()
    local command = parseCommand()
    print("command = " .. command[1] .. "\targuments = " .. command[2])
end

main()
