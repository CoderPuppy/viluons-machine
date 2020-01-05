return function(instrs, labels)
	local lines = {}
	for i, instr in ipairs(instrs) do
		if instr[1] == 'JIZ' then
			lines[i] = '?K' .. tostring(instr[2]) .. ' ' .. tostring(instr[3])
		elseif instr[1] == 'JMP' then
			lines[i] = 'JMP ' .. tostring(instr[2])
		elseif instr[1] == 'INCR' then
			lines[i] = 'K' .. tostring(instr[2]) .. '++'
		elseif instr[1] == 'DECR' then
			lines[i] = 'K' .. tostring(instr[2]) .. '--'
		else
			error('unknown instruction: ' .. tostring(instr[1]))
		end
	end
	
	for i, line in ipairs(lines) do
		lines[i] = '  ' .. line
	end

	do
		local labels_i = {}
		for lbl, i in pairs(labels) do
			labels_i[#labels_i + 1] = {lbl, i}
		end

		table.sort(labels_i, function(a, b)
			return a[2] < b[2]
		end)

		local off = 0
		for _, lbl in ipairs(labels_i) do
			table.insert(lines, lbl[2] + off, lbl[1] .. ':')
			off = off + 1
		end
	end

	local out = ''
	for _, line in ipairs(lines) do
		out = out .. line .. '\n'
	end
	return out
end
