# Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию)
# 1. Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть
# доступны только запросы на чтение данных, тевторому пользовалю shop — любые операции в пределах базы данных shop.
drop user if exists shop_read;
create user shop_read identified with caching_sha2_password by 'pass';
grant usage, select on shop.* to shop_read;
show grants;
# mysql> show grants;
# +---------------------------------------------+
# | Grants for shop_read@%                      |
# +---------------------------------------------+
# | GRANT USAGE ON *.* TO `shop_read`@`%`       |
# | GRANT SELECT ON `shop`.* TO `shop_read`@`%` |
# +---------------------------------------------+
# 2 rows in set (0.00 sec)


create user shop identified with caching_sha2_password by 'pass';
grant all on shop.* to shop;
# mysql> show grants;
# +------------------------------------------------+
# | Grants for shop@%                              |
# +------------------------------------------------+
# | GRANT USAGE ON *.* TO `shop`@`%`               |
# | GRANT ALL PRIVILEGES ON `shop`.* TO `shop`@`%` |
# +------------------------------------------------+

select *
from mysql.user;


# 2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ,
# имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца
# id и name. Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать
# записи из представления username.

create table accounts
(
    id       serial primary key,
    name     varchar(255),
    password varchar(512)
);

insert into accounts (name, password)
values ('vasya', 'password1')
     , ('petya', 'password2')
     , ('dunya', 'password3')
;

select * from accounts;

create or replace view username as
    select id, name from accounts;

select * from username;

drop user if exists user_read;
create user user_read identified with caching_sha2_password by 'pass';

grant usage on accounts.* to user_read;
grant select on username.* to user_read;
# mysql> show grants;
# +-------------------------------------------------+
# | Grants for user_read@%                          |
# +-------------------------------------------------+
# | GRANT USAGE ON *.* TO `user_read`@`%`           |
# | GRANT SELECT ON `username`.* TO `user_read`@`%` |
# +-------------------------------------------------+
# 2 rows in set (0.00 sec)

