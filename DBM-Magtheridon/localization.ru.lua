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

}

L:SetOptionLocalization{
	Pull = "Отсчет времени до активации босса"
}

L:SetMiscLocalization{
	YellPhase2 = "Меня так просто не возьмешь! Пусть стены темницы содрогнутся... и падут!"
}

