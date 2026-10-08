-- #region Classes & Tables
---@class task
---@field label string
---@field completed boolean

---@type string
local filePath = arg[0] or ""

---@type table<task>
local tasksTable = {}

local function stringToBoolean(booleanString)
	return string.lower(booleanString) == "true" and true or false
end

local commandsList = {
	---@param label string
    add = function(label)
    	local task = {label = label, completed = false}
        table.insert(tasksTable, task)
        io.write("Task Added: " .. label)
    end,

    list = function()
        local titleString = string.format("%-4s %-35s %-12s", "id", "Task Title", "Status")
        print(titleString)
        if next(tasksTable) == nil then
            local emptyTable = string.format("%-4s %-35s %-12s", "--", "No Tasks", "--")
            print(emptyTable)
        end
        for i = 1, #tasksTable do
            local label = tasksTable[i].label
            local status = tasksTable[i].completed == true and "Done" or "To Do"
            local formattedString = string.format("%-4s %-35s %-12s", i, label, status)
            print(formattedString)
        end
    end,

    ---@param number number
    delete = function(number)
    	io.write("Task Deleted: " .. tasksTable[number].label)
    	table.remove(tasksTable, number)
    end,
}

local fileFunctions = {
	location = string.match(filePath, "(.*[/\\])") or "",
	saveTasks = function(self)
	    local saveFile = assert(io.open(self.location .. "tasksList.sav", "w"))
	    for i = 1, #tasksTable do
	        saveFile:write(tostring(tasksTable[i].completed) .. " " .. tostring(tasksTable[i].label .. "\n"))
	    end
    end,
    loadTasks = function(self)
        local loadFile = tostring(self.location .. "tasksList.sav")
        local file = io.open(loadFile, "r")
        if file == nil then return end
        local taskList = {}
        for l in io.lines(loadFile, "l") do
        	---@type task
            local task = {
             	completed = stringToBoolean(string.match(l, "%S+")),
            	label = string.match(l, "%S+ (.*)"),
            }
            table.insert(taskList, task)
        end
        tasksTable = taskList
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
            fileFunctions:saveTasks()
            return
        end
    end

    if command == "delete" then
    	local number = tonumber(argument)
    	if number == nil then return end
        commandsList.delete(number)
        fileFunctions:saveTasks()
        return
    end

    if command == "list" then
        commandsList.list()
        return
    end

    io.write("Unrecognised Command.\nTry : add or list")
end
-- #endregion

local function main()
	fileFunctions:loadTasks()
    local command = parseCommand()
    executeCommand(command[1],command[2])
end

main()
