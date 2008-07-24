-- Threat30 is defined in utils.lua due to load order issues

function Threat30:OnInitialize()
end

function Threat30:OnEnable()
	self.enabled = true
end

function Threat30:OnDisable()
	self.enabled = false
end

Threat30:RegisterEvent("ADDON_LOADED")
Threat30:RegisterEvent("PLAYER_LOGIN")
Threat30.DebugFrame = ChatFrame1