return {
	merge = function(...)
		local rules = {...}

		return setmetatable({}, {
			__index = function(self, k)
				if k == 'live' then
					for _, rule in ipairs(rules) do
						if rule.live then
							return true
						end
					end
					return false
				end
			end;
			__call = function(self, arg)
				for _, rule in ipairs(rules) do
					local handler = rule(arg)
					if handler then
						return handler
					end
				end
			end;
		})
	end;

	seq = function(...)
		local rules = {...}

		local i = 1
		return setmetatable({}, {
			__index = function(self, k)
				if k == 'live' then
					while i <= #rules and not rules[i].live do
						i = i + 1
					end

					return i <= #rules
				end
			end;
			__call = function(self, arg)
				while not rules[i].live do
					i = i + 1
					if i > #rules then
						return
					end
				end

				return rules[i](arg)
			end;
		})
	end;

	pattern = function(pat, rule)
		return setmetatable({}, {
			__index = function(self, k)
				if k == 'live' then
					return rule.live
				end
			end;
			__call = function(self, arg)
				local m = {arg:match(pat)}

				if m[1] then
					return rule(m)
				end
			end;
		})
	end;

	split = function(...)
		local rules = {...}

		return setmetatable({}, {
			__index = function(self, k)
				if k == 'live' then
					for _, rule in ipairs(rules) do
						if not rule.live then
							return false
						end
					end
					return true
				end
			end;
			__call = function(self, arg)
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
			end;
		})
	end;

	filter = function(f, rule)
		return setmetatable({}, {
			__index = function(self, k)
				if k == 'live' then
					return rule.live
				end
			end;
			__call = function(self,arg)
				if f(arg) then
					return rule(arg)
				end
			end;
		})
	end;

	map = function(f, rule)
		return setmetatable({}, {
			__index = function(self, k)
				if k == 'live' then
					return rule.live
				end
			end;
			__call = function(self, arg)
				return rule(f(arg))
			end;
		})
	end;

	bind = function(f, rule)
		return setmetatable({}, {
			__index = function(self, k)
				if k == 'live' then
					return rule.live
				end
			end;
			__call = function(self, arg)
				local r = f(arg)
				if r then
					return rule(r)
				end
			end;
		})
	end;

	collect = function(t)
		local self = setmetatable({ live = true }, { __call = function(self, arg)
			return function()
				t[#t + 1] = arg
			end
		end })
		t = t or self
		return self
	end;

	one = function(t)
		local self = setmetatable({ live = true }, { __call = function(self, arg)
			if not t.set then
				return function()
					if t.set then error('multiple for one') end
					t.set = true
					self.live = false
					t.v = arg
				end
			end
		end })
		t = t or self
		return self
	end;

	first = function(t)
		local self = setmetatable({ live = true }, { __call = function(self, arg)
			return function()
				if not t.set then
					t.set = true
					t.v = arg
				end
			end
		end })
		t = t or self
		return self
	end;

	last = function(t)
		local self = setmetatable({ live = true }, { __call = function(self, arg)
			return function()
				self.set = true
				self.v = arg
			end
		end })
	end;

	parse = function(args, rule)
		for i, arg in ipairs(args) do
			local handler = rule.live and rule(arg)
			if handler then
				handler()
			else
				error(('unhandled arg %q at %d'):format(arg, i))
			end
		end
	end;
}
