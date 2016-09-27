return {
	merge = function(...)
		local rules = {...}

		return function(arg)
			for _, rule in ipairs(rules) do
				local handler = rule(arg)
				if handler then
					return handler
				end
			end
		end
	end;

	seq = function(...)
		local rules = {...}

		local i = 1
		return function(arg)
			if i <= #rules then
				local handler = rules[i](arg)
				if handler then
					i = i + 1
					return handler
				end
			end
		end
	end;

	pattern = function(pat, rule)
		return function(arg)
			local m = {arg:match(pat)}

			if m then
				return rule(m)
			end
		end
	end;

	split = function(...)
		local rules = {...}

		return function(arg)
			local handlers = {}

			for i, rule in ipairs(rules) do
				handlers[i] = rule(arg[i])
				if not handlers[i] then
					return
				end
			end

			return function()
				for _, handler in ipairs(handlers) do
					handler()
				end
			end
		end
	end;

	filter = function(f, rule)
		return function(arg)
			if f(arg) then
				return rule(arg)
			end
		end
	end;

	map = function(f, rule)
		return function(arg)
			return rule(f(arg))
		end
	end;

	bind = function(f, rule)
		return function(arg)
			local r = f(arg)
			if r then
				return rule(r)
			end
		end
	end;

	collect = function()
		return setmetatable({}, { __call = function(t, arg)
			return function()
				t[#t + 1] = arg
			end
		end })
	end;

	one = function()
		return setmetatable({}, { __call = function(t, arg)
			if not t.set then
				return function()
					if t.set then error('multiple for one') end
					t.set = true
					t.v = arg
				end
			end
		end })
	end;

	first = function()
		return setmetatable({}, { __call = function(t, arg)
			return function()
				if not t.set then
					t.set = true
					t.v = arg
				end
			end
		end })
	end;

	last = function()
		return setmetatable({}, { __call = function(t, arg)
			return function()
				t.set = true
				t.v = arg
			end
		end })
	end;

	parse = function(args, rule)
		for i, arg in ipairs(args) do
			local handler = rule(arg)
			if handler then
				handler()
			else
				error(('unhandled arg %q at %d'):format(arg, i))
			end
		end
	end;
}
