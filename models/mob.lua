local mobBase = {}
local mobBase_mt = {__index = mobBase}

function Threat:CreateMob(guid)
	local t = Threat.newTable()
	t.players = Threat.newTable()
	setmetatable(t, mobBase)
end
