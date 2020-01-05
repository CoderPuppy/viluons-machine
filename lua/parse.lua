return function(s)
	local instrs = {}
	local labels = {}

	for line in s:gmatch '[^\n\r]+' do
		local instr = line:match '^%s*([^;%s].*)'
		if instr then
			repeat
				local reg, to = instr:match '^%?K(%d+)%s+(.+)$'
				if reg then
					instrs[#instrs + 1] = {'JIZ', tonumber(reg), to}
					break
				end

				local reg = instr:match '^K(%d+)%+%+$'
				if reg then
					instrs[#instrs + 1] = {'INCR', tonumber(reg)}
					break
				end

				local reg = instr:match '^K(%d+)%-%-$'
				if reg then
					instrs[#instrs + 1] = {'DECR', tonumber(reg)}
					break
				end

				local reg, to = instr:match '^%?K(%d+)%-%-%s+(.+)$'
				if reg then
					instrs[#instrs + 1] = {'DECR?', tonumber(reg), to}
					break
				end

				local to = instr:match '^JMP%s+(.+)$'
				if to then
					instrs[#instrs + 1] = {'JMP', to}
					break
				end

				local lbl = instr:match '^([^%s]+):$'
				if lbl then
					labels[lbl] = #instrs + 1
					break
				end

				error('unknown instr: ' .. instr)
			until true
		end
	end

	return instrs, labels
end
