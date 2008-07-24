local eventFrame = CreateFrame("Frame", "Threat30EventFrame")
Threat30[0] = eventFrame[0];
Threat30 = setmetatable({}, getmetatable(eventFrame))

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
	Threat30.newTable = new
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
	Threat30.newHash = newHash
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
	Threat30.delTable = del
end

do
	local registeredEvents = {}
	local function onEvent(self, event, ...)
		if registeredEvents[event] then
			for k, v in pairs(registeredEvents[event]) do
				v(k, event, ...)
			end
		elseif event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
			if not self.initialized then
				self.initialized = true
				self:OnInitialize()
			end
			
			if IsLoggedIn() then
				if not self.enabled then
					self:OnEnable()
				end
			end
		end
	end
	Threat30:SetScript("OnEvent", onEvent)

	function Threat30:FireEvent(name, ...)
		onEvent(eventFrame, name, ...)
	end
	
	Threat30.registeredEvents = {}
	function Threat30.RegisterEvent(self, name, handler)
		eventFrame:RegisterEvent(name)
		handler = handler or name
		registeredEvents[name] = registeredEvents[name] or Threat30.newTable
		local events = registeredEvents[name]
		if type(handler) == "string" then
			if self[name] and type(self[name]) == "function" then
				events.eventCount = events.eventCount + 1
				events[self] = self[name]
			else
				error(("Unable to bind event handler %s: %s not found on self"):format(name, handler))
			end
		elseif type(handler) == "function" then
			events.eventCount = events.eventCount + 1
			events[self] = handler
		end
	end

	function Threat30.UnregisterEvent(self, name)
		local events = registeredEvents[name]
		if events and events[self] then
			events[self] = Threat30.delTable(events[self])
			events.eventCount = events.eventCount - 1
			if events.eventCount == 0 then
				registeredEvents[name] = Threat30.delTable(registeredEvents[name])
			end
		end	
		eventFrame:UnregisterEvent(name)
	end
end

function Threat30:Debug(msg, ...)
	if self.DebugFrame then
		local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p = ...
		self.DebugFrame:AddMessage(("|cffffcc00ThreatLib-Debug: |r" .. msg):format(
			tostring(a),
			tostring(b),
			tostring(c),
			tostring(d),
			tostring(e),
			tostring(f),
			tostring(g),
			tostring(h),
			tostring(i),
			tostring(j),
			tostring(k),
			tostring(l),
			tostring(m),
			tostring(n),
			tostring(o),
			tostring(p)				
		))
	end
end

do
	local callback_base = {}
	local callback_base_mt = {__index = callback_base}
	Threat30.EmbedCallbacks = function(self) {
		for k, v in pairs(callback_base) do
			self[k] = v
		end
	}

	function callback_base:_getHandler(event, handler)
		handler = handler or event
		if type(handler) == "string" then
			if type(self[event]) == "function" then
				handler = self[event]
			else
				error(("Unable to bind %s on self: no method"):format(event))
			end
		end
	end
	
	function callback_base:RegisterCallback(target_obj, event, handler)
		self.callbacks = self.callbacks or {}
		self.callback_objects = self.callback_objects or {}
		self.callbacks[event] = self.callbacks[event] or {}
		tinsert(self.callback_objects, target_obj)
		tinsert(self.callbacks[event], self:_getHandler(event, handler))
	end

	function callback_base:UnregisterCallback(target_obj, event, handler)
		if not self.callbacks then return end
		if not self.callbacks[event] then return end
		local ref = self:_getHandler(event, handler)
		for idx, val in ipairs(self.callbacks[event]) do
			if val == ref and self.callback_objects[event][idx] == target_obj then
				tremove(self.callbacks[event], idx)
				tremove(self.callback_objects[event], idx)
				return
			end
		end
	end

	function callback_base:FireCallback(event, ...)
		if not self.callbacks then return end
		if not self.callbacks[event] then return end
		for idx, handler in ipairs(self.callbacks[event]) do
			handler(self.callback_objects[idx], self, ...)
		end
	end
	Threat30:EmbedCallbacks()
end
