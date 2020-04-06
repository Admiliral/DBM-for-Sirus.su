if GetLocale() ~= "ruRU" then return end

local L

local spell				= "%s"
local debuff			= "%s: >%s<"
local spellCD			= "Восстановление %s"
local spellSoon			= "Скоро %s"
local optionWarning		= "Предупреждение для %s"
local optionPreWarning	= "Предупреждать заранее о %s"
local optionSpecWarning	= "Спец-предупреждение для %s"
local optionTimerCD		= "Отсчет времени до восстановления %s"
local optionTimerDur	= "Отсчет времени для %s"
local optionTimerCast	= "Отсчет времени применения заклинания %s"

----------------------------------
--  Auchenai Crypts             --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("ACTrash")

L:SetGeneralLocalization({
	name = "АГ треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

----------------------------------
--  Shirrak  --
-----------------------
L = DBM:GetModLocalization("Shirrak")

L:SetGeneralLocalization({
	name = "Ширрак Страж Мертвых"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	EmoteFire = " оказывается в зоне внимания |3-1(%s)."
})

----------------------------------
--  Exarh  --
-----------------------
L = DBM:GetModLocalization("Exarh")

L:SetGeneralLocalization({
	name = "Экзарх Маладаар"
})

L:SetWarningLocalization({
	WarnSoul = "Украденная душа на %s"
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	WarnSoul = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.target:format(32346, GetSpellInfo(32346))
})

L:SetMiscLocalization({
})

----------------------------------
--  Hellfire Ramparts           --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("HRTrash")

L:SetGeneralLocalization({
	name = "Бастионы треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	Dogs = "Призыв бойцовских псов"
})

L:SetOptionLocalization({
	Dogs = "Отсчет времени до призыва бойцовских псов"
})

L:SetMiscLocalization({
	yellDogs = "Незваные гости! Задержите их, а я спущу бойцовых псов!"
})

----------------------------------
--  Watchkeeper  --
-----------------------
L = DBM:GetModLocalization("Watchkeeper")

L:SetGeneralLocalization({
	name = "Начальник стражи Гарголмар"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	TimerWound = "Смертельная рана %s"
})

L:SetOptionLocalization({
	TimerWound = DBM_CORE_AUTO_TIMER_OPTIONS.target:format(36814, GetSpellInfo(36814))
})

L:SetMiscLocalization({
})

----------------------------------
--  Omor  --
-----------------------
L = DBM:GetModLocalization("Omor")

L:SetGeneralLocalization({
	name = "Омор Неодолимый"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Vazruden  --
-----------------------
L = DBM:GetModLocalization("Vazruden")

L:SetGeneralLocalization({
	name = "Вазруден Глашатай"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	EmoteNazan = "Назан спускается с небес."
})

----------------------------------
--  The Slave Pens           --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("SPTrash")

L:SetGeneralLocalization({
	name = "Узилище треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Mennu  --
-----------------------
L = DBM:GetModLocalization("Mennu")

L:SetGeneralLocalization({
	name = "Менну Предатель"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Rokmar  --
-----------------------
L = DBM:GetModLocalization("Rokmar")

L:SetGeneralLocalization({
	name = "Рокмар Трескун"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Quagmirran  --
-----------------------
L = DBM:GetModLocalization("Quagmirran")

L:SetGeneralLocalization({
	name = "Зыбун"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  TheBloodFurnace           --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("BFTrash")

L:SetGeneralLocalization({
	name = "Кузня крови треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  TheMaker  --
-----------------------
L = DBM:GetModLocalization("TheMaker")

L:SetGeneralLocalization({
	name = "Мастер"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yellPull = "Не мешайте мне работать!"
})

----------------------------------
--  Broggok  --
-----------------------
L = DBM:GetModLocalization("Broggok")

L:SetGeneralLocalization({
	name = "Броггок"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yellPull = "Заходите, незваные гости..."
})

----------------------------------
--  Keli'dan  --
-----------------------
L = DBM:GetModLocalization("Kelidan")

L:SetGeneralLocalization({
	name = "Кели'дан Разрушитель"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	Explosion = "Взрыв!"
})

L:SetOptionLocalization({
	Explosion = DBM_CORE_AUTO_TIMER_OPTIONS.cast:format(37371, GetSpellInfo(37371))
})

L:SetMiscLocalization({
})

----------------------------------
--  Mana Tombs           --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("MTTrash")

L:SetGeneralLocalization({
	name = "Гробницы маны треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Pandemonius  --
-----------------------
L = DBM:GetModLocalization("Pandemonius")

L:SetGeneralLocalization({
	name = "Пандемоний"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Tavarok  --
-----------------------
L = DBM:GetModLocalization("Tavarok")

L:SetGeneralLocalization({
	name = "Таварок"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Yor  --
-----------------------
L = DBM:GetModLocalization("Yor")

L:SetGeneralLocalization({
	name = "Йор"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Nexus-Prince Shaffar  --
-----------------------
L = DBM:GetModLocalization("Shaffar")

L:SetGeneralLocalization({
	name = "Принц Шаффар"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	TimerEtherealOrb = "Следующий маяк",
	TimerEtherealSpawn = "Вызов ученика"
})

L:SetOptionLocalization({
	TimerEtherealOrb = "Отсчет времени до вызова следующего эфирального маяка",
	TimerEtherealSpawn = "Отсчет времени до вызова эфирального ученика"
})

L:SetMiscLocalization({
})

----------------------------------
--  Sethekk Halls           --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("SHTrash")

L:SetGeneralLocalization({
	name = "Сетеккские залы треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Syth  --
-----------------------
L = DBM:GetModLocalization("Syth")

L:SetGeneralLocalization({
	name = "Темнопряд Сит"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
	yellSummon = "У меня свои звер-ррр-рюшки есть!"
})

----------------------------------
--  Ikiss  --
-----------------------
L = DBM:GetModLocalization("Ikiss")

L:SetGeneralLocalization({
	name = "Король воронов Айкисс"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
	Explosion = "Взрыв!"
})

L:SetOptionLocalization({
	Explosion = "Отсчет времени до взрыва"
})

L:SetMiscLocalization({
})

----------------------------------
--  Underbog           --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("UTrash")

L:SetGeneralLocalization({
	name = "Нижетопь треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Hungarfen  --
-----------------------
L = DBM:GetModLocalization("Hungarfen")

L:SetGeneralLocalization({
	name = "Топеглад"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Ghazan  --
-----------------------
L = DBM:GetModLocalization("Ghazan")

L:SetGeneralLocalization({
	name = "Газ'ан"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Muselek  --
-----------------------
L = DBM:GetModLocalization("Muselek")

L:SetGeneralLocalization({
	name = "Владыка болот Мусел'ек"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  BlackStalker  --
-----------------------
L = DBM:GetModLocalization("BlackStalker")

L:SetGeneralLocalization({
	name = "Черная Охотница"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Arcatraz          --
----------------------------------
--  Thrash  --
-----------------------
L = DBM:GetModLocalization("ArTrash")

L:SetGeneralLocalization({
	name = "Аркатрац треш"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Zereketh  --
-----------------------
L = DBM:GetModLocalization("Zereketh")

L:SetGeneralLocalization({
	name = "Зерекет Бездонный"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Dalliah  --
-----------------------
L = DBM:GetModLocalization("Dalliah")

L:SetGeneralLocalization({
	name = "Даллия Глашатай Судьбы"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Soccothrates  --
-----------------------
L = DBM:GetModLocalization("Soccothrates")

L:SetGeneralLocalization({
	name = "Провидец Гнева Соккорат"
})

L:SetWarningLocalization({
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
})

L:SetMiscLocalization({
})

----------------------------------
--  Skyriss  --
-----------------------
L = DBM:GetModLocalization("Skyriss")

L:SetGeneralLocalization({
	name = "Предвестник Скайрисс"
})

L:SetWarningLocalization({
	WarnSplitSoon = "Скоро раздвоение",
	WarnSplit     = "Раздвоение"
})

L:SetTimerLocalization({
})

L:SetOptionLocalization({
	WarnSplitSoon = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.soon:format(39019, GetSpellInfo(39019)),
	WarnSplit     = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(39019, GetSpellInfo(39019))
})

L:SetMiscLocalization({
	Split	= "We span the universe, as countless as the stars!"
})
