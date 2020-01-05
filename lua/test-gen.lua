local require = require 'nsrq' ()

local reify = require './reify'
local passes = require './passes'

local parts = {}
local labeled = {}
local regs = {}
local dests = {END = 'END';}

local function Reg()
	local i = #regs + 1
	
	local self = {
		type = 'Reg';
		i = i;
	}

	regs[i] = self

	return self
end

local function Part(...)
	local i = #parts + 1

	local label = ('part%d'):format(i)

	local self = {
		type = 'Part';
		dest = ':' .. label;
		label = label;
		i = i;
		instrs = {...};
		emit = true;
	}
	labeled[label] = self
	dests[self.dest] = self.dest
	parts[i] = self
	return self
end

local next_label_i = 1
local function Label(name)
	if not name then
		name = ('label%d'):format(next_label_i)
		next_label_i = next_label_i + 1
	end

	local self = {
		type = 'Label';
		label = name;
		name = name;
		dest = ':' .. name;
	}

	return self
end

local I = {}
function I._do(body)
	local r = function(c) return Part({'JMP', c.dest}) end

	body(function(i)
		local old_r = r
		r = function(c)
			return old_r(i(c))
		end
	end)

	return r
end
function I._if(cond, body_t, body_f)
	if not body_f then
		body_f = function(c) return c end
	end

	return function(c)
		return cond(body_t(c), body_f(c))
	end
end
function I._while(cond, body)
	return function(c)
		local lbl = Label()
		return I.label(lbl)(cond(body(I.jmp(lbl)()), c))
	end
end
function I.label(lbl)
	local lbl_

	if type(lbl) == 'table' and lbl.type == 'Label' then
		lbl_ = lbl.label
	else
		lbl_ = tostring(lbl)
	end

	return function(c)
		labeled[lbl_] = c
		dests[':' .. lbl_] = ':' .. lbl_
		return c
	end
end
function I.jmp(to)
	local to_
	if type(to) == 'string' or type(to) == 'number' then
		to_ = to
	elseif type(to) == 'table' and to.dest then
		to_ = to.dest
	else
		error('unknown dest: ' .. tostring(to))
	end

	return function(c)
		return Part({'JMP', to_})
	end
end
function I.stop()
	return function(c)
		return Part({'JMP', 'END'})
	end
end
function I.incr(reg)
	return function(c)
		return Part(
			{'INCR', reg.i},
			{'JMP', c.dest}
		)
	end
end
function I.decr(reg)
	return function(c)
		return Part(
			{'DECR', reg.i},
			{'JMP', c.dest}
		)
	end
end

local C = {}
function C.zero(reg)
	return function(tc, fc)
		return Part(
			{'JIZ', reg.i, tc.dest},
			{'JMP', fc.dest}
		)
	end
end
function C.not_zero(reg)
	return function(tc, fc)
		return Part(
			{'JIZ', reg.i, fc.dest},
			{'JMP', tc.dest}
		)
	end
end
function C.gt(l, r, c)
	return function(tc, fc)
		return Part(
			{'JIZ', r.i, tc.dest},
			{'JIZ', l.i, fc.dest},
			{'DECR', l.i},
			{'DECR', r.i},
			{'INCR', c.i},
			{'JMP', -6}
		)
	end
end

local K2 = Reg()
local K7 = Reg()
local K8 = Reg()
local start = I._do(function(e)
	e(I._if(C.zero(K8), I.stop()))
	e(I._while(C.not_zero(K2), I._do(function(e)
		e(I.decr(K2))
	end)))
	e(I._while(C.gt(K7, K8, K2), I._do(function(e)
		e(I._while(C.not_zero(K2), I._do(function(e)
			e(I.incr(K8))
			e(I.decr(K2))
		end)))
	end)))
	e(I._while(C.not_zero(K2), I._do(function(e)
		e(I.decr(K2))
		e(I.incr(K7))
		e(I.incr(K8))
	end)))
end)(I.stop()())

for _, part in ipairs(parts) do
	if part.instrs[1][1] == 'JMP' then
		local new_dest = dests[part.instrs[1][2]]
		if new_dest then
			part.emit = false
			for dst, dest_ in pairs(dests) do
				if dest_ == part.dest then
					dests[dst] = new_dest
				end
			end
		end
	end
end

do
	local instrs = {
		{'JMP', dests[start.dest]}
	}
	local labels = {}

	local part_is = {}

	for _, part in ipairs(parts) do
		if part.emit then
			part_is[part] = #instrs + 1
			for _, instr in ipairs(part.instrs) do
				local instr_

				if instr[1] == 'JMP' then
					instr_ = {'JMP', dests[instr[2]] or instr[2]}
				elseif instr[1] == 'JIZ' then
					instr_ = {'JIZ', instr[2], dests[instr[3]] or instr[3]}
				else
					instr_ = instr
				end

				instrs[#instrs + 1] = instr_
			end
		end
	end

	for lbl, part in pairs(labeled) do
		if part.emit then
			labels[lbl] = part_is[part]
		end
	end

	-- instrs, labels = passes.desugar_jmps(nil, instrs, labels)
	-- instrs, labels = passes.drop_labels(nil, instrs, labels)

	io.write(reify(instrs, labels))
end
