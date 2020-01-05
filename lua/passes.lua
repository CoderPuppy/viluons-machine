return {
	desugar_jmps = function(arg, instrs, labels)
		local ret = {}

		local function desugar_jmp(ip, to)
			local v = to:match '^=(%d+)$'
			if v then
				return tonumber(v) - ip - 1
			end

			local v = to:match '^(%-?%d+)$'
			if v then
				return tonumber(v)
			end

			local lbl = to:match '^:(.+)$'
			if lbl then
				if labels[lbl] then
					return labels[lbl] - ip - 1
				else
					error(('unknown label: %q'):format(lbl))
				end
			end

			if type(to) == 'number' or to == 'ERROR' then
				return to
			end

			if to == 'END' then
				return #instrs + 1 - ip - 1
			end

			error(('unknown destination: %q'):format(to))
		end

		for i, instr in ipairs(instrs) do
			if instr[1] == 'JMP' then
				ret[i] = { 'JMP', desugar_jmp(i, instr[2]) }
			elseif instr[1] == 'JIZ' then
				ret[i] = { 'JIZ', instr[2], desugar_jmp(i, instr[3]) }
			else
				ret[i] = instr
			end
		end
		return ret, labels
	end;

	desugar_decr_branch = function(arg, instrs, labels)
		local offs = {}
		local deoffs = {}
		local off = 0

		local function process_jmp(i, to)
			if type(to) == 'number' or to:match '^%-?%d+$' then
				local to = tonumber(to) + deoffs[i] + 1
				return tostring((offs[to] or to + off) - i - 1)
			end

			local i_ = to:match '^=(%d+)$'
			if i_ then
				return ('=%d'):format(offs[tonumber(i_)])
			end

			return to
		end

		local instrs_ = {}
		local labels_ = {}
		for i, instr in ipairs(instrs) do
			offs[i] = i + off
			if i + off ~= #instrs_ + 1 then
				error('bad')
			end
			if instr[1] == 'DECR?' then
				off = off + 1
				instrs_[#instrs_ + 1] = {'JIZ', instr[2], instr[3]}
				instrs_[#instrs_ + 1] = {'DECR', instr[2]}
			elseif instr[1] == 'JMP' then
				instrs_[#instrs_ + 1] = {'JMP', instr[2]}
			elseif instr[1] == 'JIZ' then
				instrs_[#instrs_ + 1] = {'JIZ', instr[2], instr[3]}
			elseif instr[1] == 'INCR' then
				instrs_[#instrs_ + 1] = instr
			elseif instr[1] == 'DECR' then
				instrs_[#instrs_ + 1] = instr
			else
				error(('unhandled instr: %s'):format(instr[1]))
			end
			for j = offs[i], #instrs_ do
				deoffs[j] = i
			end
		end

		for lbl, i in pairs(labels) do
			labels_[lbl] = offs[i] or (i + off)
		end

		for i, instr in ipairs(instrs_) do
			if instr[1] == 'JMP' then
				instr[2] = process_jmp(i, instr[2])
			elseif instr[1] == 'JIZ' then
				instr[3] = process_jmp(i, instr[3])
			end
		end

		return instrs_, labels_
	end;

	drop_labels = function(arg, instrs, labels)
		return instrs, {}
	end;
}
