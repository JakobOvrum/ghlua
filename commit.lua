module "ghlua"

local repo = _REPO

function repo:commitaction(_action, ...)
	return action("commits", _action, self.user, self.repo, ...)
end

function repo:getCommits(branch)
	return self:commitaction("list", branch).commits
end

-- use forward slashes!
function repo:getFileHistory(branch, path)
	return self:commitaction("list", branch, path).commits
end

function repo:getCommit(sha)
	return self:commitaction("show", sha).commit
end

local function pageIterator(command)
	local args = {page = 1}
	local commits = get(command, args).commits
	args.page = 2
	local i = 1
	return function()
		local commit = commits[i]
		if commit then
			i = i + 1
		else
			local result = tryget(command, args)
			if result then
				args.page = args.page + 1
				commits = result.commits
				commit = commits[1]
				i = 1
			end
		end
		return commit
	end	
end

function repo:commits(branch)
	return pageIterator(("commits/list/%s/%s/%s"):format(self.user, self.repo, branch))
end

function repo:fileHistory(branch, path)
	return pageIterator(("commits/list/%s/%s/%s/%s"):format(self.user, self.repo, branch, path))
end
