local setmetatable = setmetatable
local table = table
local error = error
local require = require
local assert = assert

module "ghlua"

require "ghlua.util"

_REPO = {}
local repo = _REPO

require "ghlua.commit"
require "ghlua.network"

function repository(username, repository)
	return setmetatable({
		user = assert(username);
		repo = assert(repository);
	}, {__index = repo})
end

function repo:getOwner()
	return self.user
end

function repo:getName()
	return self.repo
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

function repo:getCollaborators()
	return self:action("show", "collaborators").collaborators
end

function repo:getContributors(showAnon)
	return self:action("show", "contributors", showAnon and "anon" or "").contributors
end

function repo:getWatchers(showFull)
	local args
	if showFull then
		args = {full = 1}
	end
	return get(("repos/show/%s/%s/watchers"):format(self.user, self.repo), args).watchers
end

-- also returns the main repo as the first result
function repo:getForks()
	return self:action("show", "network").network
end

function repo:getLanguages()
	return self:action("show", "languages").languages
end

function repo:getNetwork()
	return network(self.user, self.repo)
end
