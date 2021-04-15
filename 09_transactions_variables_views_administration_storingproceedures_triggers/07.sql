use shop;
#           to see server parameters:
# mysqld --verbose --help


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# to see variables use command
show variables like '%datetimeformta%'; -- doesnt work
show variables like '%admin_address%';
show variables like '%admin_port%'; -- 33062
show variables like '%time_zone%';
show variables like 'transaction_isolation';
show variables like '%table_size';
show variables like 'auto_increment%';

set session tmp_table_size = 16777216; -- set during session
set global tmp_table_size = 16777216; -- set server settings

select *
from catalogs;

set session auto_increment_increment = 1; -- set during session

insert into catalogs (id, name)
values (default, 'adapters'); -- last added id became +10

# set @different_id :=
#         (select cat1.id
#          from catalogs cat1
#                   left join catalogs cat2 on cat1.id = cat2.id + 27
#          where cat2.id is not null);
#
# delete
# from catalogs
# where id = @different_id;

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# log files:
#     error logs
show variables like 'log_error';

#     general query logs
show variables like 'general_log%';
set global general_log = 0;
# set global general_log = 1;

#     slow query logs
show variables like 'slow_query%';
show variables like 'long_query_time';
set global slow_query_log = 0;
# set global slow_query_log = 1;
set global long_query_time = 10;
select benchmark(1000000000, (select count(*) from products));
# mysqldumpslow DESKTOP-F2U5O7B-slow.log

select * from mysql.general_log;
select * from mysql.slow_log;
show variables like 'log_output';
set global log_output = 'TABLE'; -- write logs to db
set global log_output = 'FILE'; -- write logs to files (default)
set global log_output = 'NONE'; -- not ot write logs


#     binary logs
show variables like 'log_bin';
# set global log_bin = 'ON'; -- only in my.ini
# mysqlbinlog DESKTOP-F2U5O7B-bin.000022


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
show variables like 'max_connect%';
show processlist ;
# kill 25 -- kill by id

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# users access
create user foo; -- without password
create user shop identified with sha256_password by 'pass';
# mysql -u shop -p
# enter password: pass
select user();
# +----------------+
# | user()         |
# +----------------+
# | shop@localhost |
# +----------------+
# 1 row in set (0.00 sec)

select host, user from mysql.user;
# +-----------+------------------+
# | host      | user             |
# +-----------+------------------+
# | %         | foo              |
# | %         | shop             |
# | localhost | mysql.infoschema |
# | localhost | mysql.session    |
# | localhost | mysql.sys        |
# | localhost | root             |
# +-----------+------------------+
# 6 rows in set (0.01 sec)

drop user foo;
rename user shop to foo;


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
select host, user from mysql.user;
# grant
grant all on *.* to 'foo'@'%';

# revoke
revoke all on *.* from 'foo'@'%';
drop user foo;

# priviliges:
# all, alter, create, delete, drop, execute, index, insert, references, select, show databases, show view, usage, grant option
grant select, insert, delete, update on *.* to foo;
grant all on *.* to foo;
grant grant option on *.* to foo;

# grant all, grant option on *.* to foo;  -- gives syntax error

grant usage, select on *.* to foo;

# scope of privileges
grant usage on *.* to foo;                                      -- rights on *.* (global)
grant usage on * to foo;                                        -- rights on * (current \ global if not selected any db for current usage)
grant usage on shop.* to foo;                                   -- right on database.*
grant usage on shop.catalogs to foo;                            -- rights on database.table
grant select (id, name), update (name) on shop.catalogs to foo; -- rights (col1, col2), rights (col1) on database.table


show grants; -- grants of current user

GRANT ALL ON shop.* TO 'foo'@'localhost' IDENTIFIED WITH sha256_password BY 'pass'
WITH MAX_CONNECTIONS_PER_HOUR 10
     MAX_QUERIES_PER_HOUR 1000
     MAX_UPDATES_PER_HOUR 200
     MAX_USER_CONNECTIONS 3;


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# replication - pizdec
