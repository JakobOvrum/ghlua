local table = table
local error = error
local pairs = pairs
local type = type
local request = require("socket.http").request
local decode = require("json").decode

local print = print

module "ghlua"

local function postArgs(t)
	local buffer = {}
	for key, value in pairs(t) do
		if type(key) == "number" then
			table.insert(buffer, value)
		else
			table.insert(buffer, table.concat{key, "=", value})
		end
	end
	return table.concat(buffer, "&")
end

local function apiUrl(command)
	return "http://github.com/api/v2/json/" .. command
end

local function apiUrlArgs(command, args)
	return table.concat{"http://github.com/api/v2/json/", command, "?", postArgs(args)}
end


function tryget(command, args)
	local url	
	if args then
		url = apiUrlArgs(command, args)
	else
		url = apiUrl(command)
	end
	
	print(url)
	local body, status, headers, statusline = request(url)
	
	if not body or status ~= 200 then
		return nil, statusline, url
	end

	return decode(body)
end

--- Issue a GET request to GitHub.
-- @param command command to request
-- @param args URL parameters [optional]
-- @error errors if the request failed due to an invalid command or lack of access.
-- @returns table with results. The table layout depends on the command.
function get(command, args, errorlevel)
	local result, errormsg, url = tryget(command, args)
	if not result then
		error(("failed github request: %s (%s)"):format(url, errormsg), errorlevel or 2)
	end
	return result
end

function action(...)
	return get(table.concat({...}, "/"))
end
