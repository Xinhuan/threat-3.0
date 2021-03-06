local eventFrame = CreateFrame("Frame", "Threat30EventFrame")

-- Make Threat30 behave like a frame. This lets us use event handling directly, rather than having to proxy through another table, which saves us a method
-- invocation per event handled!
-- Is this really needed? I don't see the advantage --- nevcairiel 2008-07-24
Threat30 = setmetatable({}, getmetatable(eventFrame))
Threat30[0] = eventFrame[0];

-- Table recycling
local new, newHash, del
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

-- Event handling
--[[
	Register events via:
	
	Threat30.RegisterEvent(self, "UNIT_AURA"[, handlerStringOrMethod])
	
	"self" is the object that the handler exists on. It does not have to be the Threat30 object.
	
	Event handlers are stored in a single lookup table, consisting of:
	{
		EVENT_NAME = {
			object = handler,
			object = handler,
			object = handler
		}
	}
	
	Thus, when an event is fired, we need to look up the event in the table, then iterate all objects that have registered the event and invoke the handler for each.
]]--
do
	local registeredEvents = {}
	local function onEvent(self, event, ...)
		if registeredEvents[event] then
			for k, v in pairs(registeredEvents[event]) do
				v(k, event, ...)
			end
		end
	end
	eventFrame:SetScript("OnEvent", onEvent)
	
	-- This function really should never be used in the production code -- nevcairiel 2007-07-24
	function Threat30:FireEvent(name, ...)
		onEvent(eventFrame, name, ...)
	end
	
	Threat30.registeredEvents = {}
	function Threat30.RegisterEvent(self, name, handler)
		eventFrame:RegisterEvent(name)
		handler = handler or name
		registeredEvents[name] = registeredEvents[name] or Threat30.newHash("eventCount", 0)
		
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
				eventFrame:UnregisterEvent(name)
			end
		end
	end
	
	local function initialize(self)
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
	Threat30:RegisterEvent("ADDON_LOADED", initialize)
	Threat30:RegisterEvent("PLAYER_LOGIN", initialize)
end

-- Prints a debug message to the DebugFrame of your choice. 
-- Currently ChatFrame1, set in core.lua
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

--[[
	Callback handling
	Callbacks are stored via 2 tables per object that embeds callbacks. These are indexed tables containing:
	
	{registering_obect_1, registering_obect_2, ..., registering_obect_n}
	{handler_1, handler_2, ..., handler_n}
	
	When a callback is fired, the handlers are iterated, and the registering object is always passed as the first parameter.
	
	local t = {}
	Threat30.EmbedCallbacks(t)
	t:RegisterCallback(SomeOtherTable, "SomeCallback"[, handlerMethodOrString])
	SomeOtherTable:FireCallback("SomeCallback", arg1, arg2)	
	function t:SomeCallback(originatingTable, args...)
		-- handle the callback
	end
]]--
do
	local callback_base = {}
	local callback_base_mt = {__index = callback_base}
	Threat30.EmbedCallbacks = function(self)
		for k, v in pairs(callback_base) do
			self[k] = v
		end
	end

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
		
		for idx = 1, #self.callbacks[event] do
			if self.callbacks[event][idx] == ref and self.callback_objects[event][idx] == target_obj then
				tremove(self.callbacks[event], idx)
				tremove(self.callback_objects[event], idx)
				return
			end
		end
	end

	function callback_base:FireCallback(event, ...)
		if not self.callbacks then return end
		if not self.callbacks[event] then return end
		
		local callbacks, objects = self.callbacks[event], self.callback_objects[event]
		for idx = 1, #callbacks do
			callbacks[idx](objects[idx], self, ...)
		end
	end
	Threat30:EmbedCallbacks()
end
