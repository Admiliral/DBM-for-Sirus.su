if GetLocale() ~= "ruRU" then return end

local L

--Alar
L = DBM:GetModLocalization("Alar")

L:SetGeneralLocalization{
	name = "Ал'ар"
}

L:SetTimerLocalization{
	TimerNextPlat = "След. платформа"
}

L:SetWarningLocalization{
	WarnPlatSoon = "Скоро следующая платформа",
	SpecWarnFeatherNear	= "Падающее перо феникса около вас - остерегайтесь",
	WarnSupernova = "Супернова >%d<",
	WarnPhase2Soon = "Скоро 2-я фаза",
	WarnPhase2 = "ФАЗА 2 БЕЕГИИТЕЕ",
	WarnFlamefal5 = "Падение пламени через 5 секунд!!!",
	WarnFlamefal4 = "Падение пламени через 4 секунды!!!",
	WarnFlamefal3 = "Падение пламени через 3 секунды!!!",
	WarnFlamefal2 = "Падение пламени через 2 секунды!!!",
	WarnFlamefal1 = "Падение пламени через 1 секунду!!!",
	WarnFlamefal0 = "Перья полетели, БЕГИТЕ!!!",
	WarnPhoenixScream2 = "КРИК ЧЕРЕЗ 2 СЕКУНДЫ, ОТВЕРНИТЕСЬ!!!",
	WarnPhoenixScream1 = "КРИК ЧЕРЕЗ 1 СЕКУНДУ, ОТВЕРНИТЕСЬ!!!",
	WarnPhoenixScream0 = "{Череп}{Череп}{Череп}!!!КРИК!!!{Череп}{Череп}{Череп}",
	WarnFireSign = "Знак огня"
}

L:SetOptionLocalization{
	TimerNextPlat = "Отсчет времени до перелета на следующую платформу",
	TwilightCutterCast = "Предупреждать заранее о $spell:308631",
	WarnPlatSoon = "Предупреждение о перелете на следующую платформу",
	SpecWarnFeather = "Спец-предупреждение, когда $spell:308632 на вас",
	SpecWarnFeatherNear = "Спец-предупреждение, когда $spell:308632 около вас",
	YellOnFeather = "Кричать, когда $spell:308632 на вас",
	FeatherIcon = DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(308632),
	FeatherArrow = "Показывать стрелку, когда $spell:308632 около вас",
	WarnPhase2Soon = "Предупреждать заранее о переходе в фазу 2 (на ~7%)",
	WarnPhase2 = "Начало фазы 2 $spell:308649 ",
	WarnSupernova = "Предупреждение о ваших стаках $spell:308636",
	WarnFlamefal5 = "Предупреждение, что перья полетят через 5 секунд!!!",
	WarnFlamefal4 = "Предупреждение, что перья полетят через 4 секунды!!!",
	WarnFlamefal3 = "Предупреждение, что перья полетят через 3 секунды!!!",
	WarnFlamefal2 = "Предупреждение, что перья полетят через 2 секунды!!!",
	WarnFlamefal1 = "Предупреждение, что перья полетят через 1 секунду!!!",
	WarnFlamefal0 = "Предупреждение, что перья полетели!!!",
	WarnPhoenixScream2 = "Объявление в рейд, что крик будет через 2 секунды!!!",
	WarnPhoenixScream1 = "Объявление в рейд, что крик будет через 1 секунду!!!",
	WarnPhoenixScream0 = "Объявление в рейд, что крик прошёл!!!",
	WarnFireSign = "Объявить в рейд о касте знака огня"
}


L:SetMiscLocalization{
	YellFeather		= "Перо падает на меня!",
}

--Solarian
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "Верховный звездочет Солариан"
}

L:SetTimerLocalization{
	TimerNextRing = "Ослепление",
	TimerNextStar = "Звездное пламя",
	TimerNextHelp = "Вызов послушников",
	TimerNextGates = "Призыв врат бездны",
	TimerNextHeal = "Высшее исцеление",
	TimerAdds = "Вызов послушников",
	TimerPriests = "Вызов жрецов"
}

L:SetWarningLocalization{
	WarnAddsSoon = "Скоро вызов послушников"
}

L:SetOptionLocalization{
	WarnAddsSoon    = "Предупреждение о скором вызове послушников",
	TimerNextRing = "Отсчет времени до следующего $spell:308563 ",
	TimerNextStar = "Отсчет времени до следующего $spell:308565 ",
	TimerNextHelp = "Отсчет времени до следующего $spell:308559 ",
	TimerNextHeal = "Отсчет времени до следующего $spell:308561 ",
	TimerNextGates = "Отсчет времени до следующего $spell:308545 ",
	TimerAdds       = "Отсчет времени до следующих послушников",
	TimerPriests    = "Отсчет времени до следующих жрецов"
}

L:SetMiscLocalization{
	YellPull = "Тал ану-мен но син-дорай!",
	YellAdds = "Вы безнадежно слабы!",
	YellPriests = "Я навсегда избавлю вас от мании величия!",
	PriestH = "Жрец из зала Солориана",
	PriestN = "Жрец из Зала Звездочета",
	Provid = "Провидец из зала Солориана",
	BeaconIconSet = "{Череп}{Череп}{rt%d}Гнев на:{Череп}{Череп}{Череп}%s{Череп}{Череп}{Череп}",

}

--VoidReaver
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "Страж Бездны"
}

L:SetWarningLocalization{
	warnScope6 = "Можно взрывать через 5 секунд!!!",
	warnScope7 = "Можно взрывать через 3 секунды!!!",
	warnScope8 = "Можно взрывать через 2 секунды!!!",
	warnScope9 = "Можно взрывать через 1 секунду!!!",
	warnScope10 = "Можно взрывать Сейчас!!!",
	WarnScope = "{Череп}{Череп}{Череп}На %s {Череп}{Череп}{Череп} >%d< стаков{Череп}{Череп}{Череп}",
	SpawnOrbs = "ВНИМАНИЕ!!! СПАВН СФЕР!!!",
	Phase1 = "ВНИМАНИЕ!!! ФАЗА ПОНИЖЕННОГО УРОНА!!!",
	Phase2 = "ВНИМАНИЕ!!! ФАЗА ПОВЫШЕННОГО УРОНА!!!",
	Bah = "Можно взрывать сферу"
}

L:SetOptionLocalization{
	warnScope6 = "Предупреждать, что можно взрывать через 5 секунд!!!",
	warnScope7 = "Предупреждать, что можно взрывать через 3 секунды!!!",
	warnScope8 = "Предупреждать, что можно взрывать через 2 секунды!!!",
	warnScope9 = "Предупреждать, что можно взрывать через 1 секунду!!!",
	warnScope10 = "Предупреждать о разрешении взрывать сферы!!!",
	SpawnOrbs = "Предупреждать о спавне сфер",
	Phase1 = "Предупреждать о фазе с пониженным уроном",
	Phase2 = "Предупреждать о фазе с повышенным уроном",
	Bah = "Разрешение на взрыв сферы"
}

L:SetMiscLocalization{
	YellPull = "Внимание! Вы подлежите уничтожению!"
}

--KaelThas
L = DBM:GetModLocalization("KaelThas")

L:SetGeneralLocalization{
	name = "Кель'тас Солнечный Скиталец"
}

L:SetTimerLocalization{
	TimerNextAdd = "%s",
	TimerPhase3 = "Фаза 3",
	TimerPhase4 = "Фаза 4",
	TimerTalaTarget = "Преследование на %s",
	TimerGravity = "Падение"
}

L:SetWarningLocalization{
	WarnNextAdd = "%s на подходе",
	WarnPhase = "%s",
	WarnTalaTarget = "Таладред преследует %s",
	SpecWarnTalaTarget = "Вас преследует Таладред - бегите"
}

L:SetOptionLocalization{
	WarnNextAdd = "Объявление о скорой активации следующего помощника",
	TimerNextAdd = "Отсчет времени до следующего помощника",
	WarnPhase = "Анонс перехода на след. фазу",
	TimerPhase3 = "Отсчет времени до 3й фазы",
	TimerPhase4 = "Отсчет времени до 4й фазы",
	WarnTalaTarget = "Обьявлять цели преследуемые Таладредом",
	SpecWarnTalaTarget = "Спец. предупреждение для преследуемого Таладредом",
	TimerTalaTarget = "Отсчет времени до смены цели Таладреда",
	TimerGravity = "Отсчет времени до окончания $spell:35941",
	RemoveWeaponOnMindControl   = "Убирать оружие на МК.",
	SetIconOnMC = "Устанавливать иконки на цели заклинания $spell:36797"
}

L:SetMiscLocalization{
	YellPhase1 = "Энергия. Сила. Мои люди без них не могут... Эта зависимость возникла после уничтожения Солнечного Колодца. Добро пожаловать... в будущее. Мне очень жаль, но вы не сможете ничего изменить. Теперь меня никто не остановит! Селама ашаль-аноре!",
	YellSang   = "Вы справились с моими лучшими советниками... Но перед мощью Кровавого Молота не устоит никто. Узрите лорда Сангвинара!",
	YellCaper  = "Каперниан проследит, чтобы вы не задержались здесь надолго.",
	YellTelon  = "Неплохо, теперь вы можете потягаться с моим главным инженером Телоникусом.",
	YellPhase2 = "Как видите, оружия у меня предостаточно...",
	YellPhase3 = "Возможно, я недооценил вас. Было бы несправедливо заставлять вас драться с четырьмя советниками сразу, но... Мои люди тоже никогда не знали справедливости. Я лишь возвращаю долг.",
	YellPhase4 = "Увы, иногда приходится брать все в свои руки. Баламоре шаналь!",
	YellPhase5 = "Я не затем ступил на этот путь, чтобы остановиться на полдороги! Мои планы должны сбыться – и они сбудутся! Узрите же истинную мощь!",
	NamesAdds  = {["Thaladred"] = "Таладред", ["Lord Sanguinar"] = "Лорд Сангвинар", ["Capernian"] = "Каперниан", ["Telonicus"] = "Телоникус"},
	WarnPhase1 = "Фаза 1 - Таладред на подходе",
	WarnPhase2 = "Фаза 2 - Орудия на подходе",
	WarnPhase3 = "Фаза 3 - Приспешники на подходе",
	WarnPhase4 = "Фаза 4 - Кель'тас на подходе",
	WarnPhase5 = "Фаза 5",
	TalaTarget = "смотрит на |3%-3%([%w\128-\255]+%).",
	Axe = "Сокрушение"
}
