# https://d2xzmw6cctk25h.cloudfront.net/record/102898/attachment/8b5f862e0df8d879ba292a9f8c90ae39.mp4
#
# Ошибка "Unable to load authentication plugin 'caching_sha2_password'. "
# Запустите консоль.
#
# Выполните следующие команды:
#
# cd "C:\Program Files\MySQL\MySQL Server 8.0\bin"
#
# C:\Program Files\MySQL\MySQL Server 8.0\bin> mysql -u root -p
# Enter password: *********
#
# mysql> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'newrootpassword';
# Query OK, 0 rows affected (0.10 sec)
#
# mysql> exit

-- где 'newrootpassword' нужно заменить на ваш пароль

# 1. Добавление пути mysql в системную переменную Path (видео)
# https://www.youtube.com/watch?v=6Tnh9yRFMQw

# 2. Работа с дампами в Windows (видео)
# https://www.youtube.com/watch?v=QDvf1y-gl6Q

# 3. Создание файла my cnf в Windows (видео)
# https://www.youtube.com/watch?v=RJG9pQutWX0&feature=emb_title

USE gb;
CREATE TABLE courses(
	id INT,
	name VARCHAR(100)
);

CREATE TABLE students (
	id INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	firstname VARCHAR(100) NOT NULL,
	lastname VARCHAR(100) NOT NULL,
	email VARCHAR(100) NOT NULL UNIQUE,
	course_id INT
);

ALTER TABLE students 
ADD COLUMN bithday date;

ALTER TABLE students 
RENAME COLUMN bithday to date_of_birth;

ALTER TABLE students 
DROP COLUMN date_of_birth;

INSERT INTO courses   (name)
VALUES ('Databases') , ('Linux'), ('BigDATA');

INSERT INTO students  (firstname, lastname, email, course_id)
VALUES ('Pavel', 'Ivanov', 'gb_ivanov@mail.ru', 1) , 
('Sveta', 'Petrova', 'gb_petrova@mail.ru', 2) , 
('Ivan', 'Svetlov', 'gb_svetlov@mail.ru', 3) ;

SELECT * from courses ;
SELECT * from students;

UPDATE students 
SET email='gb_svetlov@yandex.ru'
WHERE lastname = 'Svetlov';

DELETE from students where id=3;

