local require = require 'nsrq' ()

local parse = require '../parse'
local passes = require '../passes'
local interp = require '../interp'
local args = require '../args'

local args = {...}

local instrs, labels
do
	local h = io.open(args[1], 'r')
	local contents = h:read '*a'
	h:close()
	instrs, labels = parse(contents)
end

local regs = {}

local cur_reg = 1
for _, arg in ipairs({table.unpack(args, 2)}) do
	repeat
		local v = arg:match '^(%d+)$'
		if v then
			regs[cur_reg] = tonumber(v)
			cur_reg = cur_reg + 1
			break
		end

		local reg, v = arg:match '^(%d+)=(%d+)$'
		if reg then
			regs[tonumber(reg)] = tonumber(v)
			break
		end

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

local regs, ip, count = interp(instrs, regs)

print(('count=%d'):format(count))

local max_reg = -1
for reg in pairs(regs) do
	max_reg = math.max(max_reg, reg)
end

for reg = 0, max_reg do
	print(('%d=%d'):format(reg, tostring(regs[reg])))
end
