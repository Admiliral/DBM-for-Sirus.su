if GetLocale() ~= "ruRU" then return end

local L

--Magtheridon
L = DBM:GetModLocalization("Magtheridon")

L:SetGeneralLocalization{
	name = "Магтеридон "
}

L:SetTimerLocalization{
	Pull = "Активация босса"
}

L:SetWarningLocalization{
	WarnPhase2soon = "Скоро фаза 2",
	WarnHandOfMagt = "Печать Магтеридона"
}

L:SetOptionLocalization{
	WarnPhase2soon = "Анонсировать переход на вторую фазу",
	WarnHandOfMagt = "Спец предупреждение для целей Печати",
	Pull = "Отсчет времени до активации босса"
}

L:SetMiscLocalization{
	YellPhase2 = "Меня так просто не возьмешь! Пусть стены темницы содрогнутся... и падут!"
}

