local table = table
local error = error
local require = require
local assert = assert
local print = print

--- GitHub API
module "ghlua"

require "ghlua.util"
require "ghlua.repository"
local request = require("socket.http").request
local decode = require("json").decode

local repo = _REPO

function repo:getTree(sha)
	return action("tree", "show", self.user, self.repo, sha).tree
end

function repo:getBlob(tree, path, excludeData)
	checkArg(2, "string", path)

	local args
	if excludeData then
		args = {meta = 1}
	end
	return get(table.concat({"blob/show", self.user, self.repo, tree, path}, "/"), args).blob
end

-- !!! does not give anything like an error for blobs that weren't found !!!
function repo:getBlobData(blob)
	local url = apiUrl(table.concat({"blob/show", self.user, self.repo, blob}, "/"))
	print(url)

	local body, status, headers, statusline = request(url)
	
	if not body then
		error(("blob get failed: %s (%s)"):format(url, statusline), 2)
	elseif status ~= 200 then
		error(decode(body).error, 2)
	end

	return body
end

