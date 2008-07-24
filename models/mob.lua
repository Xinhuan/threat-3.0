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
	local newThreat = (self.threat[playerGUID] or 0) + threat
	if newThreat < 0 then newThreat = 0 end
	self.threat[playerGUID] = newThreat
	self:FireCallback("ThreatUpdated", playerGUID, newThreat)
end

function base:SetThreat(playerGUID, threat)
	if threat < 0 then threat = 0 end
	self.threat[playerGUID] = threat
	self:FireCallback("ThreatUpdated", playerGUID, threat)
end

function base:MultiplyThreat(playerGUID, multiplier)
	local newThreat = (self.threat[playerGUID] or 0) * multiplier
	if newThreat < 0 then newThreat = 0 end
	self.threat[playerGUID] = newThreat
	self:FireCallback("ThreatUpdated", playerGUID, newThreat)
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
