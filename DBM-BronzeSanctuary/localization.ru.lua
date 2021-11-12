if GetLocale() ~= "ruRU" then return end

local L

-- Импорус
L = DBM:GetModLocalization("Imporus")

L:SetGeneralLocalization{
	name = "Импорус"
}

L:SetMiscLocalization{
	YellCrash			= "Темпоральная стрела летит в меня!",
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
	BurningTimeSoon				="Скоро каст Лужи",
	RezonansSoon				="Скоро каст Резонанса"
}

L:SetOptionLocalization{
	SetIconOnTemporalBeat			= "Устанавливать метку на цель заклинания $spell:316519",
	YellOnTemporalCrash				= "Кричать, когда в вас летит $spell:316519",
	RezonansSoon 					= "Таймер о скором применении $spell:316523",
	BossHealthFrame					= "Показывать здоровье босса",
	RangeFrame						= "Показывать окно проверки дистанции (10м)",
	BurningTimeSoon 				= "Таймер о скором применении $spell:316526"
}


-- Элонус
L = DBM:GetModLocalization("Elonus")

L:SetGeneralLocalization{
	name = "Элонус"
}

L:SetTimerLocalization{
}

L:SetWarningLocalization{
	WarningReplicaSpawned = "Появляется копия Элонуса Исказитель времени!!!",
	WarningReplicaSpawnedSoon = "Скоро появляется копия Элонуса",
	WarnirnReturnSoon			="Скоро нужно будет сбить каст!!!!!"

}

L:SetOptionLocalization{
	AnnounceReverCasc			= "Объявлять игроков, на кого установлена метка $spell:312208, в рейд чат",
	AnnounceTempCasc			= "Объявить игрока на которого установлена метка $spell:312206, в рейд чат",
	AnnounceErap				= "Объявлять игроков, на кого установлена метка $spell:312204, в рейд чат",
	WarningReplicaSpawned		= "Предупреждение о появлении копии Элонуса",
	RangeFrame					= "Показывать окно проверки дистанции (6м)",
	TempCascIcon 				= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(312206),
	BossHealthFrame				= "Показывать здоровье босса"
}

L:SetMiscLocalization{
	RevCasc				= "Обратный каскад {rt%d} установлена на %s",
	Erapc				= "Слово силы: Стереть {rt%d} установлена на %s",
	CollapsingStar			= "Копия Элониса",
	IncinerateTarget		= "Щит",
	TempCasc			= "Темпоральный каскад {rt%d} установлен на %s"
}


--Мурозонд
L = DBM:GetModLocalization("Murozond")

L:SetGeneralLocalization{
	name           = "Мурозонд"
}

L:SetTimerLocalization{

}

L:SetWarningLocalization{
	PrePhase = "Скоро каст $spell:313122"
}

L:SetOptionLocalization{
	BossHealthFrame		= "Показывать здоровье босса"
}

L:SetMiscLocalization{
}

