-- #region Classes & Tables
---@class task
---@field label string
---@field completed boolean

---@type table<task>
local tasksTable = {}

local commandsList = {
	---@param label string
    add = function(label)
    	local task = {label, false}
        table.insert(tasksTable, task)
    end,

    list = function()
    	local titleString = string.format("%-4s %-35s %-12s","id","Task Title","Status")
        print(titleString)
        if next(tasksTable) == nil then
            local emptyTable = string.format("%-4s %-35s %-12s", "--", "No Tasks", "--")
            print(emptyTable)
        end
        for i = 1, #tasksTable do
            local label = tasksTable[i].label
            local status = tasksTable[i].completed and "Done" or "To Do"
            local  formattedString = string.format("%-4s %-35s %-12s",i,label,status)
            print(formattedString)
        end
    end
}
-- #endregion

-- #region Helper Functions
---@return table<string>
local function parseCommand()
    local label = {}
    for i = 2, #arg do
        table.insert(label, arg[i])
    end
    local labelToString = table.concat(label, " ")
    local command = string.lower(tostring(arg[1]))
    return { command, labelToString }
end

---@param command string
---@param argument string
local function executeCommand(command, argument)
    if command == nil then
        io.write("Expected Command Got None")
        return
    end

    if command == "add" then
        if argument == nil or argument == "" then
            io.write("Expected a Task")
            return
        else
            commandsList.add(argument)
            io.write("Task Added: " .. argument)
            return
        end
    end

    if command == "list" then
        commandsList.list()
        return
    end

    io.write("Unrecognised Command.\nTry : add or list")
end
-- #endregion

local function main()
    local command = parseCommand()
    executeCommand(command[1],command[2])
end

main()
