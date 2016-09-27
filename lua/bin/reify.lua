local require = require 'nsrq' ()

local parse = require '../parse'
local passes = require '../passes'
local reify = require '../reify'

local args = {...}

local instrs, labels
do
	local h = io.open(args[1], 'r')
	local contents = h:read '*a'
	h:close()
	instrs, labels = parse(contents)
end

for _, arg in ipairs({table.unpack(args, 2)}) do
	repeat
		local pass = arg:match '^%-p(.+)$'
		if pass then
			local name, parg

			local name_, parg_ = pass:match '^([^%(]+)(%b())$'
			if name_ then
				name = name_
				parg = parg_:sub(2, -2)
			else
				name = pass
				parg = nil
			end
			
			if passes[name] then
				instrs, labels = passes[name](parg, instrs, labels)
			else
				error(('unknown pass: %q'):format(name))
			end
			break
		end

		error(('unhandled arg: %q'):format(arg))
	until true
end

io.write(reify(instrs, labels))
