local table = table
local error = error
local pairs = pairs
local type = type
local setmetatable = setmetatable
local tonumber = tonumber
local request = require("socket.http").request
local decode = require("json").decode
local getinfo = require("debug").getinfo

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

_APIURL = "http://github.com/api/v2/json/"

function apiUrl(command, args)
	if args then
		return table.concat{_APIURL, command, "?", postArgs(args)}
	else
		return  _APIURL .. command
	end
end

function tryget(command, args)
	local url = apiUrl(command, args)
	
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

function checkArg(argn, expectedType, arg)
    local t = type(arg)
    if t ~= expectedType then
        local name = getinfo(2, "n").name
        error(("bad argument #%d to %s (%s expected, got %s)"):format(argn, name, expectedType, t), 3)
    end

    return arg
end

function readonly(t)
	return setmetatable({}, {__index = t, __newindex = function() error("table is readonly", 2) end})
end

-- Matches three different kinds of github time formats
function time(s)
	local year, month, day = s:match("(%d+)%-(%d+)%-(%d+)")
	local hour, minute, second = s:match("(%d+):(%d+):(%d+)")
	local timezone = s:match("%-(%d+):%d+$")
	return {
		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);

		hour = tonumber(hour);
		minute = tonumber(minute);
		second = tonumber(second);
		
		timezone = tonumber(timezone);
	}
end
