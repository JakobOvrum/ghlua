ghlua
=========================================
ghlua is a Lua library for using the GitHub API.

Documentation coming soon.

Roadmap
=========================================
ghlua currently supports the following API categories:

 * [Repository API](http://develop.github.com/p/repo.html)
 * [Commit API](http://develop.github.com/p/commits.html)
 * [Object API](http://develop.github.com/p/object.html)
 * [Network API](http://develop.github.com/p/network.html)
 * [User API](http://develop.github.com/p/users.html)

Commands that require you to authenticate are not yet supported.

Dependencies
-----------------------------------------
ghlua requires the following:

 * [Lua 5.1](http://www.lua.org/)
 * [LuaSocket](http://w3.impa.br/~diego/software/luasocket/)
 * A json library with a `decode` function (like [luajson](http://luaforge.net/projects/luajson/))
