# Практическое задание по теме “Транзакции, переменные, представления”
# 1 В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из
# таблицы shop.users в таблицу sample.users. Используйте транзакции.
set transaction isolation level repeatable read;
start transaction;

savepoint before_transaction;
insert into sample.users(id, name)
select id, name
from shop.users
where id = 1;

# rollback to savepoint before_transaction;
commit;

# 2 Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее
# название каталога name из таблицы catalogs.
use shop;

create or replace view products_catalogs_name as
select p.name prod_name, c.name catal_name
from products p
         left join catalogs c on p.catalog_id = c.id;

# 3 (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за
# август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный
# список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она
# отсутствует.
use shop;

drop table if exists august_dates;
create table august_dates
(
    id SERIAL PRIMARY KEY,
    created_at datetime
);
insert into august_dates (created_at)
values ('2018-08-01'),
       ('2016-08-04'),
       ('2018-08-16'),
       ('2018-08-17'),
       (null),
       ('2018-08-02'),
       ('2018-08-02'),
       ('2018-08-01'),
       (null);

# наверное более простой и очевидный запрос
select created_at,
       case isnull(created_at)
           when 0 then 1
           else 0
           end checkifthereisanydate
from august_dates;

# с подвыпердом хоть какогото использования "переменных" в названии типа как пройденной темы))
set @theres_date = 1;
set @theres_no_date = 0;
select created_at,
       case isnull(created_at)
           when 0 then @theres_date
           else @theres_no_date
           end checkifthereisanydate
from august_dates;

# 4 (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие
# записи из таблицы, оставляя только 5 самых свежих записей.
select * from august_dates;

delete
from august_dates
where created_at not in
      (select * from (select created_at from august_dates order by dayofyear(created_at) desc limit 5) ololo)
   or created_at is null;

select * from august_dates;


