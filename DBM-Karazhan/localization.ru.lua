if GetLocale() ~= "ruRU" then return end

local L

--Attumen
L = DBM:GetModLocalization("Attumen")

L:SetGeneralLocalization{
	name = "Аттумен Охотник"
}

L:SetWarningLocalization{
	WarnPhase2Soon = "Скоро фаза 2"
}

L:SetOptionLocalization{
	WarnPhase2Soon = "Предупреждать о переходе на пешую фазу"
}

L:SetMiscLocalization{
	DBM_ATH_YELL_1		= "Давай, Полночь, разгоним этот сброд!",
	KillAttumen			= "Always knew... someday I would become... the hunted."
}


--Moroes
L = DBM:GetModLocalization("Moroes")

L:SetGeneralLocalization{
	name = "Мороуз"
}

L:SetWarningLocalization{
	DBM_MOROES_VANISH_FADED	= "Исчезновение рассеивается",
	WarnPhase2Soon = "Скоро фаза 2",
}

L:SetTimerLocalization{
	Phase2 = "Фаза 2"
}

L:SetOptionLocalization{
	DBM_MOROES_VANISH_FADED	= "Show vanish fade warning",
	WarnPhase2Soon = "Предупреждать о приближении второй фазы",
	WarnDeathMark = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(305470, GetSpellInfo(305470) or "unknown"),
	Phase2 = "Отсчитывать время до второй фазы."
}

L:SetMiscLocalization{
	DBM_MOROES_YELL_START	= "Хмм, неожиданные посетители. Нужно подготовиться..."
}


-- Maiden of Virtue
L = DBM:GetModLocalization("Maiden")

L:SetGeneralLocalization{
	name = "Благочестивая дева"
}

L:SetWarningLocalization{
}

L:SetOptionLocalization{
	RangeFrame			= "Show range frame (10)",
	HealthFrame         = "Отображать здоровье босса и прочность щита"
}

L:SetMiscLocalization{
}


-- Romulo and Julianne
L = DBM:GetModLocalization("RomuloAndJulianne")

L:SetGeneralLocalization{
	name = "Ромуло и Джулианна"
}

L:SetWarningLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	DBM_RJ_PHASE2_YELL	= "Ночь, добрая и строгая, приди! Верни мне моего Ромуло!",
	Romulo				= "Ромуло",
	Julianne			= "Джулианна"
}


-- Big Bad Wolf
L = DBM:GetModLocalization("BigBadWolf")

L:SetGeneralLocalization{
	name = "Злой и страшный серый волк"
}

L:SetWarningLocalization{
}

L:SetOptionLocalization{
	RRHIcon		= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(30753)
}

L:SetMiscLocalization{
	DBM_BBW_YELL_1			= "Так вам и надо!"
}


-- Curator
L = DBM:GetModLocalization("Curator")

L:SetGeneralLocalization{
	name = "Смотритель"
}

L:SetWarningLocalization{
	WarnUnstableTar = "Нестабильная энергия на >%s<"
}

L:SetTimerLocalization{
	TimerRunesBam = "Взрыв!"
}

L:SetOptionLocalization{
	RangeFrame			= "Show range frame (10)",
	WarnUnstableTar =   DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(305309, GetSpellInfo(305309) or "unknown"),
	TimerRunesBam = "Отсчет времени до взрыва рун"
}

L:SetMiscLocalization{
	DBM_CURA_YELL_PULL		= "Галерея только для гостей.",
	DBM_CURA_YELL_OOM		= "Ваш запрос не может быть выполнен."
}


-- Terestian Illhoof
L = DBM:GetModLocalization("TerestianIllhoof")

L:SetGeneralLocalization{
	name = "Терестиан Больное Копыто"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
}

L:SetMiscLocalization{
	DBM_TI_YELL_PULL		= "А, вы как раз вовремя! Ритуалы скоро начнутся!",
	Kilrek					= "Kil'rek",
	DChains					= "Demon Chains"
}


-- Shade of Aran
L = DBM:GetModLocalization("Aran")

L:SetGeneralLocalization{
	name = "Тень Арана"
}

L:SetWarningLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "Не двигайтесь!",
	SpecWarnFreeze = "Вы будете заморожены!",
	WarnFreeze = "%s заморожен!"
}

L:SetTimerLocalization{
	TimerSpecialHeroic = "Следующая спец-способность"
}

L:SetOptionLocalization{
	DBM_ARAN_DO_NOT_MOVE	= "Show special warning for $spell:30004",
	TimerSpecialHeroic = "Отсчет времени до следующей спец-способности",
	SpecWarnFreeze = "Предупреждение о том что вы будете заморожены",
	WarnFreeze = "Обьявление замороженой цели"
}

L:SetMiscLocalization{
	Familliar = "Фамильяр"
}


--Netherspite
L = DBM:GetModLocalization("Netherspite")

L:SetGeneralLocalization{
	name = "Пустогнев"
}

L:SetWarningLocalization{
	DBM_NS_WARN_PORTAL_SOON	= "Фаза порталов через 5 секунд",
	DBM_NS_WARN_BANISH_SOON	= "Фаза изгнания через 5 секунд",
	warningPortal			= "Фаза порталов",
	warningBanish			= "Фаза изгнания",
	SpecWarnKickNow			= "Прерывание"
}

L:SetTimerLocalization{
	timerPortalPhase	= "Фаза порталов",
	timerBanishPhase	= "Фаза изгнания",
	TimerGates          = "Зеленые лучи",
	TimerGhostPhase     = "Призрачная фаза",
	TimerRepentance     = "Возмездие",
	TimerPortals        = "Появление порталов",
	TimerNormalPhase    = "Обычная фаза"
}

L:SetOptionLocalization{
	DBM_NS_WARN_PORTAL_SOON	= "Show pre-warning for Portal phase",
	DBM_NS_WARN_BANISH_SOON	= "Show pre-warning for Banish phase",
	warningPortal			= "Show warning for Portal phase",
	warningBanish			= "Show warning for Banish phase",
	timerPortalPhase		= "Show timer for Portal Phase duration",
	timerBanishPhase		= "Show timer for Banish Phase duration",
	SpecWarnKickNow				= "Спец-предупреждение, когда вы должы прервать заклинание",
	TimerGates          = "Зеленые лучи",
	TimerGhostPhase     = "Призрачная фаза",
	TimerRepentance     = "Возмездие",
	TimerPortals        = "Появление порталов",
	TimerNormalPhase    = "Обычная фаза"
}

L:SetMiscLocalization{
	DBM_NS_EMOTE_PHASE_2	= "%s goes into a nether-fed rage!",
	DBM_NS_EMOTE_PHASE_1	= "%s cries out in withdrawal, opening gates to the nether."
}


--Prince Malchezaar
L = DBM:GetModLocalization("Prince")

L:SetGeneralLocalization{
	name = "Принц Малчезар"
}

L:SetWarningLocalization{
	WarnNextPhaseSoon = "Фаза %s"
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	WarnNextPhaseSoon = "Предупреждать о переходе на следующую фазу",
	AnnouncePorch	  = "Объявлять игроков, на кого установлен $spell:305429, в рейд чат"
}

L:SetMiscLocalization{
	DBM_PRINCE_YELL_PULL	= "Безумие привело вас сюда, ко мне. Я стану вашей погибелью!",
	DBM_PRINCE_YELL_P2		= "Простофили! Время – это пламя, в котором вы сгорите!",
	DBM_PRINCE_YELL_P3		= "Как ты можешь надеяться выстоять против такой ошеломляющей мощи?",
	DBM_PRINCE_YELL_INF1	= "Все миры, все измерения открыты мне!",
	DBM_PRINCE_YELL_INF2	= "Вас ждет не один Малчезаар, но и легионы, которыми я командую!",
	FlameWorld              = "Огненные просторы",
	IceWorld                = "Ледяная пустошь",
	BlackForest             = "Черный лес",
	Porch					= "Мстительная порча {rt%d} установлена на: %s",
	LastPhase               = "Финал"
}


-- Nightbane
L = DBM:GetModLocalization("Nightbane")

L:SetGeneralLocalization{
	name = "Ночная Погибель"
}

L:SetWarningLocalization{
	DBM_NB_DOWN_WARN 		= "Наземная фаза через 15 секунд",
	DBM_NB_DOWN_WARN2 		= "Наземная фаза через 5 секунд",
	DBM_NB_AIR_WARN			= "Воздушная фаза"
}

L:SetTimerLocalization{
	timerNightbane			= "Начало",
	timerAirPhase			= "Воздушная фаза"
}

L:SetOptionLocalization{
	SetIconOnPyromancer     = "Устанавливать иконки на Пиромантов",
	AnnouncePyromancerIcons = "Анонсировать Пиромантов",
	RemoveWeaponOnMindControl = "Снимать оружие при подчинении",
	DBM_NB_AIR_WARN			= "Показать предупреждение для воздушной фазы",
	PrewarnGroundPhase		= "Показать предварительные предупреждения для наземной фазы",
	timerNightbane			= "Показать таймер для вызова",
	timerAirPhase			= "Показать таймер продолжительности воздушной фазы"
}

L:SetMiscLocalization{
	Pyromancer              = "Пиромант",
	Hypothermia             = "Переохлаждение",
	PyromancerIconSet       = "Знак пироманта {rt%d} установлен на %s",
	DBM_NB_EMOTE_PULL		= "Древнее существо пробуждается вдалеке...",
	DBM_NB_YELL_PULL		= "Ну и глупцы! Я быстро покончу с вашими страданиями!",
	DBM_NB_YELL_AIR			= "Жалкий гнус! Я изгоню тебя из воздуха!",
	DBM_NB_YELL_GROUND		= "Довольно! Я сойду на землю и сам раздавлю тебя!",
	DBM_NB_YELL_GROUND2		= "Ничтожества! Я вам покажу мою силу поближе!"
}


-- Wizard of Oz
L = DBM:GetModLocalization("Oz")

L:SetGeneralLocalization{
	name = "Страна Оз"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{
	AnnounceBosses			= "Show warnings for boss spawns",
	ShowBossTimers			= "Show timers for boss spawns",
	DBM_OZ_OPTION_1			= "Показать область границы контроля в фазе 2"
}

L:SetMiscLocalization{
	DBM_OZ_WARN_TITO		= "*** Тито ***",
	DBM_OZ_WARN_ROAR		= "*** Хохотун ***",
	DBM_OZ_WARN_STRAWMAN	= "*** Балбес ***",
	DBM_OZ_WARN_TINHEAD		= "*** Медноголовый ***",
	DBM_OZ_WARN_CRONE		= "*** Ведьма ***",
	DBM_OZ_YELL_DOROTHEE	= "О, Тито, нам просто надо найти дорогу домой!",
	DBM_OZ_YELL_ROAR		= "I'm not afraid a' you! Do you wanna' fight? Huh, do ya'? C'mon! I'll fight ya' with both paws behind my back!",
	DBM_OZ_YELL_STRAWMAN	= "Now what should I do with you? I simply can't make up my mind.",
	DBM_OZ_YELL_TINHEAD		= "I could really use a heart. Say, can I have yours?",
	DBM_OZ_YELL_CRONE		= "Woe to each and every one of you, my pretties!"
}


-- Zluker
L = DBM:GetModLocalization("Zluker")

L:SetGeneralLocalization{
	name = "Злюкер"
}

L:SetWarningLocalization{
}

L:SetTimerLocalization{
}

L:SetOptionLocalization{

}

L:SetMiscLocalization{
	YellZluker = "Вместе мы неудержимы!"
}


-- Named Beasts
L = DBM:GetModLocalization("Shadikith")

L:SetGeneralLocalization{
	name = "Shadikith the Glider"
}

L = DBM:GetModLocalization("Hyakiss")

L:SetGeneralLocalization{
	name = "Hyakiss the Lurker"
}

L = DBM:GetModLocalization("Rokad")

L:SetGeneralLocalization{
	name = "Rokad the Ravager"
}
