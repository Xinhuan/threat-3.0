local playerBase = {}
local playerBase_mt = {__index = playerBase}

function Threat:CreatePlayer(guid)
	local t = Threat.newTable()
	t.mobs = Threat.newTable()
	t.guid = guid
	setmetatable(t, playerBase)
end

function playerBase:AddThreat(guid, threat)
	mobs[guid] = mobs[guid] or Threat:CreateMob(guid)
	mobs[guid]:AddThreat(self.guid, threat)
end

function playerBase:AddGlobalThreat(threat)
	for k, v in pairs(mobs) do
		mobs[k]:AddThreat(self.guid, threat)
	end
end

