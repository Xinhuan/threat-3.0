local base = {}
local base_mt = {__index = base}
Threat30.EmbedCallbacks(base)

local mobList = Threat30.mob_list

function Threat30:NewPlayer(guid)
	local t = Threat.newTable()
	setmetatable(t, base_mt)
	t.guid = guid
	self:FireCallback("PlayerCreated", t)
end

function playerBase:AddThreat(guid, threat)
	mobList:AddThreatOn(guid, self.guid, threat)
end

function playerBase:AddThreatOnAll(threat)
	mobList:AddGlobalThreat(self.guid, threat)
end

function playerBase:MultiplyThreatOn(mobGUID, multiplier)
	mobList:MultiplyThreatOn(mobGUID, self.guid, multiplier)
end

function playerBase:MultiplyThreatOnAll(mobGUID, multiplier)
	mobList:MultiplyThreatOnAll(mobGUID, self.guid, multiplier)
end

function playerBase:SetThreatOnAll(threat)
	mobList:SetThreatOnAll(self.guid, threat)
end

function playerBase:GetThreatOn(mobGUID)
	return mobList:GetThreatOn(mobGUID, self.guid)
end

function playerBase:Death()
	mobList:SetThreatOnAll(0)
end

function playerBase:Destroy()
	--[[
	Clean up, should notify other clients that this player is no longer in combat
	This will primarily be for pets, who despawn and respawn relatively regularly
	Actual players will likely never need this method, since they maintain a single
	GUID for life. We should likely only call this on despawn, not on death.
	
	This will be used like so:
	
	player = player:Destroy()
	
	In order to get rid of the last reference to this table.
	]]-- 
	self.mobs = Threat30.delTable(self.mobs)
	return Threat30.delTable(self)
end
