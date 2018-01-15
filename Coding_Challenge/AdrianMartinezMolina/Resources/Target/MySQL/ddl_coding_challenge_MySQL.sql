CREATE DATABASE IF NOT EXISTS `coding.challenge`;
USE `coding.challenge`;

/* ACTION_DIM */

CREATE TABLE IF NOT EXISTS `action_dim` (
  `action_key` INT NOT NULL AUTO_INCREMENT,
  `action` VARCHAR(250) NOT NULL,
  `description` VARCHAR(4000) NULL,
  PRIMARY KEY (`action_key`),
  UNIQUE INDEX `action_unique` (`action` ASC))
ENGINE=InnoDB
COMMENT = 'Dimension table which contains all diferent types of events';


/* USER_DIM */

CREATE TABLE IF NOT EXISTS `user_dim` (
  `user_key` INT NOT NULL AUTO_INCREMENT,
  `user` VARCHAR(10) NOT NULL,
  `username` VARCHAR(100) NULL,
  CHECK (`user` LIKE 'U%'), 
  /* check() would review if all users code start with "U". However in MySQL 5.7, the documentation says:
  "The CHECK clause is parsed but ignored by all storage engines" 
  (https://dev.mysql.com/doc/refman/5.7/en/create-table.html) */
  PRIMARY KEY (`user_key`),
  UNIQUE INDEX `user_unique` (`user` ASC))
ENGINE=InnoDB
COMMENT = 'Dimension table which contains all diferent users that generates events';


/* PRODUCT_DIM */

CREATE TABLE IF NOT EXISTS `product_dim` (
  `product_key` INT NOT NULL AUTO_INCREMENT,
  `product_code` VARCHAR(50) NOT NULL,
  `product_description` VARCHAR(4000) NULL,
  `category` VARCHAR(50) NULL,
  `category_description` VARCHAR(4000) NULL,
  PRIMARY KEY (`product_key`),
  UNIQUE INDEX `product_code_unique` (`product_code` ASC))
ENGINE=InnoDB
COMMENT = 'Dimension table which contains all diferent products y their related categories that can be viewed by users logged into';

/* DATETIME_DIM */

CREATE TABLE IF NOT EXISTS `datetime_dim`  (
    datetime_id bigint NOT NULL,
    fulldate datetime,
	hour int,
    dayofmonth int,
	monthnumber int,
	year    int,
	quarter tinyint,
	dayname varchar(10),
    monthname varchar(10),
    dayofweek int,
    dayofyear int,
    PRIMARY KEY(datetime_id)
) ENGINE=InnoDB
COMMENT = 'Time Dimension table that allows us to set relations between date/time and facts';


CREATE TABLE `coding.challenge`.`events_fact` (
  `id` BIGINT NOT NULL,
  `channel` VARCHAR(100) NOT NULL,
  `action_key` INT NOT NULL,
  `datetime_key` BIGINT NOT NULL,
  `user_key` INT NOT NULL,
  `product_key` INT NOT NULL,
  `value` VARCHAR(4000) NULL,
  INDEX `FK_EVENTS_FACTS_USER_DIM_idx` (`user_key` ASC),
  CONSTRAINT `FK_EVENTS_FACTS_USER_DIM`
    FOREIGN KEY (`user_key`)
    REFERENCES `coding.challenge`.`user_dim` (`user_key`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE=InnoDB 
COMMENT = 'Fact table which contains all diferent ocurrences of happened events emitted by Ecommerce Mobile App';

/* PRC_DATETIMEDIMBUILD */

DROP PROCEDURE IF EXISTS `prc_datetimedimbuild`;

delimiter //
CREATE PROCEDURE `prc_datetimedimbuild` (p_start_date DATETIME, p_end_date DATETIME)
BEGIN
    DECLARE v_full_date DATETIME;

    TRUNCATE datetime_dim;

    SET v_full_date = p_start_date;
    WHILE v_full_date < p_end_date DO

          INSERT INTO datetime_dim (
            datetime_id,
            fulldate,
            dayofmonth,
            hour,
            dayofyear,
            dayofweek,
            dayname,
            monthnumber,
            monthname,
            year,
            quarter
        ) VALUES (
			DATE_FORMAT(v_full_date, "%Y%m%d%H%i%s"),
            v_full_date,
            DAYOFMONTH(v_full_date),
            HOUR(v_full_date),
            DAYOFYEAR(v_full_date),
            DAYOFWEEK(v_full_date),
            DAYNAME(v_full_date),
            MONTH(v_full_date),
            MONTHNAME(v_full_date),
            YEAR(v_full_date),
            QUARTER(v_full_date)
        );

        SET v_full_date = DATE_ADD(v_full_date, INTERVAL 1 HOUR);
    END WHILE;
END //
delimiter ;

CALL `prc_datetimedimbuild`('2017-11-27 00:00:00', '2017-11-28 00:00:00');


