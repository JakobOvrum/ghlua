local require = require
local setmetatable = setmetatable
local assert = assert

module "ghlua"

require "ghlua.util"

_USER = {}
local usr = _USER

function user(username)
	return setmetatable({
		name = assert(username);
	}, {__index = usr})
end

function usr:action(_action, ...)
	return action("user", _action, self.name, ...)
end

function usr:getInfo()
	return self:action("show").user
end

function usr:getFollowing()
	return self:action("show", "following").users
end

function usr:getFollowers()
	return self:action("show", "followers").users
end

function usr:getWatching()
	return action("repos", "watched", self.name).repositories
end

function usr:getRepositories()
	return action("repos", "show", self.name).repositories
end
