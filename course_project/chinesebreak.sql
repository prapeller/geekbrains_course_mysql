DROP DATABASE IF EXISTS chinesebreak;
CREATE DATABASE chinesebreak;
USE chinesebreak;

# таблица админов, наполняют приложение контентом (элементами, заданиями
DROP TABLE IF EXISTS admin;
CREATE TABLE admin
(
    id            SERIAL PRIMARY KEY,
    first_name    VARCHAR(100) NOT NULL,
    last_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone         BIGINT UNSIGNED,
    INDEX admin_first_last_name (first_name, last_name)
);

DROP TABLE IF EXISTS language;
CREATE TABLE language
(
    id SMALLINT UNSIGNED AUTO_INCREMENT UNIQUE NOT NULL PRIMARY KEY,
    lang_name VARCHAR(20) NOT NULL,
    creator BIGINT UNSIGNED,
    FOREIGN KEY (creator) REFERENCES admin (id) ON UPDATE CASCADE ON DELETE
);