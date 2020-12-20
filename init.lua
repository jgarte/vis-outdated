local M = {}
local HOME = os.getenv('HOME')
local XDG_CACHE_HOME = os.getenv('XDG_CACHE_HOME')
local BASE = XDG_CACHE_HOME or HOME

M.path = BASE .. '/.vis-outdated'

-- configure in visrc
M.repos = {}

local read_hashes = function()
	local f = io.open(M.path)
	if f == nil then return {} end
	local t= {}
	for line in f:lines() do
		for k, v in string.gmatch(line, '(.+)%s(%w+)') do
			t[k] = v
		end
	end
	f:close()
	return t
end

local write_hashes = function(hashes)
	local f = io.open(M.path, 'w+')
	if f == nil then return end
	local t = {}
	for repo, hash in pairs(hashes) do
		table.insert(t, repo .. ' ' .. hash)
	end
	local s = table.concat(t, '\n')
	f:write(s)
	f:close()
end

local execute = function(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

local fetch_hashes = function(repos)
	local latest = {}
	for i, repo in ipairs(repos) do
		local command = 'git ls-remote ' .. repo .. ' HEAD | cut -f1'
		local result = execute(command)
		local hash = string.gsub(result, '%s+', '')
		latest[repo] = hash
	end
	return latest
end

local get_hash_status = function(current, latest)
	if current == nil then
		return 'not there'
	end

	if current == latest then
		return 'latest'
	end

	if current ~= latest then
		return 'outdated'
	end
end

-- compare current with latest
local calc_diff = function(current, latest)
	local diff = {}
	for repo, hash in pairs(latest) do
		local current_hash = current[repo]
		local status = get_hash_status(current_hash, hash)
		diff[repo] = { hash= hash, status= status }
	end
	return diff
end

local print_hashes = function(hashes)
	local t = {}
	for repo, hash in pairs(hashes) do
		table.insert(t, repo .. ' ' .. hash)
	end
	local s = table.concat(t, '\n')
	vis:message(s)
end


local print_diff = function(diff)
	local t = {}
	for repo, diff in pairs(diff) do
		table.insert(t, repo .. ' - ' .. diff.status) --.. diff.hash .. ')')
	end
	local s = table.concat(t, '\n')
	vis:message(s)
end

local getFileName = function(url)
  return url:match("^.+/(.+)$")
end

-- TODO colorize results of cache list e.g. red if old, green if latest
vis:command_register('out-ls', function()
	local current = read_hashes()
	vis:message('on disk')
	print_hashes(current)
	local latest = fetch_hashes(M.repos)
	vis:message('latest')
	print_hashes(latest)
	return true
end)

vis:command_register('out-df', function()
	local current = read_hashes()
	local latest = fetch_hashes(M.repos)
	local diff = calc_diff(current, latest)
	vis:message('diff')
	print_diff(diff)
	return true
end)

vis:command_register('out-up', function()
	local latest = fetch_hashes(M.repos)
	write_hashes(latest)
	vis:message('updated')
	print_hashes(latest)
	return true
end)

-- git clone (shallow) repos to the vis-plugins folder
vis:command_register('out-in', function()
	local visrc, err = package.searchpath('visrc', package.path)
	assert(not err)
	local vis_path = visrc:match('(.*/)')
	assert(vis_path)
	local path = vis_path ..'plugins'
	vis:message('installing to ' .. path)
	for i, url in ipairs(M.repos) do
		local name = getFileName(url)
		local full_path = path .. '/' .. name
		execute('git -C ' .. path .. ' clone --depth 1 --branch=master ' .. url .. ' --quiet 2> /dev/null')
		vis:message('git cloned (shallow) ' .. url .. ' to ' .. name)
	end
	return true
end)

return M
