-- #region Classes & Tables
---@class task
---@field label string
---@field completed boolean

---@type table<task>
local tasksTable = {}

local commandsList = {
	---@param label string
    add = function(label)
    	local task = {label = label, completed = false}
        table.insert(tasksTable, task)
        io.write("Task Added: " .. label)
    end,

    list = function()
        local titleString = string.format("%-4s %-35s %-12s", "id", "Task Title", "Status")
        io.write(titleString.."\n")
        if next(tasksTable) == nil then
            local emptyTable = string.format("%-4s %-35s %-12s", "--", "No Tasks", "--")
            io.write(emptyTable.."\n")
        end
        for i = 1, #tasksTable do
            local label = tasksTable[i].label
            local status = tasksTable[i].completed == true and "Done" or "To Do"
            local formattedString = string.format("%-4s %-35s %-12s", i, label, status)
            io.write(formattedString.."\n")
        end
    end,

    ---@param number number
    delete = function(number)
    	io.write("Task Deleted: " .. tasksTable[number].label)
    	table.remove(tasksTable, number)
    end,

    ---@param number number
    check = function(number)
        if tasksTable[number].completed == true then
            io.write('Task already completed: ' .. tasksTable[number].label)
            return
        end
        io.write("Task Marked Done: " .. tasksTable[number].label)
        tasksTable[number].completed = true
    end,

    ---@param number number
    uncheck = function(number)
        if tasksTable[number].completed == false then
            io.write('Task already in progress: ' .. tasksTable[number].label)
            return
        end
        io.write("Task Marked Inprogress: " .. tasksTable[number].label)
        tasksTable[number].completed = false
    end,
}

local fileFunctions = {
    location = string.match(arg[0] or "", "(.*[/\\])") or "",
	saveTasks = function(self)
	    local saveFile = assert(io.open(self.location .. "tasksList.sav", "w"))
        for i = 1, #tasksTable do
            saveFile:write(tostring(tasksTable[i].completed) .. " " .. tostring(tasksTable[i].label .. "\n"))
        end
        io.close(saveFile)
    end,
    loadTasks = function(self)
        local loadFile = tostring(self.location .. "tasksList.sav")
        local file = io.open(loadFile, "r")
        if file == nil then return end
        local taskList = {}
        for l in file:lines() do
        	---@type task
            local task = {
             	completed = string.lower(string.match(l, "%S+")) == "true" and true or false,
            	label = string.match(l, "%S+ (.*)"),
            }
            table.insert(taskList, task)
        end
        tasksTable = taskList
        io.close(file)
    end
}

local errorHandling = {
    ---@param number number
	---@return number
    isOutOfRange = function(number)
        if tasksTable[number] == nil then
            io.write("Number out of the range of todo list")
            os.exit()
        end
        return number
    end,

    ---@param argument string
    ---@return number
    isArgumentANumber = function(argument)
    	local number = tonumber(argument)
        if type(number) ~= "number" then
            io.write("This command expected a number got none.")
            os.exit()
        end
        return number
    end,

    noCommand = function()
        io.write("The app expected a command got none.\nType help for all commands")
        os.exit()
    end,

    unrecognisedCommand = function()
        io.write("Unrecognised command.\nType help for all commands")
        os.exit()
    end,
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
    local command = (arg[1]) or ""
    command = string.lower(command)
    return { command, labelToString }
end

---@param command string
---@param argument string
local function executeCommand(command, argument)
    if command == "" then
        errorHandling.noCommand()
    end

    if command == "add" then
        if argument == nil or argument == "" then
            io.write("Name Your Task:\n")
            argument = io.read()
        end

        commandsList.add(argument)
        fileFunctions.saveTasks(fileFunctions)
        return
    end

    if command == "delete" then
        local number = errorHandling.isArgumentANumber(argument)
        number = errorHandling.isOutOfRange(number)

        commandsList.delete(number)
        fileFunctions.saveTasks(fileFunctions)
        return
    end

    if command == "check" then
        local number = errorHandling.isArgumentANumber(argument)
        number = errorHandling.isOutOfRange(number)

        commandsList.check(number)
        fileFunctions.saveTasks(fileFunctions)
        return
    end

    if command == "uncheck" then
    	local number = errorHandling.isArgumentANumber(argument)
        number = errorHandling.isOutOfRange(number)

        commandsList.uncheck(number)
        fileFunctions.saveTasks(fileFunctions)
        return
    end

    if command == "list" then
        commandsList.list()
        return
    end
    errorHandling.unrecognisedCommand()
end
-- #endregion

local function main()
	fileFunctions.loadTasks(fileFunctions)
    local command = parseCommand()
    executeCommand(command[1],command[2])
end

main()
