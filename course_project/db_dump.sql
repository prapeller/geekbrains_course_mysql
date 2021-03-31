-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Окт 19 2020 г., 17:27
-- Версия сервера: 5.7.27-30
-- Версия PHP: 7.1.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `u1095735_default`
--

-- --------------------------------------------------------

--
-- Структура таблицы `admins`
--

CREATE TABLE `admins` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(32) NOT NULL,
  `status` enum('admin','manager') NOT NULL DEFAULT 'manager'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `admins`
--

INSERT INTO `admins` (`id`, `username`, `password`, `status`) VALUES
(1, 'admin', '2b16b2b6c390d832b929e622d29c7709', 'admin');

-- --------------------------------------------------------

--
-- Структура таблицы `cources`
--

CREATE TABLE `cources` (
  `id` int(10) UNSIGNED NOT NULL,
  `language_id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Список курсов';

--
-- Дамп данных таблицы `cources`
--

INSERT INTO `cources` (`id`, `language_id`, `name`) VALUES
(1, 1, 'course1'),
(2, 1, 'course2');

-- --------------------------------------------------------

--
-- Структура таблицы `grammatics`
--

CREATE TABLE `grammatics` (
  `id` int(10) UNSIGNED NOT NULL,
  `language_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `explanation` text NOT NULL,
  `pinyin` text NOT NULL,
  `hieroglyph` text NOT NULL,
  `translate` varchar(250) NOT NULL,
  `literal` varchar(250) NOT NULL,
  `structure` text NOT NULL,
  `json_cources` json NOT NULL,
  `json_topics` json NOT NULL,
  `json_lessons` json NOT NULL,
  `json_tasks` json NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `grammatics`
--

INSERT INTO `grammatics` (`id`, `language_id`, `name`, `explanation`, `pinyin`, `hieroglyph`, `translate`, `literal`, `structure`, `json_cources`, `json_topics`, `json_lessons`, `json_tasks`) VALUES
(1, 1, 'Личные местоимения', '<p><span style=\\\"color: rgb(0, 0, 0);\\\">Личные местоимения не склоняются:</span></p><p><span style=\\\"color: rgb(0, 0, 0);\\\">我 (wǒ) я = мне</span></p><p><span style=\\\"color: rgb(0, 0, 0);\\\">你 (nǐ) ты = тебе</span></p><p><span style=\\\"color: rgb(0, 0, 0);\\\">他 (tā) он = ему</span></p><p><span style=\\\"color: rgb(0, 0, 0);\\\">她 (tā) она = ей</span></p>', 'wǒ shì zhāng wēi', '我是张伟。', 'Я - Чжан Вэй.', 'я есть Чжан Вэй', '<p><span style=\\\"color: rgb(0, 0, 0);\\\">Я = мне / ты = тебе / он = ему / она = ей</span></p>', '[]', '[]', '[]', '[]'),
(2, 1, '\"Быть, являться\" с помощью 是 (shì)', '<p>是 (shì) - аналог \"быть, являться\" в английском языке.</p>', 'nǐ shì zhāng wěi', '你是张伟。', 'Ты - Чжан Вэй.', 'ты есть Чжан Вэй', '<p>Кто/что + 是 + Кто/что2</p>', '[]', '[]', '[]', '[]');

-- --------------------------------------------------------

--
-- Структура таблицы `hieroglyphs`
--

CREATE TABLE `hieroglyphs` (
  `id` int(10) UNSIGNED NOT NULL,
  `language_id` int(10) UNSIGNED NOT NULL,
  `pinyin` varchar(250) NOT NULL,
  `hieroglyph` varchar(250) NOT NULL,
  `translate` varchar(250) NOT NULL,
  `json_cources` json NOT NULL,
  `json_topics` json NOT NULL,
  `json_lessons` json NOT NULL,
  `json_tasks` json NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `hieroglyphs`
--

INSERT INTO `hieroglyphs` (`id`, `language_id`, `pinyin`, `hieroglyph`, `translate`, `json_cources`, `json_topics`, `json_lessons`, `json_tasks`) VALUES
(1, 1, 'hǎo', '好', 'хорошо; добро; отлично', '[]', '[]', '[]', '[]');

-- --------------------------------------------------------

--
-- Структура таблицы `languages`
--

CREATE TABLE `languages` (
  `id` smallint(5) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Список языков с которыми работает система';

--
-- Дамп данных таблицы `languages`
--

INSERT INTO `languages` (`id`, `name`) VALUES
(1, 'русский');

-- --------------------------------------------------------

--
-- Структура таблицы `lessons`
--

CREATE TABLE `lessons` (
  `id` int(10) UNSIGNED NOT NULL,
  `topic_id` int(10) UNSIGNED NOT NULL,
  `sort` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `lessons`
--

INSERT INTO `lessons` (`id`, `topic_id`, `sort`) VALUES
(1, 1, 0),
(3, 2, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `tasks`
--

CREATE TABLE `tasks` (
  `id` int(10) UNSIGNED NOT NULL,
  `lesson_id` int(10) UNSIGNED NOT NULL,
  `type` set('word_image','word_char_from_lang','word_lang_from_char','word_char_from_video','word_match','sent_image','sent_char_from_lang','sent_lang_from_char','sent_lang_from_video','sent_say_from_char','sent_say_from_video','sent_paste_from_char','sent_choose_from_char','sent_delete_from_char') NOT NULL,
  `task_data` json NOT NULL,
  `sort` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `tasks`
--

INSERT INTO `tasks` (`id`, `lesson_id`, `type`, `task_data`, `sort`) VALUES
(1, 3, 'word_image', '{\"answer\": 1, \"variants\": [3, 1, 2, 4]}', 0),
(2, 3, 'word_char_from_lang', '{\"answer\": 0, \"variants\": [3, 1, 2, 4]}', 1),
(3, 3, 'word_lang_from_char', '{\"answer\": 0, \"variants\": [4, 2, 1, 3]}', 2),
(5, 3, 'word_char_from_video', '{\"answer\": 0, \"variants\": [1, 3, 4, 2]}', 3),
(8, 3, 'word_match', '[5, 4, 2, 1, 3]', 4),
(11, 3, 'sent_image', '[1, 10, 2, 14, 12, 13]', 5),
(13, 3, 'sent_char_from_lang', '[1, 2, 18, 13]', 6),
(14, 3, 'sent_lang_from_char', '[19, 20, 21, 13]', 7),
(15, 3, 'sent_lang_from_video', '[3, 5, 18, 13]', 8),
(16, 3, 'sent_say_from_char', '[1, 22, 1, 2, 18, 13]', 9),
(17, 3, 'sent_say_from_video', '[20, 23, 24, 25, 26, 21, 13]', 10),
(18, 3, 'sent_paste_from_char', '[1, 7, 27, 8, 28, 13]', 11),
(19, 3, 'sent_choose_from_char', '[32, 31, 25, 1, 29, 30, 31, 26, 25, 21, 13]', 12),
(20, 3, 'sent_delete_from_char', '[34, 35, 36, 1, 16]', 13);

-- --------------------------------------------------------

--
-- Структура таблицы `topics`
--

CREATE TABLE `topics` (
  `id` int(10) UNSIGNED NOT NULL,
  `cource_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Топики курсов';

--
-- Дамп данных таблицы `topics`
--

INSERT INTO `topics` (`id`, `cource_id`, `name`) VALUES
(1, 0, 'Привет'),
(2, 1, 'Привет');

-- --------------------------------------------------------

--
-- Структура таблицы `words`
--

CREATE TABLE `words` (
  `id` int(10) UNSIGNED NOT NULL,
  `language_id` int(10) UNSIGNED NOT NULL,
  `pinyin` varchar(250) NOT NULL,
  `hieroglyph` varchar(250) NOT NULL,
  `translate` varchar(250) NOT NULL,
  `literal` varchar(250) NOT NULL,
  `json_cources` json NOT NULL,
  `json_topics` json NOT NULL,
  `json_lessons` json NOT NULL,
  `json_tasks` json NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `words`
--

INSERT INTO `words` (`id`, `language_id`, `pinyin`, `hieroglyph`, `translate`, `literal`, `json_cources`, `json_topics`, `json_lessons`, `json_tasks`) VALUES
(1, 1, 'nǐhǎo', '你好', 'привет', 'тебе добро', '[]', '[]', '[]', '[]'),
(2, 1, 'zàijiàn', '再见', 'пока; увидимся', 'снова увидеться', '[]', '[]', '[]', '[]'),
(3, 1, 'nǐ', '你', 'ты', '', '[]', '[]', '[]', '[]'),
(4, 1, 'wǒ', '我', 'я', '', '[]', '[]', '[]', '[]'),
(5, 1, 'shì', '是', 'быть; являться', '', '[]', '[]', '[]', '[]'),
(6, 1, 'tā', '他', 'он', '', '[]', '[]', '[]', '[]'),
(7, 1, 'men', '们', 'маркер множественного числа (людей)', '', '[]', '[]', '[]', '[]'),
(8, 1, 'shuō', '说', 'говорить', '', '[]', '[]', '[]', '[]'),
(9, 1, 'éyǔ', '俄语', 'русский язык', '', '[]', '[]', '[]', '[]'),
(10, 1, 'bù', '不', 'не', '', '[]', '[]', '[]', '[]'),
(11, 1, 'zhōngguó', '中国', 'Китай', 'срединная страна ', '[]', '[]', '[]', '[]'),
(12, 1, 'rén', '人', 'человек', '', '[]', '[]', '[]', '[]'),
(13, 1, '', '。', '.', '', '[]', '[]', '[]', '[]'),
(14, 1, 'éguó', '俄国', 'Россия', 'русская страна', '[]', '[]', '[]', '[]'),
(15, 1, 'ma', '吗', 'вопросительная частица для вопросов \"да\\нет\"', '', '[]', '[]', '[]', '[]'),
(16, 1, '', '？', '?', '', '[]', '[]', '[]', '[]'),
(18, 1, 'zhāng wěi', '张伟', 'Чжан Вэй', '', '[]', '[]', '[]', '[]'),
(19, 1, 'píngguǒ', '苹果', 'яблоко', 'яблоко фрукт', '[]', '[]', '[]', '[]'),
(20, 1, 'yī', '一', 'один', '', '[]', '[]', '[]', '[]'),
(21, 1, 'kuài', '块', 'блок, кусок', '', '[]', '[]', '[]', '[]'),
(22, 1, '', '，', ',', '', '[]', '[]', '[]', '[]'),
(23, 1, 'gè', '个', 'счетное слово для большинства предметов', '', '[]', '[]', '[]', '[]'),
(24, 1, 'miànbāo', '面包', 'хлеб', 'мучная упаковочка', '[]', '[]', '[]', '[]'),
(25, 1, 'shí', '十', 'десять', '', '[]', '[]', '[]', '[]'),
(26, 1, 'wǔ', '五', 'пять', '', '[]', '[]', '[]', '[]'),
(27, 1, 'dōu', '都', 'все; всё; оба', '', '[]', '[]', '[]', '[]'),
(28, 1, 'hànyǔ', '汉语', 'китайский язык', '', '[]', '[]', '[]', '[]'),
(29, 1, 'bōluó', '菠萝', 'ананас', 'шпинат редька', '[]', '[]', '[]', '[]'),
(30, 1, 'sān', '三', 'три', '', '[]', '[]', '[]', '[]'),
(31, 1, 'bǎi', '百', 'сотня', '', '[]', '[]', '[]', '[]'),
(32, 1, 'píng', '瓶', '(счетное слово) бутылка', '', '[]', '[]', '[]', '[]'),
(33, 1, 'bēi', '杯', '(счетное слово) чашка; стакан', '', '[]', '[]', '[]', '[]'),
(34, 1, 'mángguǒ', '芒果', 'манго', '', '[]', '[]', '[]', '[]'),
(35, 1, 'duōshǎo', '多少', 'сколько', 'много мало', '[]', '[]', '[]', '[]'),
(36, 1, 'qián', '钱', 'деньги', '', '[]', '[]', '[]', '[]');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `cources`
--
ALTER TABLE `cources`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `grammatics`
--
ALTER TABLE `grammatics`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `hieroglyphs`
--
ALTER TABLE `hieroglyphs`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `lessons`
--
ALTER TABLE `lessons`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `topics`
--
ALTER TABLE `topics`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `words`
--
ALTER TABLE `words`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `admins`
--
ALTER TABLE `admins`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `cources`
--
ALTER TABLE `cources`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `grammatics`
--
ALTER TABLE `grammatics`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `hieroglyphs`
--
ALTER TABLE `hieroglyphs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `languages`
--
ALTER TABLE `languages`
  MODIFY `id` smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT для таблицы `lessons`
--
ALTER TABLE `lessons`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT для таблицы `topics`
--
ALTER TABLE `topics`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT для таблицы `words`
--
ALTER TABLE `words`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
