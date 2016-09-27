local require = require 'nsrq' ()

local parse = require '../parse'
local passes = require '../passes'
local interp = require '../interp'
local args = require '../args'

local regs = {}

local file_arg = {}
local passes_arg = {}
local regs_arg
do
	local cur_reg = 1
	regs_arg = args.bind(tonumber, setmetatable({ live = true }, { __call = function(self, arg)
		return function()
			regs[cur_reg] = arg
			cur_reg = cur_reg + 1
		end
	end }))
end

args.parse({...}, args.merge(
	args.seq(
		args.one(file_arg),
		args.merge(
			regs_arg,
			args.pattern('^(%d+)=(%d+)$', setmetatable({ live = true }, { __call = function(self, arg)
				return function()
					regs[tonumber(arg[1])] = tonumber(arg[2])
				end
			end }))
		)
	),
	args.pattern('^%-p(.+)$', args.map(function(arg)
		local name, parg = arg[1]:match '^([^%(]+)(%b())$'
		if name then
			parg = parg:sub(2, -2)
		else
			name = arg[1]
		end
		
		if passes[name] then
			return {passes[name], parg}
		else
			error(('unknown pass: %q'):format(name))
		end
	end, args.collect(passes_arg)))
))

if not file_arg.set then
	error('no file specified')
end

local instrs, labels
do
	local h = io.open(file_arg.v, 'r')
	if not h then error(('No file: %q'):format(file_arg.v), 0) end
	local contents = h:read '*a'
	h:close()
	instrs, labels = parse(contents)
end

for _, pass in ipairs(passes_arg) do
	instrs, labels = pass[1](pass[2], instrs, labels)
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
