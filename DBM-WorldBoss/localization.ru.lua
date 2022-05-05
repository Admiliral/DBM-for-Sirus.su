if GetLocale() ~= "ruRU" then return end

local L

-- Норигорн
L = DBM:GetModLocalization("Norigorn")

L:SetGeneralLocalization{
	name = "Норигорн"
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
}

L:SetMiscLocalization{
}
L:SetOptionLocalization{
}

L = DBM:GetModLocalization("Zort")

L:SetGeneralLocalization{
	name = "Зорт"
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
}

L:SetMiscLocalization{
	Pechat				= "Печать: Предательство {rt%d} установлена на %s",
	Flame				= "Пламя Кошмаров {rt%d} установлена на %s"
}
L:SetOptionLocalization{
	SetIconOn1Target		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(307342),
	AnnouncePech			= "Объявлять игроков, на кого установлена метка $spell:307814, в рейд чат",
	AnnounceFlame			= "Объявить игрока на которого установлена метка $spell:307839, в рейд чат",
}