return function(instrs, regs_, ip_)
	local regs = setmetatable({}, { __index = function(t, k)
		local v = regs_ and regs_[k] or 0
		rawset(t, k, v)
		return v
	end })
	local ip = ip_ or 1

	local function jump(to)
		if type(to) == 'number' then
			ip = ip + to
		elseif to == 'ERROR' then
			error('ERROR at ' .. tostring(ip))
		end
	end

	local handlers = {
		JIZ = function(reg, to)
			if regs[reg] == 0 then
				jump(to)
			end
		end;
		JMP = function(to)
			jump(to)
		end;
		INCR = function(reg)
			regs[reg] = regs[reg] + 1
		end;
		DECR = function(reg)
			regs[reg] = regs[reg] - 1
		end;
	}

	local count = 0

	while ip <= #instrs do
		count = count + 1

		if ip < 1 then
			ip = 1
		end

		local instr = instrs[ip]

		if handlers[instr[1]] then
			handlers[instr[1]](table.unpack(instr, 2, #instr))
		else
			error('unknown instr: ' .. tostring(instr[1]))
		end

		ip = ip + 1
	end

	return regs, ip, count
end
