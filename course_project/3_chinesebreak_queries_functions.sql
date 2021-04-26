use chinesebreak;

# сколько слов в каждом топике
select topic_id, count(id) as 'words per topic'
from word
group by topic_id;

# сколько грамматик в каждом топике
select topic_id, count(id) as 'grammars per topic'
from grammar
group by topic_id;

# в каком топике больше всего грамматик
select topic_id, count(*) grammars
from grammar
group by topic_id
order by grammars desc
limit 1;

# сколько в среднем иероглифов на каждый топик
select round(avg(cnt))
from (select count(id) cnt
      from `character`
      group by topic_id) tbl;

# сколько слов состоит более чем из одного иероглифа в первых двух топиках
select count(`char`) compound_words_qty
from word
where length(`char`) > 3
  and topic_id <= 2;

# вывести количетсво и написание pinyin слов содержащие 'i'
select count(id) words_with_i_qty, group_concat(' ', pinyin) pinyin_with_i
from `word`
where pinyin like '%i%';

# вывести количетсво и написание pinyin слов содержащие 'a'
select count(id) words_with_a_qty, group_concat(' ', pinyin) pinyin_with_a
from `word`
where pinyin like '%a%';

# сколько заданий прошел каждый пользователь
select user_id, count(*)
from user_progress_tasks upt
where upt.is_checked = 1
group by user_id;

# вывести email и количество пройденных слов пользователями, еще не купившими подписку
select user.id, user.email, count(id) words_qty
from user
         join user_progress_words upw on user.id = upw.user_id
where user.status not like 'premium%'
  and upw.count_right > 0
group by user_id;

# сколько писем еще не прочитано техподдержкой, которые написали пользователи прошедшие больше десяти заданий
select count(id)
from messages m
where m.from_id in (
    select user_id
    from (select user_id, count(*) as cnt
          from user_progress_tasks upt
          where is_checked = 1
          group by user_id
          having cnt > 10
         ) user_id_cnt)
  and is_checked = 1
  and type = 'user_admin';

# какие слова, грамматику и иероглифы пройдут пользователи в каком топике\ уроке\ задании
create or replace view active_elements as
select id    task_id,
       json_object(
               'active_words', (select elements -> "$.words_id_active_or_to_del" from task where id = task_id),
               'active_grammar', (select elements -> "$.grammar_id_active" from task where id = task_id),
               'active_character', (select elements -> "$.character_id_active" from task where id = task_id)
           ) act_el
from task;


select topic.id, topic.name, lesson.id, task.id, act_el
from task
         join active_elements on task.id = active_elements.task_id
         join lesson on task.lesson_id = lesson.id
         join topic on lesson.topic_id = topic.id
order by lesson_id;


# показать  правильный вариант предложения на китайском, его транслитерацию на pinyin, перевод и дословный перевод
# во всех заданиях, привальный ответ в которых админы составляют из слов (с указанием из какого топика это задание)
# то есть нужно учитывать, что правильный вариант ответа складывается из последовательности слов words_id из task.elements.$words_id

drop function if exists concat_sent_char_from_words_id;
create function concat_sent_char_from_words_id(this_task_id bigint)
    returns varchar(512)
    reads sql data
begin
    set @words_id_list = (select task.elements -> "$.words_id" from task where id = this_task_id);
    -- this_task_id

    set @sent_char = (select group_concat(`char` separator '')
                      from (
                               select *
                               from json_table(
                                            @words_id_list,
                                            "$[*]"
                                            columns (
                                                rowid for ordinality,
                                                word_id int path "$"
                                                )
                                        ) jst
                                        join word on jst.word_id = word.id
                               order by rowid) jsnt);

    return @sent_char;

end;

drop function if exists concat_sent_pinyin_from_words_id;
create function concat_sent_pinyin_from_words_id(this_task_id bigint)
    returns varchar(512)
    reads sql data
begin
    set @words_id_list = (select task.elements -> "$.words_id" from task where id = this_task_id);
    -- this_task_id

    set @sent_pinyin = (select group_concat(`pinyin` separator ' ')
                        from (
                                 select *
                                 from json_table(
                                              @words_id_list,
                                              "$[*]"
                                              columns (
                                                  rowid for ordinality,
                                                  word_id int path "$"
                                                  )
                                          ) jst
                                          join word on jst.word_id = word.id
                                 order by rowid) jsnt);

    return @sent_pinyin;

end;

create or replace view right_sentances as
select topic.id                                                   topic_id,
       topic.name                                                 topic_name,
       lesson.id                                                  lesson_id,
       task.id                                                    task_id,
       concat_sent_char_from_words_id(task.id)                    sent_char,
       concat_sent_pinyin_from_words_id(task.id)                  sent_pinyin,
       json_extract(task.right_sentences -> "$.sent_lang_A", "$") sent_lang,
       json_extract(task.right_sentences -> "$.sent_lit_A", "$")  sent_lit
from task_type tt
         join task on tt.id = task.task_type_id
         join lesson on task.lesson_id = lesson.id
         join topic on lesson.topic_id = topic.id
where tt.name like 'sent%';

select *
from right_sentances;


