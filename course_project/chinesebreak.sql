/*
Требования к курсовому проекту:
1) Составить общее текстовое описание БД и решаемых ею задач;
2) минимальное количество таблиц - 10;
3) скрипты создания структуры БД (с первичными ключами, индексами, внешними ключами);
4) создать ERDiagram для БД;
5) скрипты наполнения БД данными;
6) скрипты характерных выборок (включающие группировки 5, JOIN'ы 5, вложенные таблицы 10);
7) представления (минимум 2);
8) хранимые процедуры / триггеры;

приложение для изучения китайского. функционал - копия основного функционала на прохождение уроков существующего приложения hellochinese
    табличное представление данных для админки из первого курса: https://docs.google.com/spreadsheets/d/1la_atKTDrziyPFU22DQsm25utBWK5ppYP3MRAMS280U/edit?usp=sharing
    экранчики фронта: https://www.figma.com/file/EhIEXnGEn2S70FqKshyjZE/chinesego?node-id=937%3A0

База должна хранить данные

    -об админах - учителя, составители программы обученияимеет, имеют доступ к админке для ее наполнени


    -о структуре и составе учебного материала, который формируется и заполняется админом в админке
        -общая иерархия учебного материала
            -язык
            -курс(группа топиков)
            -топик(тематика)
            -урок
            -задание

        -контента учебного материала (элементы, из которых составляются задания которые пользователь проходит в практических упражнениях)
            -слово
            -иероглиф
            -грамматика


    -о медиафайлах. для каждого изучаемого элемента (слова, иероглифа, грамматики), предложения есть аудио, для иероглифов есть анимация начертания, для упраждений с картинками - картика, с видео - видео и тд
        -аудио
        -видео
        -картинка (растр\вектор)
        -анимация (растр\вектор)


    -о видах заданий, которыми будут наполняться уроки "для прохождения", и которые будут запускаться "для повторения"
        -упражнений при прохождении элементов
        -упражнений при повторении элементов


    -о пользователях - ученики, используют web\mobile app

        -данные касаемые учебного прогресса пользователя
            -какие уроки в каких топиках пройдены (наверное, лучше через зависимость топиков от заданий) то есть если пройдены все задания урока - открывается следующий урок, если пройдены все уроки топика - открывается следующий топик, если все топики курса - следущий курс. но должна быть предусмеотрена возможность досрочного прохождения курсового теста с открытием всех топиков всех уроков всех элементов внутри курса
            -какие элементы пройдены (пользователь впервые прошел задание, в котором элемент активен - этот элемент становится доступен к просмотру в виде карточки элемента, в которой указана основная информация об этом элементе и примере его использования = правильные ответы на задания при прохождении)
            -счетчик правильных\неправильных ответов в элементах (сколько раз пользователь правильно\неправильно ответил на задание при прохождении или повторении этого элемента)
            -данные о попадании элемента в "пул повторения" для возможности запуска упражнений на повторение этого элемента.

        -данные пользовательских настроек

 */

drop database if exists chinesebreak;
create database chinesebreak;
use chinesebreak;


drop table if exists admin;
create table admin
(
    id            serial primary key,
    first_name    varchar(100) not null,
    last_name     varchar(100) not null,
    email         varchar(100) not null unique,
    password_hash varchar(512) not null,
    phone         bigint unsigned,
    status        enum ('super', 'manager') comment 'у супера права на публикацию и удаление опубликованных разделов, у менджеров права на формирование учебного материала',
    registered_at datetime default now(),
    updated_at    datetime on update now(),
    index admin_first_last_name_idx (first_name, last_name)
) comment 'админ (учитель) - имеет доступ к админке для наполнения уч материалом курс. есть супер-админ, есть менеджер-админ)';


drop table if exists media;
create table media
(
    id        serial primary key,
    name      varchar(50) not null,
    type      enum ('audio', 'video', 'bitmap','svg', 'gif') comment '-аудио, -видео, -картинка (растр/вектор), -анимация (растр/вектор)',
    file_path varchar(2083),
    index name_idx (name)
) comment 'медиафайлы. для каждого изучаемого элемента (слова, иероглифа, грамматики), предложения есть аудио, для иероглифов есть анимация начертания, для упраждений с картинками - картика, с видео - видео и тд';


drop table if exists language;
create table language
(
    id               serial primary key,
    name             varchar(50)     not null,
    creator_admin_id bigint unsigned,
    created_at       datetime default now(),
    updator_admin_id bigint unsigned not null,
    updated_at       datetime on update now(),
    is_published     bit      default 0,
    published_at     datetime,
    index name_idx (name),
    constraint language_creator_admin_id_fk foreign key (creator_admin_id) references admin (id) on delete set null on update cascade
) comment 'общая иерархия учебного материала, на самом верху язык. предполагаем, что материал китайскому языку будем обучать не только русских, но в перспективе людей говорящих на других языках';


drop table if exists course;
create table course
(
    id               serial primary key,
    language_id      bigint unsigned,
    name             varchar(50)     not null,
    creator_admin_id bigint unsigned,
    created_at       datetime default now(),
    updator_admin_id bigint unsigned not null,
    updated_at       datetime on update now(),
    is_published     bit      default 0,
    published_at     datetime,
    index name_idx (name),
    constraint course_creator_admin_id_fk foreign key (creator_admin_id) references admin (id) on delete set null on update cascade,
    constraint language_id_fk foreign key (language_id) references language (id) on delete set null on update cascade
) comment 'курс(группа топиков)';


drop table if exists topic;
create table topic
(
    id               serial primary key,
    course_id        bigint unsigned,
    name             varchar(50)     not null,
    creator_admin_id bigint unsigned,
    created_at       datetime default now(),
    updator_admin_id bigint unsigned not null,
    updated_at       datetime on update now(),
    media_id         bigint unsigned comment 'svg иконка',
    index name_idx (name),
    constraint topic_creator_admin_id_fk foreign key (creator_admin_id) references admin (id) on delete set null on update cascade,
    constraint course_id_fk foreign key (course_id) references course (id) on delete set null on update cascade
) comment 'топик(тематика уроков)';


drop table if exists lesson;
create table lesson
(
    id               serial primary key,
    topic_id         bigint unsigned,
    creator_admin_id bigint unsigned,
    created_at       datetime default now(),
    updator_admin_id bigint unsigned not null,
    updated_at       datetime on update now(),
    constraint lesson_creator_admin_id_fk foreign key (creator_admin_id) references admin (id) on delete set null on update cascade,
    constraint topic_id_fk foreign key (topic_id) references topic (id) on delete set null on update cascade
) comment 'урок';


drop table if exists task_type;
create table task_type
(
    id   serial primary key,
    name varchar(50) not null
) comment 'типы заданий';
# 22 типа задания "на прохождение". добавляются админами в админке/ условно все типы можно разделить на работу со словами (в фигме это желтые), с предложениями (коричневые), с диалогами (фиолетовые), с паззлами(розовые), и ривалка иероглифов'
# 3 типа заданий. формируются при создании соответствующего элеметна. 2 запускаются при "повторе с носителями" (слова, грамматика) и при запуске "рисовалки"(иероглиф). рисовалку можно запустить "при прохождении" уроков.
# 2 типа на "повторение" слов / 4 доп. типа на "повтор сложного".


drop table if exists task;
create table task
(
    id               serial primary key,
    lesson_id        bigint unsigned,
    task_type_id     bigint unsigned not null,
    creator_admin_id bigint unsigned,
    created_at       datetime default now(),
    updator_admin_id bigint unsigned,
    updated_at       datetime on update now(),
    elements         json            ,
    right_sentences  json            ,
    wrong_sentences  json            ,
    media            json            ,
    constraint lesson_id_fk foreign key (lesson_id) references lesson (id) on delete set null on update cascade,
    constraint task_type_id_fk foreign key (task_type_id) references task_type (id) on delete cascade on update cascade,
    constraint task_creator_admin_id_fk foreign key (creator_admin_id) references admin (id) on delete set null on update cascade
) comment 'задание в уроке';


drop table if exists word;
create table word
(
    id             serial primary key,
    topic_id       bigint unsigned,
    `char`         varchar(50),
    pinyin         varchar(50),
    lang           varchar(50),
    lit            varchar(50),
    image_media_id bigint unsigned,
    audio_media_id bigint unsigned,
    index word_char_ind (`char`),
    index word_pinyin_ind (pinyin),
    index word_lang_ind (lang),
    index word_lit_ind (lit),
    constraint word_topic_id foreign key (topic_id) references topic (id),
    constraint word_image_media_id foreign key (image_media_id) references media (id),
    constraint word_audio_media_id foreign key (audio_media_id) references media (id)
);

drop table if exists grammar;
create table grammar
(
    id          serial primary key,
    topic_id    bigint unsigned,
    name        varchar(512) not null,
    explanation text(1000),
    `char`      varchar(512) not null,
    pinyin      varchar(512) not null,
    lang        varchar(512) not null,
    lit         varchar(512) not null,
    structure   varchar(512) not null,
    index grammar_name_ind (name),
    fulltext expl_ind (explanation),
    constraint grammar_topic_id foreign key (topic_id) references topic (id)
);


drop table if exists `character`;
create table `character`
(
    id                      serial primary key,
    topic_id                bigint unsigned,
    `char`                  varchar(50) not null,
    pinyin                  varchar(50) not null,
    lang                    varchar(50) not null,
    image_media_id          bigint unsigned default null,
    audio_media_id          bigint unsigned default null,
    char_animation_media_id json        not null,
    index character_pinyin_ind (pinyin),
    index character_char_ind (`char`),
    index character_lang_ind (lang),
    constraint character_topic_id foreign key (topic_id) references topic (id),
    constraint character_image_media_id foreign key (image_media_id) references media (id),
    constraint character_audio_media_id foreign key (audio_media_id) references media (id)
);

drop table if exists user;
create table user
(
    id            serial primary key,
    name          varchar(50)  not null,
    email         varchar(50)  not null unique,
    password_hash varchar(255) not null,
    phone         bigint unsigned unique default null,
    age           bigint unsigned        default null,
    registered_at datetime               default now(),
    updated_at    datetime on update now(),
    status        enum (
        'trial',
        'premium_1',
        'premium_6',
        'premium_12')          not null  default 'trial' comment 'по умолчанию у пользователя статус подписки trial, если по подписке - то может быть на месяц, пол года или на год',
    purchased_at  datetime,
    index user_name (name),
    index user_email (email),
    index user_status (status)
) comment 'пользователь (ученик) - использует web/mobile app';


drop table if exists user_progress_tasks;
create table user_progress_tasks
(
    user_id    bigint unsigned not null,
    task_id    bigint unsigned not null,
    is_checked bit      default 0,
    checked_at datetime default null on update now(),
    primary key (user_id, task_id),
    constraint user_progress_task_user_id_fk foreign key (user_id) references user (id),
    constraint user_progress_task_task_id_fk foreign key (task_id) references task (id)
);


drop table if exists mnemonic_stage;
create table mnemonic_stage
(
    id                  serial primary key,
    hours_before_repeat INT unsigned not null
);

drop table if exists user_progress_words;
create table user_progress_words
(
    user_id           bigint unsigned not null,
    word_id           bigint unsigned not null,
    checked_at        datetime                 default null on update now(),
    mnemonic_stage_id bigint unsigned not null default 1,
    expire_at         datetime                 default null,
    count_right       INT unsigned             default 0 comment 'счетчик правльных ответов',
    count_wrong       INT unsigned             default 0 comment 'счетчик неправильных ответов',
    primary key (user_id, word_id),
    constraint upw_mnemonic_stage_fk foreign key (mnemonic_stage_id) references mnemonic_stage (id),
    constraint upw_user_id foreign key (user_id) references user (id),
    constraint upw_word_id foreign key (word_id) references word (id)

) comment 'сначала у всех элементов счетчик правильных ответов (count_right=0) и все элементы находятся на первой
ступени "мнемонической лесенки", после того как элемент проходится впервые в задании - count_right = 1,
и expire_at = now() + mnemonic_stages.hourse_before_repeat первой ступени, после того как настает expire_at -
элемент попадает в "пул повторения". после прохождениея упражнения "на повторение" элемента из пула повторения - у
элемента увеличивается count_right + 1 и checked_times + 1, а expire_at становится равным
now() + mnemonic_stages.hourse_before_repeat второй ступени ';



drop table if exists user_progress_grammars;
create table user_progress_grammars
(
    user_id           bigint unsigned not null,
    grammar_id        bigint unsigned not null,
    checked_at        datetime                 default null on update now(),
    mnemonic_stage_id bigint unsigned not null default 1,
    expire_at         datetime                 default null,
    count_right       INT unsigned             default 0,
    count_wrong       INT unsigned             default 0,
    primary key (user_id, grammar_id),
    constraint upg_mnemonic_stage_id foreign key (mnemonic_stage_id) references mnemonic_stage (id),
    constraint upg_user_id foreign key (user_id) references user (id),
    constraint upg_grammar_id foreign key (grammar_id) references grammar (id)
);

drop table if exists user_progress_characters;
create table user_progress_characters
(
    user_id           bigint unsigned not null,
    character_id      bigint unsigned not null,
    checked_at        datetime                 default null on update now(),
    mnemonic_stage_id bigint unsigned not null default 1,
    expire_at         datetime                 default null,
    count_right       INT unsigned             default 0,
    count_wrong       INT unsigned             default 0,
    primary key (user_id, character_id),
    constraint upc_mnemonic_stage_id foreign key (mnemonic_stage_id) references mnemonic_stage (id),
    constraint upc_user_id foreign key (user_id) references user (id),
    constraint upc_character_id foreign key (character_id) references `character` (id)
);

drop table if exists messages;
create table messages
(
    id         serial primary key,
    type       enum ('user_admin', 'admin_user') comment 'направление а)пользователь-админ, б) админ-пользователь.',
    from_id    bigint unsigned,
    to_id      bigint unsigned,
    theme      varchar(512)    not null,
    body       text,
    file       MEDIUMBLOB,
    is_checked bit      default 0,
    created_at datetime default now(),
    constraint messages_from_admins foreign key (from_id) references admin(id) on delete set null on update cascade ,
    constraint messages_to_admins foreign key (to_id) references admin(id) on delete set null on update cascade,
    constraint messages_from_user foreign key (from_id) references user(id) on delete set null on update cascade ,
    constraint messages_to_user foreign key (to_id) references user(id) on delete set null on update cascade

) comment 'обратная связь с пользователями или тех поддержка, отправитель и получатель могут быть как user_id, так и admin_id, в зависимости от типа. пользователи друг другу не отправляют, ';

drop table if exists users_settings;
create table users_settings
(
    id                        serial primary key,
    user_id                   bigint unsigned not null,
    current_language_id       bigint unsigned                                                  default 1,
    text_size                 enum ('15','18','22')                                            default '18',
    chinese_display_type      enum ('only_characters', 'only_pinyin', 'characters_and_pinyin') default 'characters_and_pinyin',
    audio_speed               enum ('0.6', '1.0', '1.5')                                       default '1.0',
    audio_effects_are_on      bit                                                              default 1,
    audition_lessons_are_on   bit                                                              default 1,
    characters_lessons_are_on bit                                                              default 1,
    speaking_lessons_are_on   bit                                                              default 1,
    reminders_are_on          bit                                                              default 1,
    constraint user_settings_user_id foreign key (user_id) references user(id) on delete no action on update cascade
);

drop table if exists users_daily_goals;
create table users_daily_goals
(
    id              serial primary key,
    user_id         bigint unsigned  not null,
    daily_goal      tinyint unsigned not null default 50,
    goal_is_reached bit                       default 0,
    goal_date       datetime                  default now(),
    strike_qty      bigint unsigned  not null comment 'страйк - количетсво достигший цель дней подряд - 1. например, если пользователь 2 дня подряд достигает свою ежедневную цель по баллам - у него 1 страйк, если 3 дня подряд - 2 страйка',
    constraint users_daily_goals_user_id foreign key (user_id) references user (id)

) comment 'пользователь выставляет ежедневную цель по баллам, набирает их в зависимости от количества срабатываний счетчика count_right в элементах';


insert into admin (first_name, last_name, email, password_hash, phone, status, registered_at, updated_at)
values ('admin1', 'adminov1', 'ololo@gmail.com', 'alaululuakakasdfsdfsdfkaukauka123', 89230030303, 'super', default,
        default)
     , ('admin2', 'adminov2', 'pishpish@gmail.com', 'uuuuuuuuuuksdfsdulele323jbk2jb', 89250255353, 'manager', default,
        default)
     , ('admin3', 'adminov3', 'realne@gmail.com', 'rambaharamambarusdfsdfm1231231', 89330330303, 'manager', default,
        default)
;

insert into language (name, creator_admin_id, created_at, updator_admin_id, updated_at, is_published, published_at)
values ('russian', 1, default, 1, default, 0, null)
;

insert into media (id, name, type, file_path)
values (1, 'nǐhǎo.png', 'bitmap', 'https://...')
     , (2, 'nǐhǎo.mp3', 'audio', 'https://...')
     , (3, 'zàijiàn.png', 'bitmap', 'https://...')
     , (4, 'zàijiàn.mp3', 'audio', 'https://...')
     , (5, 'nǐ.png', 'bitmap', 'https://...')
     , (6, 'nǐ.mp3', 'audio', 'https://...')
     , (7, 'wǒ.png', 'bitmap', 'https://...')
     , (8, 'wǒ.mp3', 'audio', 'https://...')
     , (9, 'shì.png', 'bitmap', 'https://...')
     , (10, 'shì.mp3', 'audio', 'https://...')
     , (11, 'zhōngguó.png', 'bitmap', 'https://...')
     , (12, 'zhōngguó.mp3', 'audio', 'https://...')
     , (13, 'éguó.png', 'bitmap', 'https://...')
     , (14, 'éguó.mp3', 'audio', 'https://...')
     , (15, 'tā.png', 'bitmap', 'https://...')
     , (16, 'tā.mp3', 'audio', 'https://...')
     , (17, 'rén.png', 'bitmap', 'https://...')
     , (18, 'rén.mp3', 'audio', 'https://...')
     , (19, 'bù.png', 'bitmap', 'https://...')
     , (20, 'bù.mp3', 'audio', 'https://...')
     , (21, 'ma.png', 'bitmap', 'https://...')
     , (22, 'ma.mp3', 'audio', 'https://...')
     , (23, 'tā2.png', 'bitmap', 'https://...')
     , (24, 'tā2.mp3', 'audio', 'https://...')
     , (25, 'éyǔ.png', 'bitmap', 'https://...')
     , (26, 'éyǔ.mp3', 'audio', 'https://...')
     , (27, 'hànyǔ.png', 'bitmap', 'https://...')
     , (28, 'hànyǔ.mp3', 'audio', 'https://...')
     , (29, 'yīngyǔ.png', 'bitmap', 'https://...')
     , (30, 'yīngyǔ.mp3', 'audio', 'https://...')
     , (31, 'men.png', 'bitmap', 'https://...')
     , (32, 'men.mp3', 'audio', 'https://...')
     , (33, 'shuō.png', 'bitmap', 'https://...')
     , (34, 'shuō.mp3', 'audio', 'https://...')
     , (35, 'dōu.png', 'bitmap', 'https://...')
     , (36, 'dōu.mp3', 'audio', 'https://...')
     , (37, 'xué.png', 'bitmap', 'https://...')
     , (38, 'xué.mp3', 'audio', 'https://...')
     , (39, 'xiě.png', 'bitmap', 'https://...')
     , (40, 'xiě.mp3', 'audio', 'https://...')
     , (41, 'yě.png', 'bitmap', 'https://...')
     , (42, 'yě.mp3', 'audio', 'https://...')
     , (43, 'hànzi.png', 'bitmap', 'https://...')
     , (44, 'hànzi.mp3', 'audio', 'https://...')
     , (45, 'píngguǒ.png', 'bitmap', 'https://...')
     , (46, 'píngguǒ.mp3', 'audio', 'https://...')
     , (47, 'xīguā.png', 'bitmap', 'https://...')
     , (48, 'xīguā.mp3', 'audio', 'https://...')
     , (49, 'mángguǒ.png', 'bitmap', 'https://...')
     , (50, 'mángguǒ.mp3', 'audio', 'https://...')
     , (51, 'bōluó.png', 'bitmap', 'https://...')
     , (52, 'bōluó.mp3', 'audio', 'https://...')
     , (53, 'chī.png', 'bitmap', 'https://...')
     , (54, 'chī.mp3', 'audio', 'https://...')
     , (55, 'hé.png', 'bitmap', 'https://...')
     , (56, 'hé.mp3', 'audio', 'https://...')
     , (57, 'miànbāo.png', 'bitmap', 'https://...')
     , (58, 'miànbāo.mp3', 'audio', 'https://...')
     , (59, 'jīdàn.png', 'bitmap', 'https://...')
     , (60, 'jīdàn.mp3', 'audio', 'https://...')
     , (61, 'bǐnggān.png', 'bitmap', 'https://...')
     , (62, 'bǐnggān.mp3', 'audio', 'https://...')
     , (63, 'shuǐguǒ.png', 'bitmap', 'https://...')
     , (64, 'shuǐguǒ.mp3', 'audio', 'https://...')
     , (65, 'xǐhuān.png', 'bitmap', 'https://...')
     , (66, 'xǐhuān.mp3', 'audio', 'https://...')
     , (67, 'kāfēi.png', 'bitmap', 'https://...')
     , (68, 'kāfēi.mp3', 'audio', 'https://...')
     , (69, 'chá.png', 'bitmap', 'https://...')
     , (70, 'chá.mp3', 'audio', 'https://...')
     , (71, 'hē.png', 'bitmap', 'https://...')
     , (72, 'hē.mp3', 'audio', 'https://...')
     , (73, 'guǒzhī.png', 'bitmap', 'https://...')
     , (74, 'guǒzhī.mp3', 'audio', 'https://...')
     , (75, 'shuǐ.png', 'bitmap', 'https://...')
     , (76, 'shuǐ.mp3', 'audio', 'https://...')
     , (77, 'niúnǎi.png', 'bitmap', 'https://...')
     , (78, 'niúnǎi.mp3', 'audio', 'https://...')
     , (79, 'píjiǔ.png', 'bitmap', 'https://...')
     , (80, 'píjiǔ.mp3', 'audio', 'https://...')
     , (81, 'kělè.png', 'bitmap', 'https://...')
     , (82, 'kělè.mp3', 'audio', 'https://...')
     , (83, 'xiǎng.png', 'bitmap', 'https://...')
     , (84, 'xiǎng.mp3', 'audio', 'https://...')
     , (85, 'mǎi.png', 'bitmap', 'https://...')
     , (86, 'mǎi.mp3', 'audio', 'https://...')
     , (87, 'hǎo.png', 'bitmap', 'https://...')
     , (88, 'hǎo.mp3', 'audio', 'https://...')
     , (89, 'rén.png', 'bitmap', 'https://...')
     , (90, 'rén.mp3', 'audio', 'https://...')
     , (91, 'zhōng.png', 'bitmap', 'https://...')
     , (92, 'zhōng.mp3', 'audio', 'https://...')
     , (93, 'yǔ.png', 'bitmap', 'https://...')
     , (94, 'yǔ.mp3', 'audio', 'https://...')
     , (95, 'xué.png', 'bitmap', 'https://...')
     , (96, 'xué.mp3', 'audio', 'https://...')
     , (97, 'hàn.png', 'bitmap', 'https://...')
     , (98, 'hàn.mp3', 'audio', 'https://...')
     , (99, 'zì.png', 'bitmap', 'https://...')
     , (100, 'zì.mp3', 'audio', 'https://...')
     , (101, 'guā.png', 'bitmap', 'https://...')
     , (102, 'guā.mp3', 'audio', 'https://...')
     , (103, 'chī.png', 'bitmap', 'https://...')
     , (104, 'chī.mp3', 'audio', 'https://...')
     , (105, 'xǐ.png', 'bitmap', 'https://...')
     , (106, 'xǐ.mp3', 'audio', 'https://...')
     , (107, 'guǒ.png', 'bitmap', 'https://...')
     , (108, 'guǒ.mp3', 'audio', 'https://...')
     , (109, 'shuǐ.png', 'bitmap', 'https://...')
     , (110, 'shuǐ.mp3', 'audio', 'https://...')
     , (111, 'niú.png', 'bitmap', 'https://...')
     , (112, 'niú.mp3', 'audio', 'https://...')
     , (113, 'jiǔ.png', 'bitmap', 'https://...')
     , (114, 'jiǔ.mp3', 'audio', 'https://...')
     , (115, 'topic_hello.svg', 'svg', 'https://...')
     , (116, 'topic_study_chinese.svg', 'svg', 'https://...')
     , (117, 'topic_food.svg', 'svg', 'https://...')
     , (118, 'word_char_from_video_preview.mp4', 'video', 'https://...')
     , (119, 'you-are-not-russian.png', 'bitmap', 'https://...')
     , (120, 'you-are-not-chinese.png', 'bitmap', 'https://...')
     , (121, 'you-are-russian.png', 'bitmap', 'https://...')
     , (122, 'you-are-chinese.png', 'bitmap', 'https://...')
     , (123, 'zhāng wěi.mp3', 'audio', 'https://...')
     , (124, 'nǐ bù shì éguó rén.mp3', 'audio', 'https://...')
     , (125, 'nǐ shì zhāng wěi.mp3', 'audio', 'https://...')
     , (126, 'yī.png', 'bitmap', 'https://...')
     , (127, 'yī.mp3', 'audio', 'https://...')
     , (128, 'kuài.png', 'bitmap', 'https://...')
     , (129, 'kuài.mp3', 'audio', 'https://...')
     , (130, 'píngguǒ yī kuài.mp3', 'audio', 'https://...')
     , (131, 'nǐ shì zhāng wěi.mp4', 'video', 'https://...')
     , (132, 'tā men shuō hànyǔ.mp3', 'audio', 'https://...')
     , (133, 'duōshǎo.png', 'bitmap', 'https://...')
     , (134, 'duōshǎo.mp3', 'audio', 'https://...')
     , (135, 'qián.png', 'bitmap', 'https://...')
     , (136, 'qián.mp3', 'audio', 'https://...')
     , (137, 'mángguǒ duōshǎo qián.mp3', 'audio', 'https://...')
     , (138, 'tā shì zhōngguó rén ma.mp3', 'audio', 'https://...')
     , (139, 'tā bù shì zhōngguó rén.mp3', 'audio', 'https://...')
     , (140, 'tā shì éguó rén ma.mp4', 'video', 'https://...')
     , (141, 'tā shì éguó rén ma.mp3', 'audio', 'https://...')
     , (142, 'tā shì éguó rén.mp3', 'audio', 'https://...')
     , (143, 'nǐ hǎo wǒ shì zhāng wēi.mp3', 'audio', 'https://...')
     , (144, 'wǒ shì zhāng wēi.mp3', 'audio', 'https://...')
;


insert into course (language_id, name, creator_admin_id, created_at, updator_admin_id, updated_at, is_published,
                    published_at)
values (1, 'HSK-1', 1, default, 1, default, 0, null);

insert into topic (course_id, name, creator_admin_id, created_at, updator_admin_id, updated_at, media_id)
values (1, 'Привет', 1, default, 1, default, 115)
     , (1, 'Учить китайский', 2, default, 2, default, 116)
     , (1, 'Еда', 3, default, 3, default, 117)
;

insert into lesson (topic_id, creator_admin_id, created_at, updator_admin_id, updated_at)
values (1, 2, default, 1, default)
     , (1, 1, default, 1, default)
     , (1, 3, default, 1, default)
     , (2, 1, default, 1, default)
     , (2, 1, default, 1, default)
     , (2, 1, default, 1, default)
     , (3, 2, default, 2, default)
     , (3, 3, default, 3, default)
     , (3, 1, default, 3, default)
;

insert into task_type
values (1, 'word_image'),
       (2, 'word_char_from_lang'),
       (3, 'word_lang_from_char'),
       (4, 'word_char_from_video'),
       (5, 'word_match'),
       (6, 'sent_image'),
       (7, 'sent_char_from_lang'),
       (8, 'sent_lang_from_char'),
       (9, 'sent_lang_from_video'),
       (10, 'sent_say_from_char'),
       (11, 'sent_say_from_video'),
       (12, 'sent_paste_from_char'),
       (13, 'sent_choose_from_char'),
       (14, 'sent_delete_from_char'),
       (15, 'dialog_A_char_from_char'),
       (16, 'dialog_B_char_from_video'),
       (17, 'dialog_A_puzzle_char_from_char'),
       (18, 'dialog_B_puzzle_char_from_char'),
       (19, 'puzzle_char_from_lang'),
       (20, 'puzzle_lang_from_char'),
       (21, 'puzzle_char_from_video'),
       (22, 'draw_character');



insert into word (topic_id, `char`, pinyin, lang, lit, image_media_id, audio_media_id)
values (1, '你好', 'nǐhǎo', 'привет', 'тебе добро', 1, 2)
     , (1, '再见', 'zàijiàn', 'пока; увидимся', 'снова увидеться', 3, 4)
     , (1, '你', 'nǐ', 'ты', null, 5, 6)
     , (1, '我', 'wǒ', 'я', null, 7, 8)
     , (1, '是', 'shì', 'быть; являться', null, 9, 10)
     , (1, '中国', 'zhōngguó', 'Китай', 'срединная страна', 11, 12)
     , (1, '俄国', 'éguó', 'Россия', 'русская страна', 13, 14)
     , (1, '他', 'tā', 'он', 'русская страна', 15, 16)
     , (1, '人', 'rén', 'человек', null, 17, 18)
     , (1, '不', 'bù', 'не', null, 19, 20)
     , (1, '吗', 'ma', 'вопросительная частица для вопросов "да/нет"', null, 21, 22)
     , (1, '她', 'tā', 'она', null, 23, 24)
     , (2, '俄语', 'éyǔ', 'русский язык', null, 25, 26)
     , (2, '汉语', 'hànyǔ', 'китайский язык', null, 27, 28)
     , (2, '英语', 'yīngyǔ', 'английский язык', null, 29, 30)
     , (2, '们', 'men', 'маркер множественного числа (людей)', null, 31, 32)
     , (2, '说', 'shuō', 'говорить', null, 33, 34)
     , (2, '都', 'dōu', 'все; всё; оба', null, 35, 36)
     , (2, '学', 'xué', 'учить(-ся)', null, 37, 38)
     , (2, '写', 'xiě', 'писать', null, 39, 40)
     , (2, '也', 'yě', 'также; тоже', null, 41, 42)
     , (2, '汉字', 'hànzi', 'китайский иероглиф', null, 43, 44)
     , (3, '苹果', 'píngguǒ', 'яблоко', 'яблоко фрукт', 45, 46)
     , (3, '西瓜', 'xīguā', 'арбуз', 'запад(ная) дыня', 47, 48)
     , (3, '芒果', 'mángguǒ', 'манго', null, 49, 50)
     , (3, '菠萝', 'bōluó', 'ананас', 'шпинат редька', 51, 52)
     , (3, '吃', 'chī', 'кушать', null, 53, 54)
     , (3, '和', 'hé', 'и; с', null, 55, 56)
     , (3, '面包', 'miànbāo', 'хлеб', 'мучная упаковочка', 57, 58)
     , (3, '鸡蛋', 'jīdàn', 'яйцо', 'куриное яйцо', 59, 60)
     , (3, '饼干', 'bǐnggān', 'печенье', 'пирог сухой', 61, 62)
     , (3, '水果', 'shuǐguǒ', 'фрукт', 'водный фрукт', 63, 64)
     , (3, '喜欢', 'xǐhuān', 'нравиться', 'любить нравиться', 65, 66)
     , (3, '咖啡', 'kāfēi', 'кофе', null, 67, 68)
     , (3, '茶', 'chá', 'чай', null, 69, 70)
     , (3, '喝', 'hē', 'пить', null, 71, 72)
     , (3, '果汁', 'guǒzhī', 'сок', 'фруктовый сок', 73, 74)
     , (3, '水', 'shuǐ', 'вода', null, 75, 76)
     , (3, '牛奶', 'niúnǎi', 'молоко', 'коровье молоко', 77, 78)
     , (3, '啤酒', 'píjiǔ', 'пиво', 'пивной алкоголь', 79, 80)
     , (3, '可乐', 'kělè', 'кола', null, 81, 82)
     , (3, '想', 'xiǎng', 'хотеть, скучать', null, 83, 84)
     , (3, '买', 'mǎi', 'покупать', null, 85, 86)
     , (1, '。', ' ', ' ', null, null, null)
     , (1, '？', ' ', ' ', null, null, null)
     , (1, '张伟', 'zhāng wěi', 'Чжан Вэй', null, null, 123)
     , (1, '，', ' ', ' ', null, null, null)
     , (3, '一', 'yī', 'один', null, 126, 127)
     , (3, '块', 'kuài', 'блок, кусок', null, 128, 129)
     , (3, '多少', 'duōshǎo', 'сколько', 'много мало', 133, 134)
     , (3, '钱', 'qián', 'деньги', null, 135, 136)
;

insert into `character` (topic_id, `char`, pinyin, lang, image_media_id, audio_media_id, char_animation_media_id)
values (1, '好', 'hǎo', 'хорошо; добро; отлично', 87, 88, '{
  "svg_animation_id_set": []
}')
     , (1, '人', 'rén', 'человек', 89, 90, '{
  "svg_animation_id_set": []
}')
     , (1, '中', 'zhōng', 'центр; середина; Китай', 91, 92, '{
  "svg_animation_id_set": []
}')
     , (2, '语', 'yǔ', 'язык', 93, 94, '{
  "svg_animation_id_set": []
}')
     , (2, '学', 'xué', 'учиться', 95, 96, '{
  "svg_animation_id_set": []
}')
     , (2, '汉', 'hàn', 'китайский (язык); этническая группа Хань', 97, 98, '{
  "svg_animation_id_set": []
}')
     , (2, '字', 'zì', 'слово', 99, 100, '{
  "svg_animation_id_set": []
}')
     , (3, '瓜', 'guā', 'дыня', 101, 102, '{
  "svg_animation_id_set": []
}')
     , (3, '吃', 'chī', 'кушать', 103, 104, '{
  "svg_animation_id_set": []
}')
     , (3, '喜', 'xǐ', 'нравиться', 105, 106, '{
  "svg_animation_id_set": []
}')
     , (3, '果', 'guǒ', 'фрукт; результат', 107, 108, '{
  "svg_animation_id_set": []
}')
     , (3, '水', 'shuǐ', 'вода', 109, 110, '{
  "svg_animation_id_set": []
}')
     , (3, '牛', 'niú', 'корова, крупный рогатый скот', 111, 112, '{
  "svg_animation_id_set": []
}')
     , (3, '酒', 'jiǔ', 'алкоголь', 113, 114, '{
  "svg_animation_id_set": []
}')
;

insert into grammar (topic_id, name, explanation, `char`, pinyin, lang, lit, structure)
values (1, 'Личные местоимения',
        'Личные местоимения не склоняются:
        我 (wǒ) я = мне\n你 (nǐ) ты = тебе\n他 (tā) он = ему\n她 (tā) она = ей',
        '我是张伟。',
        'wǒ shì zhāng wēi',
        'Я - Чжан Вэй.',
        'я есть Чжан Вэй',
        'Я = мне / ты = тебе / он = ему / она = ей')

     , (1, '"Быть, являться" с помощью 是 (shì)',
        '是 (shì) - аналог "быть, являться" в английском языке.',
        '你是张伟。',
        'nǐ shì zhāng wěi',
        'Ты - Чжан Вэй.',
        'ты есть Чжан Вэй',
        'Кто/что + 是 + Кто/что2')

     , (1, 'Отрицание с помощью 不 (bù)',
        '不 (bù) - отрицательная частица. Ставится перед отрицаемым.',
        '他不是中国人。',
        'tā bù shì zhōngguó rén',
        'Он не китаец.',
        'он не есть срединная страна человек',
        'Кто/что + 不 + Что делать + Кого/чего')

     , (1, 'Простой вопрос "да/нет?" с помощью вопросительной частицы 吗 (ma)',
        '吗 (ma) - вопросительная частица, которая ставится в конце простого вопроса "да/нет?".',
        '你是俄国人吗？',
        'nǐ shì éguó rén ma',
        'Ты русский?',
        'ты есть русская страна человек MA?',
        'Кто/что + Что делать + Кого/чего + 吗?')

     , (2, 'Множественное число с помощью 们 (men)',
        '们 (men) - маркер множественного числа (людей).',
        '我们说俄语。',
        'wǒ men shuō éyǔ',
        'Мы говорим по-русски.',
        'мы говорим русский язык',
        '"我 (wǒ) - я, 我们 (wǒmen) - мы. 你 (nǐ) - ты, 你们 (nǐmen) - вы."')

     , (2, 'Обобщение с 都 (dōu)',
        '都 (dōu) - все; всё; оба.',
        '我们都说俄语。',
        'wǒ men dōu shuō éyǔ',
        'Мы все говорим по-русски.',
        'мы все говорим русский язык',
        'Кто/что + 都 + Что делать + Кого/чего.')

     , (2, 'Тоже (также) с помощью 也 (yě)',
        '也 (yě) - тоже, также.',
        '她也写汉字。',
        'tā yě xiě hànzì',
        'Она тоже пишет китайские иероглифы.',
        'она тоже пишет китайский иероглиф',
        'Кто/что + 也 + Что делать + Кого/чего.')

     , (3, 'Перечисление с помощью 和 (hé)',
        '和 (hé) - и; а также; с.',
        '她吃苹果和西瓜。',
        'tā chī píngguǒ hé xīguā',
        'Она ест яблоки и арбузы.',
        'она ест яблоки с арбузом',
        'Кого/чего1 + 和 + Кого/чего2.')

     , (3, '"Нравиться" с помощью 喜欢 (xǐhuān)',
        '喜欢 (xǐhuān) - любить, нравиться.',
        '我喜欢饼干。',
        'wǒ xǐhuān bǐnggān',
        'Я люблю печенье.',
        'мне нравится печенье',
        'Кто/что + 喜欢 + Что делать + Кого/чего.')

     , (3, '"Хотеть" с помощью 想 (xiǎng)',
        '想 (xiǎng) - хотеть сделать что-то.',
        '我想买可乐。',
        'wǒ xiǎng mǎi kělè',
        'Я хочу купить колу.',
        'я хочу колу',
        'Кто/что + 想 + Что делать + Кого/чего.')

     , (3, 'Выражение цены с помощью 块 (kuài)',
        'При обозначении цены не нужны дополнительные глаголы. 块 (kuài) - обычное обозначение Юаня в китайской устной речи.',
        '苹果一块。',
        'píngguǒ yī kuài',
        'Яблоко стоит 1 юань.',
        'яблоко 1 юань',
        'Кто/что + Сколько + 块')
     , (3, '"Сколько стоит?" с помощью 多少钱 (duōshǎo qián)',
        '多少 (duōshǎo) - сколько? 钱 (qián) - деньги.',
        '可乐多少钱？',
        'kělè duōshǎo qián',
        'Сколько стоит кола?',
        'кола сколько денег?',
        'Кто/что + 多少钱？')
;

insert into user (name, email, password_hash, phone, age, registered_at, status, purchased_at)
values ('user1', 'ololo@gmail.com', 'olololololopishpishrealne123', 89235230612, 16, now(), default, default)
     , ('user2', 'pish-pish@gmail.com', 'ololololoopishpishrealne124', 89235230614, 16, now(), default, default)
     , ('user3', 'realne@gmail.com', 'oloollololopishpishrealne124', 89235230613, 80, now(), 'premium_6', now())
;

insert into task (lesson_id, task_type_id, creator_admin_id, created_at, updator_admin_id, updated_at,
                  elements,
                  right_sentences,
                  wrong_sentences,
                  media)
values

#     (1, 'word_image')
 (1, 1, 1, default, 1, default
        ,'{"words_id": [1, 2, 3, 4], "words_id_active_or_to_del": [1]}'
        ,null
        ,null
        ,null)
        ,

#     (2, 'word_char_from_lang')
       (1, 2, 1, default, 1, default
        ,'{"words_id": [6, 7, 8, 9], "words_id_active_or_to_del": [7]}'
        ,null
        ,null
        ,null)
        ,

#     (3, 'word_lang_from_char')
       (2, 3, 1, default, 1, default
        ,'{"words_id": [7, 8, 9, 10], "words_id_active_or_to_del": [10]}'
        ,null
        ,null
        ,null)
        ,

#     (4, 'word_char_from_video')
       (2, 4, 1, default, 1, default
        ,'{"words_id": [1, 2, 3, 4], "words_id_active_or_to_del": [4]}'
        ,null
        ,null
        ,'{"video_id": [118]}')
        ,

#     (5, 'word_match')
       (3, 5, 1, default, 1, default
        ,'{"words_id": [13, 14, 15, 16, 17], "words_id_active_or_to_del": [13, 14, 15, 16, 17], "words_id_to_display": []}'
        ,null
        ,null
        ,null)
        ,
#     (6, 'sent_image')
#        你不是俄国人。 nǐ bù shì éguó rén
       (3, 6, 1, default, 1, default
        ,'{"words_id": [3, 10, 5, 7, 9, 45], "grammar_id_active": [3], "words_id_active_or_to_del": [10, 5]}'
        ,'{"sent_lang_A": ["Ты не русский."], "sent_lit_A": ["ты не есть русская страна человек"]}'
        ,null
        ,'{"sent_images_id": [119, 120, 121, 122], "sent_images_id_right": [119], "sent_audio_A_id": [124]}')
        ,

#     (7, 'sent_char_from_lang')
#        你是张伟。 nǐ shì zhāng wěi
       (4, 7, 1, default, 1, default
        ,'{"words_id": [1, 5, 47, 45], "grammar_id_active": [2], "words_id_active_or_to_del": [1, 5]}'
        ,'{"sent_lang_A": ["Ты - Чжан Вэй."], "sent_lit_A": ["ты есть Чжан Вэй"]}'
        ,'{"sent_char": ["我是张伟。", "你好，张伟。", "再见，张伟。"], "sent_pinyin": ["wǒ shì zhāng wēi", "nǐ hǎo zhāng wěi", "zàijiàn zhāng wěi"]}'
        ,'{"sent_audio_A_id": [125]}')
        ,

#     (8, 'sent_lang_from_char')
#        苹果一块。 píngguǒ yī kuài
       (4, 8, 1, default, 1, default
        ,'{"words_id": [23, 48, 49, 44], "grammar_id_active": [11], "words_id_active_or_to_del": [23, 44]}'
        ,'{"sent_lang_A": ["Яблоко стоит 1 юань."], "sent_lit_A": ["яблоко 1 юань"]}'
        ,'{"sent_lang": ["1 яблоко.", "2 яблока.", "Яблоко стоит 2 юаня."]}'
        ,'{"sent_audio_A_id": [130]}')
        ,

#     (9, 'sent_lang_from_video')
#        你是张伟。 nǐ shì zhāng wěi
       (5, 9, 1, default, 1, default
        ,'{"words_id": [1, 5, 47, 45], "grammar_id_active": [2], "words_id_active_or_to_del": [1, 5]}'
        ,'{"sent_lang_A": ["Ты - Чжан Вэй."], "sent_lit_A": ["ты есть Чжан Вэй"]}'
        ,'{"sent_lang": ["Я - Чжан Вэй.", "Привет, Чжан Вэй!"]}'
        ,'{"sent_video_id": [131]}')
        ,

#     (10, 'sent_say_from_char')
#        苹果一块。 píngguǒ yī kuài
       (5, 10, 1, default, 1, default
        ,'{"words_id": [23, 48, 49, 44], "grammar_id_active": [11], "words_id_active_or_to_del": [23], "words_id_to_display": [23, 48, 49]}'
        ,'{"sent_char_A": [], "sent_pinyin_A": [], "sent_lang_A": ["Яблоко стоит 1 юань."], "sent_lit_A": ["яблоко 1 юань"]}'
        ,null
        ,'{"sent_audio_A_id": [130]}')
        ,

#     (11, 'sent_say_from_video')
#        你是张伟。 nǐ shì zhāng wěi
       (6, 11, 1, default, 1, default
        ,'{"words_id": [1, 5, 47, 45], "grammar_id_active": [2], "words_id_active_or_to_del": [1, 5], "words_id_to_display": [1, 5, 47]}'
        ,'{"sent_lang_A": ["Ты - Чжан Вэй."], "sent_lit_A": ["ты есть Чжан Вэй"]}'
        , null
        ,'{"sent_video_id": [131], "sent_audio_A_id": [125]}')
        ,

#     (12, 'sent_paste_from_char')
#        他们说汉语。 tā men shuō hànyǔ
       (6, 12, 1, default, 1, default
        ,'{"words_id": [8, 16, 17, 14, 44], "grammar_id_active": [5], "words_id_active_or_to_del": [16], "words_id_to_display": [8, 16, 17, 14]}'
        ,'{"sent_lang_A": ["Они говорят по китайски."], "sent_lit_A": ["они говорят китайский язык"]}'
        ,null
        ,'{"sent_audio_A_id": [132]}')
        ,

#     (13, 'sent_choose_from_char')
#       他们说汉语。 tā men shuō hànyǔ
       (7, 13, 1, default, 1, default
        ,'{"words_id": [8, 16, 17, 14, 44], "grammar_id_active": [5], "words_id_active_or_to_del": [2], "words_id_to_display": [8, 16, 17, 14, 44], "words_id_wrong": [1, 2, 3]}'
        ,'{"sent_lang_A": ["Они говорят по китайски."], "sent_lit_A": ["они говорят китайский язык"]}'
        ,null
        ,'{"sent_audio_A_id": [132]}')
        ,

#     (14, 'sent_delete_from_char')
#        芒果多少钱？ mángguǒ duōshǎo qián
       (7, 14, 1, default, 1, default
        ,'{"words_id": [25, 50, 51, 11, 45], "grammar_id_active": [12], "words_id_active_or_to_del": [25, 50, 51, 11], "words_id_to_display": [25, 50, 51, 11], "words_id_wrong": [11]}'
        ,'{"sent_lang_A": ["Сколько стоит манго?"], "sent_lit_A": ["манго сколько денег?"]}'
        ,null
        ,'{"sent_audio_A_id": [137]}')
        ,

#     (15, 'dialog_A_char_from_char')
#        她是中国人吗？ tā shì zhōngguó rén ma <---
#        她不是中国人。 tā bù shì zhōngguó rén
       (8, 15, 1, default, 1, default
        ,'{"words_id": [12, 5, 6, 9, 11, 45], "grammar_id_active": [2], "words_id_active_or_to_del": [12, 5]}'
        ,'{"sent_lang_A": ["Она китаянка?"], "sent_lit_A": ["она есть срединная страна человек MA?"], "sent_char_B": ["她不是中国人。"], "sent_pinyin_B": ["tā bù shì zhōngguó rén"], "sent_lang_B": ["Она не китаянка."], "sent_lit_B": ["она не есть срединная страна человек"]}'
        ,'{"sent_char": ["她是俄国人吗？", "你是中国人吗？", "你是俄国人吗？"], "sent_pinyin": ["tā shì éguó rén ma", "nǐ shì zhōngguó rén ma", "nǐ shì éguó rén ma"]}'
        ,'{"sent_audio_A_id": [138], "sent_audio_B_id": [139]}')
        ,

#     (16, 'dialog_B_char_from_video')
#       她是俄国人吗？ tā shì éguó rén ma
#       她是俄国人。  tā shì éguó rén     <---
       (8, 16, 1, default, 1, default
        ,'{"words_id": [12, 5, 7, 9, 44], "grammar_id_active": [2], "words_id_active_or_to_del": [12, 5]}'
        ,'{"sent_char_A": ["她是俄国人吗？"], "sent_pinyin_A": ["tā shì éguó rén ma"], "sent_lang_A": ["Она русская?"], "sent_lit_A": ["она есть русская страна человек MA?"], "sent_lang_B": ["Она русская."], "sent_lit_B": ["она есть русская страна человек"]}'
        ,'{"sent_char": ["我是俄国人。", "你是俄国人。"], "sent_pinyin": ["wǒ shì éguó rén", "nǐ shì éguó rén"]}'
        ,'{"sent_video_id": [140], "sent_audio_A_id": [141], "sent_audio_B_id": [142]}')
        ,

#     (17, 'dialog_A_puzzle_char_from_char')
#        她是中国人吗？ tā shì zhōngguó rén ma <---
#        她不是中国人。 tā bù shì zhōngguó rén
       (9, 17, 1, default, 1, default
        ,'{"words_id": [12, 5, 6, 9, 11, 45], "grammar_id_active": [2], "words_id_active_or_to_del": [12, 5], "words_id_to_display": [12, 5, 6, 9, 11]}'
        ,'{"sent_lang_A": ["Она китаянка?"], "sent_lit_A": ["она есть срединная страна человек MA?"], "sent_char_B": ["她不是中国人。"], "sent_pinyin_B": ["tā bù shì zhōngguó rén"], "sent_lang_B": ["Она не китаянка."], "sent_lit_B": ["она не есть срединная страна человек"]}'
        ,null
        ,'{"sent_audio_A_id": [138], "sent_audio_B_id": [139]}')
        ,

#     (18, 'dialog_B_puzzle_char_from_char')
#       她是俄国人吗？ tā shì éguó rén ma
#       她是俄国人。  tā shì éguó rén     <---
       (9, 18, 1, default, 1, default
        ,'{"words_id": [12, 5, 7, 9, 44], "grammar_id_active": [2], "words_id_active_or_to_del": [12, 5], "words_id_to_display": [12, 5, 7, 9]}'
        ,'{"sent_char_A": ["她是俄国人吗？"], "sent_pinyin_A": ["tā shì éguó rén ma"], "sent_lang_A": ["Она русская?"], "sent_lit_A": ["она есть русская страна человек MA?"], "sent_lang_B": ["Она русская."], "sent_lit_B": ["она есть русская страна человек"]}'
        ,null
        ,'{"sent_audio_A_id": [141], "sent_audio_B_id": [142]}')
        ,

#     (19, 'puzzle_char_from_lang')
#      你好，我是张伟。 nǐ hǎo wǒ shì zhāng wēi
       (9, 19, 1, default, 1, default
        ,'{"words_id": [1, 47, 4, 5, 46, 44], "grammar_id_active": [2], "words_id_active_or_to_del": [1, 5], "words_id_to_display": [1, 4, 5, 46], "words_id_wrong": [10, 2, 3]}'
        ,'{"sent_lang_A": ["Привет, я - Чжан Вэй."], "sent_lit_A": ["тебе добро я есть Чжан Вэй"]}'
        ,null
        ,'{"sent_audio_A_id": [143]}')
        ,
#     (20, 'puzzle_lang_from_char')
#       我是张伟。 wǒ shì zhāng wēi \ я - Чжан Вэй.
       (9, 20, 1, default, 1, default
        ,'{"words_id": [4, 5, 46, 44], "grammar_id_active": [1, 2], "words_id_active_or_to_del": [4, 5]}'
        ,'{"sent_lang_A": [{"я": 1}, {"-": 0}, {"Чжан Вэй": 1}, {".": 0}], "sent_lit_A": ["я есть Чжан Вэй"]}'
        ,'{"sent_lang": ["не", "ты", "привет"]}'
        ,'{"sent_audio_A_id": [144]}')
        ,

#     (21, 'puzzle_char_from_video')
#        她是中国人吗？ tā shì zhōngguó rén ma
       (9, 21, 1, default, 1, default
        ,'{"words_id": [12, 5, 6, 9, 11, 45], "grammar_id_active": [2], "words_id_active_or_to_del": [12, 5], "words_id_to_display": [12, 5, 6, 9, 11], "words_id_wrong": [7, 8, 14]}'
        ,'{"sent_lang_A": ["Она китаянка?"], "sent_lit_A": ["она есть срединная страна человек MA?"]}'
        ,'{"sent_char": [], "sent_lang": [], "sent_pinyin": []}'
        ,'{"sent_video_id": [140], "sent_audio_A_id": [141]}')
        ,
#     (22, 'draw_character')
       (9, 22, 1, default, 1, default
        ,'{"character_id_active": [1]}'
        , null
        , null
        , null)
        ;

insert into user_progress_tasks (user_id, task_id)
values (1, 1)
#      , ()
;

update user_progress_tasks
set is_checked = 1
where user_id = 1
  and task_id = 1;

insert into mnemonic_stage (id, hours_before_repeat)
values (1, 0),
       (2, 12),
       (3, 24),
       (4, 96),
       (5, 336),
       (6, 720),
       (7, 1440),
       (8, 2880);

insert into user_progress_words (user_id, word_id)
values (1, 1);

# запрос повторе пользователем слова
update user_progress_words upw
set upw.mnemonic_stage_id = case
                                when upw.mnemonic_stage_id < 8 then mnemonic_stage_id + 1
                                when upw.mnemonic_stage_id >= 8 then 8
    end,
    count_right           = count_right + 1,
    expire_at             = adddate(now(), interval (select hours_before_repeat
                                                     from mnemonic_stage
                                                     where mnemonic_stage.id = upw.mnemonic_stage_id) hour)

where user_id = 1
  and word_id = 1;

# запрос повторе пользователем грамматики
update user_progress_grammars upg
set upg.mnemonic_stage_id = case
                                when upg.mnemonic_stage_id < 8 then mnemonic_stage_id + 1
                                when upg.mnemonic_stage_id >= 8 then 8
    end,
    count_right           = count_right + 1,
    expire_at             = adddate(now(), interval (select hours_before_repeat
                                                     from mnemonic_stage
                                                     where mnemonic_stage.id = upg.mnemonic_stage_id) hour)

where user_id = 1
  and grammar_id = 1;

update user_progress_characters upc
set upc.mnemonic_stage_id = case
                                when upc.mnemonic_stage_id < 8 then mnemonic_stage_id + 1
                                when upc.mnemonic_stage_id >= 8 then 8
    end,
    count_right           = count_right + 1,
    expire_at             = adddate(now(), interval (select hours_before_repeat
                                                     from mnemonic_stage
                                                     where mnemonic_stage.id = upc.mnemonic_stage_id) hour)

where user_id = 1
  and character_id = 1;

# добавить транзакцию с возможностью менять уроки местами
# проверка невозмоности добавить неправильный файл в words/grammar/character
