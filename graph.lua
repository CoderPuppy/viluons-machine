return function(instrs, labels)
	local out = ''

	for i, instr in ipairs(instrs) do
		out = out .. ('instr-%d ['):format(i)
		if instr[1] == 'JMP' then
			out = out .. ('label=JMP];\n'):format()
			if type(instr[2]) == 'number' then
				out = out .. ('instr-%d -> instr-%d [];\n'):format(i, instr[2])
			end
		elseif instr[1] == 'JIZ' then
			out = out .. ('label="JIZ %d"];\n'):format(instr[2])
			if type(instr[3]) == 'number' then
				out = out .. ('instr-%d -> instr-%d [label=%q];\n'):format(i, instr[3], tostring(instr[2]) .. ' == 0')
			end
			out = out .. ('instr-%d -> instr-%d [];\n'):format(i, i + 1)
		elseif instr[1] == 'INCR' then
			out = out .. 'label="INCR ' .. tostring(instr[2]) .. '"];\n'
			out = out .. ('instr-%d -> instr-%d [];\n'):format(i, i + 1)
		elseif instr[1] == 'DECR' then
			out = out .. ('label="DECR %d"];\n'):format(instr[2])
			out = out .. ('instr-%d -> instr-%d [];\n'):format(i, i + 1)
		else
			error('unknown instr: ' .. tostring(instr[1]))
		end
	end

	for lbl, i in ipairs(labels) do
		out = out .. ('%q [label=%q];\n'):format('lbl-' .. lbl, lbl)
		out = out .. ('%q -> instr-%d;\n'):format('lbl-' .. lbl, i)
	end

	return out
end
