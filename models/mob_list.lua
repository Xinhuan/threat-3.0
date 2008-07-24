local base = {}
local base_mt = {__index = base}
Threat30.EmbedCallbacks(base)

-- This is a singleton object, more or less.

Threat30.mob_list = setmetatable({}, base_mt)
local mobs = {}

Threat30:RegisterCallback("MobCreated")

function base:ClearList()
	for k, v in pairs(mobs) do
		v:Destroy()
	end
	encounterMobs = 0
end

function base:MobCreated(mob)
	local guid = mob
	mob:RegisterCallback(self, "MobDied")
	mob:RegisterCallback(self, "MobCrowdControlled")
	mob:RegisterCallback(self, "MobUnCrowdControlled")
	encounterMobs = encounterMobs + 1
end

function base:MobDied(mob)
	encounterMobs = encounterMobs - 1
	assert(encounterMobs >= 0)
end

function base:MobCrowdControlled(mob)
	encounterMobs = encounterMobs - 1
	assert(encounterMobs >= 0)
end

function base:MobUnCrowdControlled(mob)
	encounterMobs = encounterMobs + 1
end

function base:AddThreatOn(mobGUID, playerGUID, threat)
	mobs[mobGUID] = mobs[mobGUID] or Threat30:CreateMob(mobGUID)
	mobs[mobGUID]:AddThreat(playerGUID, threat)
end

function base:AddThreatOnAll(playerGUID, threat)
	local perMobThreat = threat / encounterMobs
	for guid, mob in pairs(mobs) do
		mob:AddThreat(playerGUID, perMobThreat)
	end
end

function base:MultiplyThreatOn(mobGUID, playerGUID, multiplier)
	mobs[mobGUID] = mobs[mobGUID] or Threat30:CreateMob(mobGUID)
	mobs[mobGUID]:MultiplyThreat(playerGUID, threat)
end

function base:MultiplyThreatOnAll(playerGUID, multiplier)
	for guid, mob in pairs(mobs) do
		mob:MultiplyThreat(playerGUID, multiplier)
	end
end

function base:SetThreatOnAll(playerGUID, threat)
	for guid, mob in pairs(mobs) do
		mob:SetThreat(playerGUID, threat)
	end
end

function base:GetThreatOn(mobGUID, playerGUID)
	local mob = mobs[mobGUID]
	if not mob then return 0 end
	mob:GetThreatForPlayer(playerGUID)
end
