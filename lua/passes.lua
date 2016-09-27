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

	drop_labels = function(arg, instrs, labels)
		return instrs, {}
	end;
}
