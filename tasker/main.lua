-- #region Classes & Tables

---@class task
---@field label string
---@field completed boolean

---@type table[task]
local tasksTable = {}
-- #endregion

-- #region Main Functions

local errorHandling = {
	---@param number number
	---@return number
	isOutOfRange = function(number)
		if tasksTable[number] == nil then
			io.write("Number out of the range of todo list.\nPlease Provide a number between 0 and " .. #tasksTable)
			os.exit(1)
		end
		return number
	end,

	---@param argument string
	---@return number | void
	isArgumentANumber = function(argument)
		local number = tonumber(argument)
		if type(number) ~= "number" then
			io.write("This command expected a number got none.")
			os.exit(1)
		end
		return number
	end,

	noCommand = function()
		io.write("The app expected a command got none.\nType help for all commands")
		os.exit(1)
	end,

	unrecognisedCommand = function()
		io.write("Unrecognised command.\nType help for all commands")
		os.exit(1)
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
		for line in file:lines() do
			---@type task
			local task = {
				completed = string.lower(string.match(line, "%S+")) == "true" and true or false
				label = string.match(line, "%S+ (.*)"),
			}
			table.insert(taskList, task)
		end
		tasksTable = taskList
		io.close(file)
	end
}

local commandsList = {
	---@param label string
	add = function(label)
		if label == nil or label == "" then
			io.write("Name Your Task:\n")
			label = io.read()
		end
		local task = { label = label, completed = false }
		table.insert(tasksTable, task)
		io.write("Task Added: " .. label)
		fileFunctions.saveTasks(fileFunctions)
	end,

	list = function()
		local stringFormat = "%-4s %-12s %-35s\n"
		for i = 1, 20, 1 do
			io.write("=")
			if i == 10 then
				io.write(" Todo List ")
			end
		end
		io.write("\n")
		local titleString = string.format(stringFormat, "id", "Status", "Task Title")
		io.write(titleString .. "\n")
		if next(tasksTable) == nil then
			local emptyTable = string.format(stringFormat, "--", "--", "No Tasks")
			io.write(emptyTable .. "\n")
		end
		for i = 1, #tasksTable do
			local label = tasksTable[i].label
			local status = tasksTable[i].completed == true and "Done" or "To Do"
			local formattedString = string.format(stringFormat, i, status, label)
			io.write(formattedString .. "\n")
		end
	end,

	---@param argument string
	delete = function(argument)
		local number = errorHandling.isArgumentANumber(argument)
		number = errorHandling.isOutOfRange(number)

		io.write("Task Deleted: " .. tasksTable[number].label)
		table.remove(tasksTable, number)
		fileFunctions.saveTasks(fileFunctions)
	end,

	---@param argument string
	check = function(argument)
		local number = errorHandling.isArgumentANumber(argument)
		number = errorHandling.isOutOfRange(number)

		if tasksTable[number].completed == true then
			io.write('Task already completed: ' .. tasksTable[number].label)
			return
		end
		io.write("Task Marked Done: " .. tasksTable[number].label)
		tasksTable[number].completed = true
		fileFunctions.saveTasks(fileFunctions)
	end,

	---@param argument string
	uncheck = function(argument)
		local number = errorHandling.isArgumentANumber(argument)
		number = errorHandling.isOutOfRange(number)

		if tasksTable[number].completed == false then
			io.write('Task already in progress: ' .. tasksTable[number].label)
			return
		end
		io.write("Task Marked Inprogress: " .. tasksTable[number].label)
		tasksTable[number].completed = false
		fileFunctions.saveTasks(fileFunctions)
	end,

	help = function()
		local help = {
			{ "Add", {
				"Type Add to add an item to the todo list.",
				"Example: <add> <Name of Task>",
				"Don't panic if you forget. The app will give you another chance to add a task.",
			} },
			{ "Delete", {
				"Lets you delete an item from the todo list.",
				"Example: <delete> <Expects: id number of task>",
			} },
			{ "Check", {
				"Lets you change the status of a task to complete.",
				"Example: <check> <Expects: id number of task>",
			} },
			{ "Uncheck", {
				"Lets you change the status of a task to in progress.",
				"Example: <uncheck> <Expects: id number of task>",
			} },
			{ "List", {
				"Gives you a list of tasks with details such as ID, status, and task name.",
				"Example: <list> <ignores all arguments>",
			} },
			{ "Help", {
				"You are here. This command gives you a list of commands accepted by this CLI app.",
				"Example: <help> <ignores all arguments>",
			} },
			{ "Extra Info", {
				"1. All commands are case insensitive. Yes, you can type like this: deLEtE",
				"2. Delete, Check, and Uncheck expect the id shown by the list command.",
			} },
		}
		local stringFormat = "%-15s %-50s\n"
		for _, entry in ipairs(help) do
			local name = entry[1]
			local text = entry[2]
			local first = true
			io.write("\n")
			for i in ipairs(text) do
				io.write(string.format(stringFormat, first and name or "", text[i]))
				first = false
			end
		end
		io.write("\n")
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
	local command = (arg[1]) or ""
	command = string.lower(command)
	return { command, labelToString }
end

---@param command string
---@param argument string
local function executeCommand(command, argument)
	command = string.lower(command)
	if command == "" then
		errorHandling.noCommand()
	end
	if commandsList[command] == nil then
		errorHandling.unrecognisedCommand()
	end
	commandsList[command](argument)
end
-- #endregion

local function main()
	fileFunctions.loadTasks(fileFunctions)
	local command = parseCommand()
	executeCommand(command[1], command[2])
end

main()
