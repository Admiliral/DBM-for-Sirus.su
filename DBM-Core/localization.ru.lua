if GetLocale() ~= "ruRU" then return end

DBM_CORE_UPDATEREMINDER_URL			= "https://forum.sirus.su/threads/dbm-dlja-sirusa.89486"

DBM_COPY_URL_DIALOG					= "Копировать ссылку"

DBM_CORE_NEED_SUPPORT				= "Вы - программист или хороший переводчик? Команда разработчиков DBM нуждается в вашей помощи. Присоединяйтесь к нам -  зайдите или отправьте сообщение на tandanu@deadlybossmods.com или nitram@deadlybossmods.com."

DBM_CORE_LOAD_MOD_ERROR				= "Ошибка при загрузке DBM для %s: %s"
DBM_CORE_LOAD_MOD_SUCCESS			= "Загружен DBM для \"%s\", введите /dbm для вызова настроек!"
DBM_CORE_LOAD_GUI_ERROR				= "Не удалось загрузить GUI: %s"

DBM_CORE_COMBAT_STARTED				= "%s вступает в бой. Удачи! :)"
DBM_CORE_COMBAT_STARTED_IN_PROGRESS	= "%s вступает в бой (в процессе). Удачи! :)"
DBM_CORE_GUILD_COMBAT_STARTED		= "Гильдия вступает в бой с %s"
DBM_CORE_BOSS_DOWN					= "%s погибает спустя %s!"
DBM_CORE_BOSS_DOWN_I				= "%s погибает! Общее количество побед у Вас %d."
DBM_CORE_BOSS_DOWN_L				= "%s погибает спустя %s! Ваш последний бой длился %s, а лучший бой длился %s. Общее количество побед у Вас %d."
DBM_CORE_BOSS_DOWN_NR				= "%s погибает спустя %s! Это новый рекорд! (Предыдущий рекорд был %s). Общее количество побед у Вас %d."
DBM_CORE_GUILD_BOSS_DOWN			= "Гильдия победила %s спустя %s!"
DBM_CORE_COMBAT_ENDED_AT			= "Бой с %s (%s) закончился спустя %s."
DBM_CORE_COMBAT_ENDED_AT_LONG		= "Бой с %s (%s) закончился спустя %s. На этом уровне сложности вы вайпнулись уже %d раз."
DBM_CORE_GUILD_COMBAT_ENDED_AT		= "Гильдия вайпнулась на %s (%s) спустя %s."

DBM_CORE_TIMER_FORMAT_SECS			= "%d сек"
DBM_CORE_TIMER_FORMAT_MINS			= "%d мин"
DBM_CORE_TIMER_FORMAT				= "%d мин %d сек"

DBM_CORE_MIN						= "мин"
DBM_CORE_MIN_FMT					= "%d мин"
DBM_CORE_SEC						= "сек"
DBM_CORE_SEC_FMT					= "%d сек"
DBM_CORE_DEAD						= "мертв"
DBM_CORE_OK							= "ОК"

DBM_CORE_GENERIC_WARNING_BERSERK	= "Берсерк через %s %s"
DBM_CORE_GENERIC_TIMER_BERSERK		= "Берсерк"
DBM_CORE_OPTION_TIMER_BERSERK		= "Отсчет времени до $spell:26662"
DBM_CORE_OPTION_HEALTH_FRAME		= "Отображать здоровье босса"

DBM_CORE_OPTION_CATEGORY_TIMERS			= "Индикаторы"
--Sub cats for "announce" object
DBM_CORE_OPTION_CATEGORY_WARNINGS		= "Общие предупреждения"
DBM_CORE_OPTION_CATEGORY_WARNINGS_YOU	= "Персональные предупреждения"
DBM_CORE_OPTION_CATEGORY_WARNINGS_OTHER	= "Предупреждения для цели"
DBM_CORE_OPTION_CATEGORY_WARNINGS_ROLE	= "Предупреждения для роли"

DBM_CORE_OPTION_CATEGORY_SOUNDS			= "Звуки"
--Misc object broken down into sub cats
DBM_CORE_OPTION_CATEGORY_DROPDOWNS		= "Dropdowns"--Still put in MISC sub grooup, just used for line separators since multiple of these on a fight (or even having on of these at all) is rare.
DBM_CORE_OPTION_CATEGORY_YELLS			= "Крики"
DBM_CORE_OPTION_CATEGORY_ICONS			= "Метки"

DBM_CORE_AUTO_RESPONDED						= "Авто-ответ."
DBM_CORE_STATUS_WHISPER						= "%s: %s, %d/%d человек живые"
DBM_CORE_AUTO_RESPOND_WHISPER				= "%s сейчас занят, в бою против %s (%s, %d/%d человек живые)"
DBM_CORE_WHISPER_COMBAT_END_KILL			= "%s одержал победу над %s!"
DBM_CORE_WHISPER_COMBAT_END_KILL_STATS		= "%s одержал победу над %s! Общее количество побед у них - %d."
DBM_CORE_WHISPER_COMBAT_END_WIPE_AT			= "%s потерпел поражение от %s на %s"
DBM_CORE_WHISPER_COMBAT_END_WIPE_STATS_AT	= "%s потерпел поражение от %s на %s. Общее количество вайпов у них - %d."

DBM_CORE_VERSIONCHECK_HEADER		= "Boss Mod - Версии"
DBM_CORE_VERSIONCHECK_ENTRY			= "%s: %s (%s)"
DBM_CORE_VERSIONCHECK_ENTRY_TWO		= "%s: %s (%s) & %s (%s)"--Two Boss mods
DBM_CORE_VERSIONCHECK_ENTRY_NO_DBM	= "%s: Boss Mod не установлен"
DBM_CORE_VERSIONCHECK_FOOTER		= "Найдено %d |4игрок:игрока:игроков; с DBM"
DBM_CORE_VERSIONCHECK_OUTDATED		= "Следующие %d игрок(и) имеют устаревшую версию: %s"
DBM_CORE_YOUR_VERSION_OUTDATED      = "Ваша версия Deadly Boss Mods устарела! Пожалуйста, посетите " .. DBM_CORE_UPDATEREMINDER_URL .. " для загрузки последней версии."
DBM_CORE_VOICE_PACK_OUTDATED		= "В вашем голосовом пакете DBM отсутствуют звуки, поддерживаемые этой версией DBM. Фильтр звуков спец-предупреждений был отключен. Пожалуйста скачайте обновленную версию голосового пакета или свяжитесь с автором для обновления, которое содержит отсутствующие звуковые файлы."
DBM_CORE_VOICE_MISSING				= "Выбранный вами голосовой пакет DBM не найден. Ваш выбор был сброшен на 'None'. Если это ошибка, убедитесь что ваш голосовой пакет правильно установлен и включен в модификациях."
DBM_CORE_VOICE_DISABLED				= "У вас установлен по крайней мере один голосовой пакет DBM, но ни один не включен. Если вы собираетесь использовать голосовой пакет, убедитесь что он выбран в 'Spoken Alerts', иначе удалите неиспользуемые голосовые пакеты чтобы скрыть это сообщение"
DBM_CORE_VOICE_COUNT_MISSING		= "Голос отсчета %d использует голововой пакет, который не был найден. Он был сброшен на настройки по умолчанию."

DBM_CORE_UPDATEREMINDER_HEADER		= "Ваша версия Deadly Boss Mods устарела.\n Версия %s (r%d) доступна для загрузки здесь:"
DBM_CORE_UPDATEREMINDER_FOOTER			= "Нажмите " .. (IsMacClient() and "Cmd-C" or "Ctrl-C")  ..  ", чтобы скопировать ссылку загрузки в буфер обмена."
DBM_CORE_UPDATEREMINDER_FOOTER_GENERIC	= "Нажмите " .. (IsMacClient() and "Cmd-C" or "Ctrl-C")  ..  ", чтобы скопировать ссылку в буфер обмена."
DBM_CORE_UPDATEREMINDER_NOTAGAIN	= "Всплывающее сообщение при наличии новой версии"

DBM_CORE_MOVABLE_BAR				= "Перетащите!"

DBM_PIZZA_SYNC_INFO					= "|Hplayer:%1$s|h[%1$s]|h транслирует DBM Timer: '%2$s'\n|HDBM:cancel:%2$s:nil|h|cff3588ff[Отменить этот DBM Timer]|r|h  |HDBM:ignore:%2$s:%1$s|h|cff3588ff[Игнорировать DBM Timer от %1$s]|r|h"
DBM_PIZZA_CONFIRM_IGNORE			= "Вы действительно хотите проигнорировать DBM Timer данного сеанса от %s?"
DBM_PIZZA_ERROR_USAGE				= "Использование: /dbm [broadcast] timer <time> <text>"

DBM_CORE_ERROR_DBMV3_LOADED			= "Deadly Boss Mods запущен дважды, поскольку установлены DBMv3 и DBMv4 и включены!\nНажмите кнопку \"ОК\" для отключения DBMv3 и перезагрузки интерфейса.\nНаведите порядок в вашей папке AddOns, удалите старые папки DBMv3."

DBM_CORE_MINIMAP_TOOLTIP_HEADER		= "Deadly Boss Mods"
DBM_CORE_MINIMAP_TOOLTIP_FOOTER		= "Shift+щелчок или щелкните правой кнопкой мыши, чтобы переместить"

DBM_CORE_RANGECHECK_HEADER			= "Проверка дистанции (%d м)"
DBM_CORE_RANGECHECK_SETRANGE		= "Настройка дистанции"
DBM_CORE_RANGECHECK_SOUNDS			= "Звуки"
DBM_CORE_RANGECHECK_SOUND_OPTION_1	= "Звуковой сигнал, когда игрок находится в диапазоне"
DBM_CORE_RANGECHECK_SOUND_OPTION_2	= "Звуковой сигнал для всех остальных игроков в диапазоне"
DBM_CORE_RANGECHECK_SOUND_0			= "Без звука"
DBM_CORE_RANGECHECK_SOUND_1			= "По умолчанию"
DBM_CORE_RANGECHECK_SOUND_2			= "Раздражающий звуковой сигнал"
DBM_CORE_RANGECHECK_HIDE			= "Скрыть"
DBM_CORE_RANGECHECK_SETRANGE_TO		= "%d м"
DBM_CORE_RANGECHECK_LOCK			= "Закрепить полосу"
DBM_CORE_RANGECHECK_OPTION_FRAMES	= "Окна"
DBM_CORE_RANGECHECK_OPTION_RADAR	= "Отображать только радар"
DBM_CORE_RANGECHECK_OPTION_TEXT		= "Отображать только текствое окно"
DBM_CORE_RANGECHECK_OPTION_BOTH		= "Отображать оба варианта"
DBM_CORE_RANGERADAR_HEADER			= "Радар (%d метров)"

DBM_LFG_INVITE						= "Приглашение в подземелье"
DBM_LFG_CD                          = "Восстановление ПП"

DBM_CORE_SLASHCMD_HELP				= {
	"Доступные (/) команды:",
	"/dbm version: выполнение проверки используемой рейдом версии (псевдоним: ver)",
	"/dbm unlock: отображение перемещаемой строки состояния таймера (псевдоним: move)",
	"/dbm timer <x> <text>: начинает отсчет <x> сек. Pizza Timer с именем <text>",
	"/dbm broadcast timer <x> <text>: транслирует <x> сек. Pizza Timer с именем <text> в рейд (требуются права лидера или помощника)",
	"/dbm break <min>: начинает отсчет отдыха на <min> мин., транслирует отсчет отдыха всем членам рейда с DBM (требуются права лидера или помощника).",
	"/dbm help: вывод этой справки",
}

DBM_ERROR_NO_PERMISSION				= "У вас недостаточно прав, для выполнение этой операции."

DBM_CORE_BOSSHEALTH_HIDE_FRAME		= "Скрыть"

DBM_CORE_ALLIANCE					= "Альянс"
DBM_CORE_HORDE						= "Орда"

DBM_CORE_UNKNOWN					= "неизвестно"

DBM_CORE_BREAK_START				= "Перерыв начинается -- у вас есть %s мин.!"
DBM_CORE_BREAK_MIN					= "Перерыв заканчивается через %s мин.!"
DBM_CORE_BREAK_SEC					= "Перерыв заканчивается через %s сек.!"
DBM_CORE_TIMER_BREAK				= "Перерыв!"
DBM_CORE_ANNOUNCE_BREAK_OVER		= "Перерыв закончился"

DBM_CORE_TIMER_PULL					= "Атака"
DBM_CORE_ANNOUNCE_PULL				= "Атака через %d сек."
DBM_CORE_ANNOUNCE_PULL_NOW			= "Атака!"

DBM_CORE_ACHIEVEMENT_TIMER_SPEED_KILL = "Быстрое убийство"

-- Auto-generated Timer Localizations
DBM_CORE_AUTO_TIMER_TEXTS = {
	target = "%s: %%s",
	cast = "%s",
	active = "%s",
	cd = "%s",
	next = "След. %s",
	achievement = "%s",
}

DBM_CORE_AUTO_TIMER_OPTIONS = {
	target = "Отсчет времени действия эффекта |cff71d5ff|Hspell:%d|h%s|h|r",
	cast = "Отсчет времени применения заклинания |cff71d5ff|Hspell:%d|h%s|h|r",
	active = "Отсчет времени действия |cff71d5ff|Hspell:%d|h%s|h|r",
	cd = "Отсчет времени до восстановления |cff71d5ff|Hspell:%d|h%s|h|r",
	next = "Отсчет времени до следующего |cff71d5ff|Hspell:%d|h%s|h|r",
	achievement = "Отсчет времени для %s",
}

-- Auto-generated Warning Localizations
DBM_CORE_AUTO_ANNOUNCE_TEXTS = {
	target = "%s на |3-5(>%%s<)",
	spell = "%s",
	cast = "Применение заклинания %s: %.1f сек",
	soon = "Скоро %s",
	prewarn = "%s через %s",
	phase = "Фаза %d",
	stack = "%s на |3-5(>%%s<) (%%d)"
}

local prewarnOption = "Предупреждать заранее о |cff71d5ff|Hspell:%d|h%s|h|r"
DBM_CORE_AUTO_ANNOUNCE_OPTIONS = {
	target = "Объявлять цели заклинания |cff71d5ff|Hspell:%d|h%s|h|r",
	spell = "Предупреждение для |cff71d5ff|Hspell:%d|h%s|h|r",
	cast = "Предупреждать о применении заклинания |cff71d5ff|Hspell:%d|h%s|h|r",
	soon = prewarnOption,
	info = " Информация о спеле |cff71d5ff|Hspell:%d|h%s|h|r",
	prewarn = prewarnOption,
	phase = "Объявлять фазу %d",
	stack = "Объявлять количество стаков $spell:%s"
}


-- Auto-generated Special Warning Localizations
DBM_CORE_AUTO_SPEC_WARN_OPTIONS = {
	spell 		= "Спец-предупреждение для $spell:%d",
	dispel 		= "Спец-предупреждение для рассеивания/похищения заклинания \n$spell:%d",
	interupt	= "Спец-предупреждение для прерывания заклинания \n$spell:%d",
	you 		= "Спец-предупреждение, когда на вас $spell:%d",
	target 		= "Спец-предупреждение, когда на ком-то $spell:%d",
	close 		= "Спец-предупреждение, когда на ком-то рядом с вами \n$spell:%d",
	move 		= "Спец-предупреждение для $spell:%d",
	run 		= "Спец-предупреждение для $spell:%d",
	cast 		= "Спец-предупреждение о применении заклинания \n$spell:%d",
	stack 		= "Спец-предупреждение для >=%d стаков $spell:%d",
	switch		= "Показать специальное предупреждение для переключения целей для \n $spell:%s"
}

DBM_CORE_AUTO_SPEC_WARN_TEXTS = {
	spell = "%s!",
	dispel = "%s на |3-5(%%s) - рассейте заклинание",
	interupt = "%s - прерывание",
	you = "%s на вас",
	target = "%s на |3-5(%%s)",
	close = "%s на |3-5(%%s) около вас",
	move = "%s - отбегите",
	run = "%s - бегите",
	cast = "%s - прекратите чтение заклинаний",
	stack = "%s (%%d)",
	switch = "%s - переключитесь"
}


DBM_CORE_AUTO_ICONS_OPTION_TEXT		= "Устанавливать метки на цели заклинания $spell:%d"
DBM_CORE_AUTO_SOUND_OPTION_TEXT		= "Звуковой сигнал при $spell:%d"


-- New special warnings
DBM_CORE_MOVE_SPECIAL_WARNING_BAR	= "Индикатор спец-предупреждения"
DBM_CORE_MOVE_SPECIAL_WARNING_TEXT	= "Специальное предупреждение"


DBM_CORE_RANGE_CHECK_ZONE_UNSUPPORTED	= "Проверка дистанции %d м. недоступна в этой зоне.\nДоступные дистанции - 10, 11, 15 и 28 м."

DBM_ARROW_MOVABLE					= "Стрелку можно перемещать"
DBM_ARROW_NO_RAIDGROUP				= "Данная функция работает только в рейд-группах и внутри рейдовых подземелий."
DBM_ARROW_ERROR_USAGE	= {
	"Использование DBM-Arrow:",
	"/dbm arrow <x> <y>: создает стрелку, указывающую в определенную точку (0 < x/y < 100)",
	"/dbm arrow <player>: создает стрелку, указывающую на определенного игрока в вашей группе или рейде",
	"/dbm arrow hide: скрывает стрелку",
	"/dbm arrow move: разрешает перемещение стрелки",
}

--LDB
DBM_LDB_TOOLTIP_HELP1	= "Левый клик чтобы открыть DBM"
