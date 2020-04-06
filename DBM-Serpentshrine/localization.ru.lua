if GetLocale() ~= "ruRU" then return end

local L

--Hydross
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "Гидросс Нестабильный"
}

L:SetTimerLocalization{
	TimerMarkOfHydross = "Знак Гидроса %s%%",
	TimerMarkOfCorruption = "Знак порчи %s%%"
}

L:SetWarningLocalization{
	WarnMarkOfHydross       = "Знак Гидроса %s%%",
	WarnMarkOfCorruption    = "Знак порчи %s%%",
	SpecWarnThreatReset     = "Сброс угрозы - АСТАНАВИТЕСЬ!!!!"
}

L:SetOptionLocalization{
	TimerMarkOfHydross      = DBM_CORE_AUTO_TIMER_OPTIONS.next:format(38215, GetSpellInfo(38215) or "unknown"),
	TimerMarkOfCorruption   = DBM_CORE_AUTO_TIMER_OPTIONS.next:format(38219, GetSpellInfo(38219) or "unknown"),
	WarnMarkOfHydross       = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(38215, GetSpellInfo(38215) or "unknown"),
	WarnMarkOfCorruption    = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(38219, GetSpellInfo(38219) or "unknown"),
	SpecWarnThreatReset     = "Спец. предупреждение о сбрасывании угрозы"
}

L:SetMiscLocalization{
	YellPull = "Я не позволю вам вмешиваться!",
	YellPoison = "Агрррхх, яд.",
	YellWater = "Так лучше, намного лучше."
}


--Tidewalker
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "Морогрим Волноступ"
}

L:SetTimerLocalization{
	TimerMurlocks   = "Мурлоки"
}

L:SetWarningLocalization{
	WarnMurlocksSoon= "Мурлоки на подходе",
	WarnGlobes      = "Глобулы!"
}

L:SetOptionLocalization{
	WarnMurlocksSoon= "Обьявлять о скором вызове мурлоков",
	WarnGlobes      = "Объявлять о появлении глобул",
	TimerMurlocks   = "Отсчет времени до вызова мурлоков"
}

L:SetMiscLocalization{
	YellPull        = "Да поглотит вас пучина вод!",
	EmoteMurlocs    = "Сильный толчок землетрясения насторожил мурлоков поблизости!",
	EmoteGraves     = "%s отправляет своих врагов в водяные могилы!",
	EmoteGlobes     = "%s призывает водяные шары!"
}

--Leotheras
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "Леотерас Слепец"
}

L:SetTimerLocalization{
	TimerDemon = "Форма демона",
	TimerNormal = "Обычная форма",
	TimerInnerDemons = "Контроль над разумом"
}

L:SetWarningLocalization{
}

L:SetOptionLocalization{
	TimerDemon = "Отсчет времени до превращения в демона",
	TimerNormal = "Отсчет времени до конца формы демона",
	TimerInnerDemons = DBM_CORE_AUTO_TIMER_OPTIONS.active:format(37676, GetSpellInfo(37676) or "unknown"),
	SetIconOnDemonTargets = "Устанавливать иконки на цели демонов"
}

L:SetMiscLocalization{
	YellPull        = "Наконец-то мое заточение окончено!",
	YellDemon       = "Прочь, жалкий эльф. Настало мое время!",
	YellShadow      = "Нет... нет! Что вы наделали? Я – главный! Слышишь меня? Я... Ааааах! Мне его... не удержать."
}

--LurkerBelow
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name           = "Скрытень из глубин"
}

L:SetTimerLocalization{
	Submerge     = "Погружение",
	Emerge       = "Появление"

}

L:SetWarningLocalization{
	WarnSubmerge = "Скоро погружение",
	WarnEmerge   = "Скоро появление"
}

L:SetOptionLocalization{
	WarnSubmerge = "Объявлять погружение",
	WarnEmerge   = "Объявлять появление",
	Submerge     = "Отсчет времени до погружения",
	Emerge       = "Отсчет времени до появления"
}

L:SetMiscLocalization{
	EmoteSpout = "%s делает глубокий вдох."
}

--Fathomlord
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name           = "Повелитель глубин Каратресс"
}

L:SetMiscLocalization{
	YellPull        = "Стража, к бою! У нас гости..."
}

--Vashj
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name       = "Леди Вайш"
}

L:SetTimerLocalization{
	Strider              = "Странник",
	TaintedElemental     = "Нечистый элементаль",
	Naga                 = "Гвардеец"
}

L:SetWarningLocalization{
	WarnCore             = "%s получил порченую магму",
	WarnPhase            = "Фаза %d",
	WarnElemental        = "Нечистый элементаль на подходе"
}

L:SetOptionLocalization{
	WarnCore              = "Объявить наличие порченой магмы",
	WarnPhase             = "Обьявлять о смене фазы",
	Strider               = "Отсчет времени до следующего Странника",
	TaintedElemental      = "Отсчет времени до следующего Нечистого элементаля",
	Naga                  = "Отсчет времени до следующего Гвардейца",
	WarnElemental         = "Объявлять о прибытии Нечистый элементаль"
}

L:SetMiscLocalization{
	YellPhase2              = "Время пришло! Не щадите никого!",
	YellPhase3              = "Вам не пора прятаться?",
	TaintedElemental        = "Нечистый элементаль"
}
