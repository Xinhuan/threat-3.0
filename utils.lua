-- Table recycling
local new, newHash, newSet, del
do
	local list = setmetatable({}, {__mode='k'})
	
	function new(...)
		local t = next(list)
		if t then
			list[t] = nil
			for i = 1, select('#', ...) do
				t[i] = select(i, ...)
			end
		else
			t = {...}
		end
		return t
	end
	Threat.newTable = new
	function newHash(...)
		local t = next(list)
		if t then
			list[t] = nil
		else
			t = {}
		end	
		for i = 1, select('#', ...), 2 do
			t[select(i, ...)] = select(i+1, ...)
		end
		return t
	end
	Threat.newHash = newHash
	function newSet(...)
		local t = next(list)
		if t then
			list[t] = nil
		else
			t = {}
		end	
		for i = 1, select('#', ...) do
			t[select(i, ...)] = true
		end
		return t
	end
	Threat.newSet = newSet
	function del(t)
		setmetatable(t, nil)
		for k in pairs(t) do
			t[k] = nil
		end
		t[''] = true
		t[''] = nil
		list[t] = true
		return nil
	end
	Threat.delTable = del
end