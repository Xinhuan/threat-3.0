local base = {}
local base_mt = {__index = base}

function Threat30:NewPlayer(guid)
	local t = Threat.newTable()
	setmetatable(t, base_mt)
	t.mobs = Threat.newTable()
	t.guid = guid
end

function playerBase:AddThreat(guid, threat)
	mobs[guid] = mobs[guid] or Threat30:NewMob(guid)
	mobs[guid]:AddThreat(self.guid, threat)
end

function playerBase:AddGlobalThreat(threat)
	Threat30.mob_list:AddGlobalThreat(self.guid, threat)
end

function playerBase:Death()
	self:SetAllThreat(0)
end

function playerBase:SetAllThreat(threat)
	for k, v in pairs(mobs) do
		v:SetThreat(self.guid, threat)
	end
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
