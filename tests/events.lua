local eventTest = {}

function eventTest:RunTests()
	self:Test_Register();
end

function eventTest:Test_Register()
	Threat30.RegisterEvent(self, "TestEvent")
	Threat30:FireEvent("TEST_EVENT", "foo", "bar")
	assert(self.eventHandled == true)
	self.eventHandled = false
	Threat30.UnregisterEvent(self, "TestEvent")
	Threat30:FireEvent("TEST_EVENT", "foo", "bar")
	assert(self.eventHandled == false)
end

function eventTest:TestEvent(event, arg1, arg2)
	assert(event == "TEST_EVENT")
	assert(arg1 == "foo")
	assert(arg2 == "bar")
	self.eventHandled = true
end

tinsert(Threat30.tests, eventTest)