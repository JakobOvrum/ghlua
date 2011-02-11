local setmetatable = setmetatable
local assert = assert
local require = require
local error = error
local table = table

module "ghlua"

require "ghlua.util"

local request = require("socket.http").request
local decode = require("json").decode

_NETWORK = {}
local net = _NETWORK

local function baseUrl(user, repo)
	return ("http://github.com/%s/%s/"):format(user, repo)
end

local function reqUrl(base, nethash)
	return table.concat{base, "network_data_chunk?nethash=", nethash, "&start=%d&end=%d"}
end

local function get(url)
	local body, status, headers, statusline = request(url)
	if not body or status ~= 200 then
		error(("network request failed: %s (%s)"):format(url, statusline), 2)
	end
	
	local result = decode(body)
	return result
end

function network(username, repository)
	local url = baseUrl(assert(username), assert(repository))
	local o = setmetatable({
		user = username;
		repo = repository;
		nextCommit = 1;
		baseUrl = url;
		updateUrl = url .. "network_meta";
	}, {__index = net})
	
	o:update()

	return o
end

function net:update()
	self.meta = get(self.updateUrl)
	self.requestUrl = reqUrl(self.baseUrl, self.meta.nethash)
end

function net:getOwner()
	return self.user
end

function net:getName()
	return self.repo
end

function net:getInfo()
	if self.meta then
		return readonly(self.meta)
	end
end

function net:getRange(start, stop)
	local url = self.requestUrl:format(start, stop)
	return get(url).commits
end

function net:getChunk(n)
	return self:getRange(n, n)[1]
end

-- !!
function net:changes()
	if self.nextCommit >= #self.meta.dates then
		return function() end
	end

	local function eat()
		local stop = self.nextCommit + 99
		local range = self:getRange(self.nextCommit, stop)
		self.nextCommit = self.nextCommit + #range
		return range, #range == 100 and self.nextCommit < #self.meta.dates
	end

	local commits, more = eat()
	local i = 1
	return function()
		local commit = commits[i]
		if not commit and more then
			commits, more = eat()
			commit = commits[1]
			i = 2
		end
		i = i + 1
		return commit
	end
end
