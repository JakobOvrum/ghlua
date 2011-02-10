local setmetatable = setmetatable
local table = table
local error = error
local require = require
local assert = assert

--- GitHub API
module "ghlua"

require "ghlua.util"

_REPO = {}
local repo = _REPO

require "ghlua.commit"

function repository(username, repository)
	return setmetatable({
		user = assert(username);
		repo = assert(repository);
	}, {__index = repo})
end


function repo:action(_action, ...)
	return action("repos", _action, self.user, self.repo, ...)
end

function repo:getInfo()
	return self:action("show").repository
end

--- Get a list of branches for the current repository.
-- @returns table with branch name keys and commit ref values.
function repo:getBranches()
	return self:action("show", "branches").branches
end

--- Get a list of tags for the current repository.
-- @returns table with tag name keys and commit ref values.
function repo:getTags()
	return self:action("show", "tags").tags
end
