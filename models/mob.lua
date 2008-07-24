local base = {}
local base_mt = {__index = base}
Threat30.EmbedCallbacks(base)

function Threat30:CreateMob(guid)
	local t = Threat30.newTable()
	setmetatable(t, base_mt)
	
	t.guid = guid
	t.threat = Threat30.newTable()
	t.isCrowdControlled = false
	t.playerCount = 0
	self:FireCallback("MobCreated", t)
end

function base:AddThreat(playerGUID, threat)
	
	if self.isCrowdControlled then return end
	self.threat[playerGUID] = (self.threat[playerGUID] or 0) + threat
	self:FireCallback("ThreatUpdated", playerGUID, self.threat[playerGUID])
end

function base:SetThreat(playerGUID, threat)
	self.threat[playerGUID] = threat
	self:FireCallback("ThreatUpdated", playerGUID, self.threat[playerGUID])
end

function base:MultiplyThreat(playerGUID, multiplier)
	self.threat[playerGUID] = (self.threat[playerGUID] or 0) * multiplier
	self:FireCallback("ThreatUpdated", playerGUID, self.threat[playerGUID])
end

function base:GetThreatForPlayer(guid)
	return self.threat[playerGUID] or 0
end

function base:CrowdControl()
	self.isCrowdControlled = true
	self:FireCallback("MobCrowdControlled")
end

function base:UnCrowdControl()
	self.isCrowdControlled = false
	self:FireCallback("MobUnCrowdControlled")
end

function base:Death()
	self:FireCallback("MobDied")
	self:Destroy()
end

function base:Destroy()
	self.threat = Threat30.delTable(self.threat)
	self:FireCallback("MobDestroyed")
end
