Threat30.tests = {}

function Threat30:RunTests()
	for k, v in pairs(Threat30.tests) do
		v:RunTests()
	end
	Threat30:Print("Tests complete!")
end
