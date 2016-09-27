local require = require 'nsrq' ()

local parse = require '../parse'
local passes = require '../passes'
local reify = require '../reify'
local args = require '../args'

local file_arg = {}
local passes_arg = {}

args.parse({...}, args.merge(
	args.one(file_arg),
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

io.write(reify(instrs, labels))
