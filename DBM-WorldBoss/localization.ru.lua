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
	Flame				= "Пламя Кошмаров {rt%d} установлена на %s",
	Sveaz				= "Кошмарная цепь {rt%d} установлена на %s"
}
L:SetOptionLocalization{
	SetIconOnSveazTarget	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(314606),
	SetIconOnFlameTarget	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(307839),
	AnnounceFlame			= "Объявлять игроков, на кого установлена метка $spell:307839, в рейд чат",
	RangeFrame				= "Показывать окно проверки дистанции",
	AnnounceSveaz			= "Объявить игрока на которого установлена метка $spell:314606, в рейд чат",
}