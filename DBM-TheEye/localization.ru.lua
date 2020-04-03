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
    WarnPlatSoon = "Скоро следующая платформа"
}

L:SetOptionLocalization{
    TimerNextPlat = "Отсчет времени до перелета на следующую платформу",
    WarnPlatSoon = "Предупреждение о перелете на следующую платформу"
}

--Solarian
L = DBM:GetModLocalization("Solarian")

L:SetGeneralLocalization{
	name = "Верховный звездочет Солариан"
}

L:SetTimerLocalization{
    TimerAdds = "Вызов послушников",
    TimerPriests = "Вызов жрецов"
}

L:SetWarningLocalization{
    WarnAddsSoon = "Скоро вызов послушников"
}

L:SetOptionLocalization{
    WarnAddsSoon    = "Предупреждение о скором вызове послушников",
    TimerAdds       = "Отсчет времени до следующих послушников",
    TimerPriests    = "Отсчет времени до следующих жрецов"
}

L:SetMiscLocalization{
    YellPull = "Тал ану-мен но син-дорай!",
    YellAdds = "Вы безнадежно слабы!",
    YellPriests = "Я навсегда избавлю вас от мании величия!",
    Priest = "Жрец из Зала Звездочета"
}

--VoidReaver
L = DBM:GetModLocalization("VoidReaver")

L:SetGeneralLocalization{
	name = "Страж Бездны"
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
