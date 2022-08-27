/*
	Представлена модель базы данных банка. С ключевыми таблицами clients и profiles.
Организована система платежей за покупки (payments) и переводов денежных средств между клиентами банка (remittances).
Базы городов и условий обслуживания для профилей пользователей, базы организаций, их расчетных счетов и наименований банков для совершения платежей.
Валютные операции и база разных валют с текущей стоимостью. 

*/

DROP DATABASE IF EXISTS bank;
CREATE DATABASE bank;
USE bank;

# DDL

DROP TABLE IF EXISTS clients; 
CREATE TABLE clients (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    email VARCHAR(120) UNIQUE,
    phone BIGINT UNIQUE,
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),

    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT 'Клиенты'; 

DROP TABLE IF EXISTS city; 
CREATE TABLE city (
  city_id SMALLINT unsigned NOT NULL AUTO_INCREMENT,
  city VARCHAR(50) NOT NULL UNIQUE, # название города
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (city_id)
) COMMENT 'Список городов';

DROP TABLE IF EXISTS banks; 
CREATE TABLE banks (
	bank_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (bank_id),
	bank VARCHAR(120) UNIQUE, # название банка
	correspondent_account BIGINT UNSIGNED NOT NULL UNIQUE, # кор. счет банка
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW()
) COMMENT 'Список банков (для организаций-продвацов)';


DROP TABLE IF EXISTS organizations; 
CREATE TABLE organizations (
	organization_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (organization_id),
	name_organization VARCHAR(120) UNIQUE, # название организации продавца
	bank_account_number BIGINT UNSIGNED NOT NULL UNIQUE, # расчетный счет продавца
	bank_id SMALLINT UNSIGNED NOT NULL,
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
	
	FOREIGN KEY (bank_id) REFERENCES banks(bank_id) ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Организации для платежей';


DROP TABLE IF EXISTS profiles; 
CREATE TABLE profiles (
	client_id BIGINT UNSIGNED NOT NULL UNIQUE,
	gender ENUM('m', 'f'),
	passport_number BIGINT UNSIGNED NOT NULL UNIQUE, # номер паспорта
	passport_date DATE, # дата выдачи
	city_id SMALLINT UNSIGNED NOT NULL,
	registered_at DATETIME DEFAULT NOW(),
	sum_of_client DECIMAL(15,2) NOT NULL DEFAULT 0, # количество денег у клиента
	
	FOREIGN KEY (client_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (city_id) REFERENCES city(city_id)  ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Профайл';

DROP TABLE IF EXISTS conditions;
CREATE TABLE conditions (
	client_id BIGINT UNSIGNED NOT NULL UNIQUE,
	interest_rate ENUM ('5%', '10%', '15%'), # процентная ставка вклада
	service_charge DECIMAL(15,2) NOT NULL DEFAULT 0, # плата за обслуживание
	bonus DECIMAL(15,2) UNSIGNED, # бонусы
	updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
	
	FOREIGN KEY (client_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Условия обслуживания';


DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	for_client_id BIGINT UNSIGNED NOT NULL,
	organization_id SMALLINT UNSIGNED NOT NULL,
	cost DECIMAL(15,2) NOT NULL DEFAULT 0, # размер платежа
	created_at DATETIME DEFAULT NOW(),
	
	FOREIGN KEY (organization_id) REFERENCES organizations(organization_id) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (for_client_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Платежи';


DROP TABLE IF EXISTS remittances;
CREATE TABLE remittances (
	id SERIAL,
	from_client_id BIGINT UNSIGNED NOT NULL, # отправитель
    to_client_id BIGINT UNSIGNED NOT NULL, # получатель
    message TEXT, # сопутствующее сообщение
    cost DECIMAL(15,2) NOT NULL DEFAULT 0, # сумма перевода
    created_at DATETIME DEFAULT NOW(),

    FOREIGN KEY (from_client_id) REFERENCES clients(id),
    FOREIGN KEY (to_client_id) REFERENCES clients(id)
) COMMENT 'Денежные переводы';


DROP TABLE IF EXISTS currency; 
CREATE TABLE currency (
  currency_id SMALLINT unsigned NOT NULL AUTO_INCREMENT,
  currency_type VARCHAR(50) NOT NULL UNIQUE, # название валюты
  currency_cost DECIMAL(15,2) NOT NULL DEFAULT 0, # стоимость валюты
  updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
  PRIMARY KEY (currency_id)
) COMMENT 'Список валют';

DROP TABLE IF EXISTS buy_currency; 
CREATE TABLE buy_currency (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	for_client_id BIGINT UNSIGNED NOT NULL, 
	count_currency DECIMAL(15,2) NOT NULL DEFAULT 0, # количество приобретаемой валюты
	currency_id SMALLINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
	
    FOREIGN KEY (for_client_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (currency_id) REFERENCES currency(currency_id) ON UPDATE CASCADE ON DELETE RESTRICT
) COMMENT 'Список покупок валюты'; 

# ДАМП

INSERT INTO `banks` VALUES (1,'Qui.',39758871784321000,'1972-05-20 21:46:27'),(2,'Ea.',76412953523180000,'2015-08-16 02:31:25'),(3,'Ut.',28926754118375000,'2006-10-03 02:39:06'),(4,'Et.',13796633334736000,'1992-05-22 01:13:58'),(5,'Quia.',79125984431768992,'2015-04-16 22:21:53'),(6,'Iste.',42237666343449000,'1976-09-04 00:11:16'),(7,'Quos.',54450846977742000,'1991-12-05 10:11:12'),(8,'Vel.',78615306251968992,'2016-06-28 22:54:36'),(9,'Aut.',11825638903224000,'2010-02-27 02:47:41'),(10,'Enim.',14182002439248000,'1979-12-21 03:11:46');
INSERT INTO `city` VALUES (1,'Port Nicole','2006-06-01 17:41:39'),(2,'Reecetown','2019-12-09 10:40:29'),(3,'North Vincenzaville','1978-11-11 15:30:29'),(4,'New Nyasiaside','1980-09-17 06:37:43'),(5,'South Jaceton','1976-07-08 20:21:16'),(6,'Port Benport','1990-04-09 05:10:55'),(7,'Gibsonhaven','1984-11-13 23:57:22'),(8,'Bechtelarport','2020-02-14 19:32:09'),(9,'Danielmouth','1995-06-19 18:46:52'),(10,'East Yvetteside','1982-05-02 02:24:14');
INSERT INTO `clients` VALUES (1,'Dixie','Mann','wunsch.lizeth@example.com',89241587985,'1980-08-18 18:41:13'),(2,'Shania','Bins','adrien70@example.net',89738238678,'1989-11-17 14:47:53'),(3,'Ova','Grant','lmayert@example.net',89257466445,'2011-07-20 04:57:35'),(4,'Noble','Labadie','claire.orn@example.com',89275713007,'1979-07-27 19:06:32'),(5,'Verdie','Mayert','mkrajcik@example.com',89307338854,'1993-05-15 00:16:07'),(6,'Neil','Nolan','ibogan@example.net',89411954066,'1971-12-27 21:37:49'),(7,'Sarah','Wisoky','herminia.larkin@example.org',89430548698,'1976-03-19 00:09:03'),(8,'Baron','Abbott','rheidenreich@example.net',89118353505,'1991-09-27 06:08:06'),(9,'Emily','Maggio','madge57@example.org',89122843216,'1991-04-10 14:24:53'),(10,'Eliane','Cassin','csauer@example.org',89766440147,'1996-12-28 01:29:08'),(11,'Chaya','Johnson','kub.paxton@example.com',89830616967,'1994-12-15 05:26:23'),(12,'Lenora','Auer','lenore38@example.org',89865602718,'2007-03-21 18:00:40'),(13,'Cecelia','Ratke','harris.eula@example.com',89653301790,'1977-10-25 10:12:48'),(14,'Carole','Wuckert','mina82@example.com',89642584678,'1983-12-27 17:46:15'),(15,'Aiyana','Kling','bode.celine@example.org',89283650130,'1993-12-01 07:28:25'),(16,'Gunner','Schaefer','aswift@example.org',89903121869,'2021-10-27 13:19:55'),(17,'Roxane','Schultz','pouros.trycia@example.net',89698324598,'1975-07-23 07:13:47'),(18,'Ima','Wilkinson','vklocko@example.org',89157154993,'1999-05-01 06:27:20'),(19,'Wilma','Koelpin','caltenwerth@example.org',89034658498,'2018-01-19 09:42:22'),(20,'Marquise','Murray','lmann@example.org',89927424360,'2020-11-30 05:44:21');
INSERT INTO `profiles` VALUES (1,'f',277442990885,'1998-08-23',5,'1990-05-03 00:23:08',7311573.79),(2,'f',504574299419,'2002-06-15',10,'1971-01-17 10:15:09',1994497.17),(3,'f',460808065841,'2017-07-10',3,'2006-07-13 03:42:56',1781789.73),(4,'f',641600225931,'1978-07-01',1,'1974-12-12 15:06:47',9326132.33),(5,'f',685728775656,'2020-03-31',4,'2014-06-22 03:40:54',1010430.48),(6,'m',829298899475,'1975-07-07',10,'1995-02-22 10:17:40',1566753.00),(7,'m',545945479183,'1992-03-14',8,'2015-11-17 14:34:16',2221680.50),(8,'m',420648410553,'2019-12-17',5,'1991-01-26 08:35:15',8148596.87),(9,'f',418066743304,'1984-08-24',5,'1984-09-20 18:02:06',6144078.78),(10,'f',671326114130,'2020-10-21',7,'2001-03-30 04:18:13',8046127.40),(11,'f',724849226244,'1982-09-12',5,'1992-08-10 18:40:49',3035431.60),(12,'f',904165320612,'1972-12-31',1,'1996-11-08 03:51:27',6929762.59),(13,'m',391182738119,'1975-03-16',1,'2019-07-30 21:34:24',8566618.00),(14,'f',972336359215,'2000-08-14',7,'2021-10-17 17:07:25',1436288.67),(15,'f',601078541577,'1991-08-24',2,'2019-03-10 07:45:20',5450481.67),(16,'f',752302049171,'1974-09-22',9,'1975-08-11 23:35:59',4977485.24),(17,'f',578044380982,'1973-06-14',5,'1978-06-23 16:31:45',4803744.82),(18,'f',606531286428,'1986-06-18',5,'1979-02-01 20:06:34',1252150.42),(19,'f',420871820543,'1972-05-21',10,'2000-12-14 19:32:33',9175709.40),(20,'f',299637508997,'2020-01-16',5,'1980-03-13 10:18:19',5033590.04);
INSERT INTO `conditions` VALUES (1,'15%',0.00,81831.49,'2021-06-16 08:43:33'),(2,'15%',5000.00,7976.10,'1989-11-28 23:25:42'),(3,'15%',10000.00,88171.21,'2021-12-22 22:10:03'),(4,'10%',3000.00,76353.77,'2005-12-11 23:02:52'),(5,'10%',3000.00,69794.68,'2002-04-12 23:08:16'),(6,'10%',1000.00,78369.83,'2009-02-11 19:05:20'),(7,'10%',0.00,39560.85,'1971-10-08 18:38:34'),(8,'10%',10000.00,41171.54,'2019-04-06 00:52:45'),(9,'5%',0.00,33136.56,'2021-12-30 18:32:27'),(10,'15%',3000.00,94719.45,'1991-12-19 13:17:33'),(11,'10%',3000.00,12517.65,'1981-03-25 17:54:20'),(12,'5%',1000.00,87878.00,'1970-03-20 20:36:15'),(13,'5%',500.00,5043.12,'2000-01-03 02:33:09'),(14,'10%',0.00,56220.16,'2008-09-11 03:31:09'),(15,'15%',1000.00,4518.28,'1979-06-03 05:08:03'),(16,'5%',5000.00,41420.16,'1996-06-24 11:26:51'),(17,'10%',500.00,58141.30,'2015-07-27 01:09:19'),(18,'5%',5000.00,62738.02,'1984-03-07 20:53:01'),(19,'5%',5000.00,43020.00,'1979-01-26 07:32:47'),(20,'5%',0.00,36440.68,'1987-10-08 15:15:01');
INSERT INTO `currency` VALUES (1,'EUR',163.30,'2000-11-06 13:10:55'),(2,'USD',184.95,'1980-10-21 01:36:28'),(3,'GBP',131.69,'1988-03-12 14:35:05'),(4,'CNY',21.63,'1997-08-26 03:18:52'),(5,'CHF',148.02,'1999-08-06 04:47:20');
INSERT INTO `organizations` VALUES (1,'blanditiis',92121378896,2,'2005-04-09 18:50:39'),(2,'deserunt',84525187655,4,'1995-08-05 11:02:34'),(3,'ipsam',46922197699,4,'1997-11-15 01:12:41'),(4,'sit',29236339586,5,'1972-10-30 06:00:18'),(5,'necessitatibus',89402363015,5,'2003-02-07 00:31:46'),(6,'ipsa',71059176232,3,'1983-01-19 18:10:01'),(7,'nulla',96373180125,7,'2021-08-03 22:20:58'),(8,'quisquam',26213204579,9,'2016-01-27 11:47:39'),(9,'modi',81071191812,9,'1975-12-11 02:58:10'),(10,'dolor',79618818335,10,'2012-07-12 01:00:20'),(11,'soluta',72377136001,7,'1972-03-11 21:12:27'),(12,'molestias',32804328977,1,'1975-10-08 12:34:39'),(13,'ut',70443067331,8,'1972-06-11 00:23:09'),(14,'enim',79804599322,10,'1999-07-08 02:11:03'),(15,'reprehenderit',56674839517,5,'2007-09-24 10:32:14'),(16,'consequatur',49137624688,8,'1987-10-30 03:33:44'),(17,'eaque',26018445192,4,'1991-07-11 13:06:50'),(18,'voluptate',23230673397,2,'1979-12-24 20:15:20'),(19,'occaecati',87770101869,9,'1996-06-06 01:04:40'),(20,'omnis',22629162084,2,'1976-12-24 01:02:26');
INSERT INTO `buy_currency` VALUES (1,5,1929.68,3,'2017-07-01 06:41:29'),(2,19,3666.16,4,'1999-02-20 22:30:02'),(3,15,4462.81,2,'1988-07-17 02:57:51'),(4,20,3469.00,3,'1987-09-17 22:48:53'),(5,20,1742.50,4,'2005-05-21 14:32:31'),(6,20,1745.89,4,'1982-10-09 16:25:42'),(7,2,3018.05,1,'2003-09-14 19:23:54'),(8,5,1954.20,5,'1983-03-26 01:12:20'),(9,19,1296.64,2,'1983-04-17 23:37:57'),(10,17,3237.25,5,'1997-04-25 18:43:59'),(11,3,4874.00,2,'1985-09-05 03:15:42'),(12,20,2522.71,2,'2011-04-01 03:25:03'),(13,15,2693.78,4,'2012-03-26 11:57:14'),(14,2,1817.72,5,'2003-06-28 19:18:56'),(15,7,3268.22,5,'2014-05-12 07:55:49'),(16,5,3901.19,5,'1973-05-28 19:35:00'),(17,10,4643.70,2,'2001-08-24 19:31:04'),(18,17,4066.71,5,'1978-12-22 00:15:02'),(19,16,4893.11,2,'1999-01-02 08:04:41'),(20,9,3188.21,4,'2000-04-22 21:40:07');
INSERT INTO `payments` VALUES (1,4,13,273977.97,'1996-02-08 00:18:26'),(2,5,17,507745.60,'2007-12-26 13:19:50'),(3,8,16,280254.69,'1975-03-04 15:08:19'),(4,4,20,31259.92,'2020-10-12 01:35:54'),(5,16,12,58729.68,'1994-12-29 06:57:29'),(6,1,13,208057.70,'1992-09-06 17:01:13'),(7,18,10,736296.11,'1990-03-22 01:14:03'),(8,5,1,254191.61,'2012-02-20 04:40:53'),(9,7,12,515732.01,'2008-11-10 21:42:21'),(10,18,19,245346.82,'2002-12-26 04:40:50'),(11,10,2,245327.00,'1982-10-24 04:29:38'),(12,20,7,284963.82,'1978-10-21 16:30:31'),(13,3,17,418685.36,'2002-05-16 21:04:52'),(14,12,19,340758.58,'2020-12-11 10:24:23'),(15,18,4,788704.07,'1976-11-27 09:49:02'),(16,12,4,377513.58,'1973-11-25 01:45:34'),(17,4,10,88337.00,'2015-05-27 19:18:24'),(18,13,19,503615.89,'1998-01-15 08:59:13'),(19,16,13,992244.46,'2017-01-24 10:00:56'),(20,12,14,79840.36,'1975-06-05 03:21:09');
INSERT INTO `remittances` VALUES (1,11,6,'Impedit commodi animi dolorum. Ducimus cum aliquam suscipit. Magnam ipsum neque et dolor. Velit saepe sed nemo quia rerum et. Beatae et est voluptas nesciunt voluptatem voluptas.',23588.60,'2016-09-06 05:25:58'),(2,2,5,'Rerum laborum rerum vitae error quia distinctio. Incidunt quidem debitis veniam nobis soluta dolorem laborum. Consequatur rem omnis sed molestias. Libero eum laudantium iure et omnis architecto.',15018.01,'2015-05-04 16:30:58'),(3,11,20,'Expedita quas neque eos ut. Eos ipsum omnis quidem hic. Voluptatum nisi tempora qui. Eum molestiae autem placeat fuga quisquam nesciunt.',35448.75,'2006-10-09 08:07:33'),(4,14,8,'Ut tenetur ducimus sed quo. Blanditiis excepturi iusto eaque vel quibusdam natus itaque. At eos labore eveniet facere autem quaerat quia.',40915.39,'1976-09-23 11:28:41'),(5,6,16,'Qui nulla et ut voluptas. Optio enim aut suscipit porro sapiente beatae. Explicabo voluptatibus cumque officia minima voluptas placeat.',49646.81,'2006-06-16 21:00:12'),(6,2,17,'Rem aut provident laboriosam aspernatur eos. Et quidem at quis aut in fugit. Id eos ea magnam. Distinctio deleniti nihil sed nemo vero excepturi.',16926.50,'1975-05-23 15:34:59'),(7,7,16,'Quia sed consequuntur quaerat rerum dolor voluptatum blanditiis. Voluptas et ut ab perferendis aut. Reprehenderit veniam quos sunt sint voluptatibus in.',39223.00,'1974-05-22 12:42:33'),(8,8,7,'Ut non voluptatem inventore qui. Cupiditate dignissimos qui sed iure veniam ea. Ipsa voluptas esse id quia. Vero occaecati pariatur accusamus esse voluptatem et.',40490.60,'1981-04-27 08:51:14'),(9,13,1,'Eum necessitatibus explicabo ut non et impedit harum. Qui maxime quis deserunt. Nostrum est deserunt omnis.',29617.90,'1973-10-26 05:00:15'),(10,13,1,'Et et blanditiis est molestias quos ut molestiae. Repellat qui praesentium excepturi sit ipsum quis omnis atque. Ipsa sit eos quam et unde. Qui ipsam quia eveniet natus necessitatibus aut.',39584.62,'1998-08-01 11:36:54'),(11,2,1,'Rerum dolor impedit perspiciatis optio. Adipisci enim pariatur sunt et. Unde autem vitae facilis autem. Deserunt deserunt consequuntur vel error laborum ipsa facilis.',32198.62,'1999-04-09 19:18:26'),(12,10,4,'Amet ut aspernatur minima nam optio. Hic provident quo quos qui omnis sunt et. Nisi iste sequi id reprehenderit. Non quasi ipsa quis numquam quas minus omnis aut.',39969.99,'2003-12-02 03:39:05'),(13,7,15,'Nobis sunt ipsa aut vero qui numquam nostrum. Quisquam neque a eius et repellat autem. Aliquam quo iusto rem optio inventore et. Et dicta ut harum eos quibusdam.',30278.00,'2002-10-31 10:45:43'),(14,5,3,'Aut est a non error quidem qui non. Quia saepe possimus doloribus tempore magnam. Dolores maxime dolorem maiores esse tempora aliquid.',2313.75,'2009-09-04 05:17:00'),(15,1,6,'Omnis nostrum odio cupiditate qui sunt sed. Necessitatibus et repellendus et libero dolores consectetur. Voluptatem dolores et ut. Beatae cumque aut perferendis enim.',11361.46,'1980-02-04 07:38:58'),(16,18,1,'Exercitationem voluptas aliquam eveniet rerum aut. Quis rem neque dolorum consequatur provident exercitationem. Eum natus similique et qui voluptas sunt.',2736.33,'1972-02-04 23:47:36'),(17,19,16,'Voluptatem vel laborum ut quia nesciunt id. Nam quae voluptas dolor esse doloremque in sed.',16288.25,'1990-04-14 00:21:40'),(18,20,5,'Ut aperiam aut est distinctio magni non sint. Cumque qui est provident at.',41862.07,'2003-12-02 06:49:38'),(19,18,18,'Sunt sit nihil explicabo exercitationem aperiam soluta. Excepturi voluptatem repudiandae amet consequatur rerum eum.',3316.45,'1976-08-20 13:41:59'),(20,7,9,'Est est dolorum recusandae. Quasi quia ipsa enim et pariatur. Labore ad ratione quia incidunt.',36875.27,'1994-02-04 12:50:59');


DROP PROCEDURE IF EXISTS payment; # процедура платежа
DELIMITER //
CREATE PROCEDURE payment(
	for_client_id BIGINT,
	organization_id SMALLINT,
	cost DECIMAL(15,2)
	)
BEGIN 
	# проверка на достаточное количество средств
	IF cost <= (SELECT sum_of_client FROM profiles WHERE for_client_id = profiles.client_id)
	THEN 
	START TRANSACTION; # ТРАНЗАКЦИЯ - списваем сумму со счета клиента и записываем платеж в лог
	
	UPDATE profiles
		SET sum_of_client = sum_of_client - cost
	WHERE profiles.client_id = for_client_id;	
	
	INSERT INTO payments (for_client_id, organization_id, cost)
	VALUES (for_client_id, organization_id, cost);  

	COMMIT;
		ELSE SELECT 'недостаточно средств';
		END IF;
END//


DROP PROCEDURE IF EXISTS remmitance// # процедура денежного перевода
CREATE PROCEDURE remmitance(
	from_client_id BIGINT, 
    to_client_id BIGINT, 
    message TEXT,
    cost DECIMAL(15,2)
	)
BEGIN
	# проверка на достаточное количество средств
	IF cost <= (SELECT sum_of_client FROM profiles WHERE from_client_id = profiles.client_id)
	THEN 
	START TRANSACTION; # ТРАНЗАКЦИЯ - списываем деньги с отправителя, добавляем их получателю и записываем перевод в лог
	
	UPDATE profiles # списание средств с отправителя
		SET sum_of_client = sum_of_client - cost
	WHERE profiles.client_id = from_client_id;	
	
	UPDATE profiles # начисление средств получателю
		SET sum_of_client = sum_of_client + cost
	WHERE profiles.client_id = to_client_id;

	INSERT INTO remittances (from_client_id, to_client_id, message, cost)
	VALUES (from_client_id, to_client_id, message, cost);  

	COMMIT;
		ELSE SELECT 'недостаточно средств';
		END IF;
	
END//
DELIMITER ;

# проверка - вызываем процедуры платежа и перевода.
CALL payment(1, 10, 53160);
CALL remmitance(1, 11, 'личное сообщение', 4620); 



DELIMITER //

# тригер на проверку наличия достаточных средств для платежа
DROP TRIGGER IF EXISTS check_sum//
CREATE TRIGGER check_sum 
BEFORE INSERT ON buy_currency
FOR EACH ROW
BEGIN
	DECLARE sum_client DECIMAL(15,2);
	DECLARE sum_buy DECIMAL(15,2);
	SELECT sum_of_client INTO sum_client FROM profiles WHERE NEW.for_client_id = profiles.client_id;
	SELECT (NEW.count_currency * currency.currency_cost) INTO sum_buy FROM currency WHERE NEW.currency_id = currency.currency_id;
	
	IF sum_client < sum_buy THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Недостаточно средств.';
	END IF;
END//

# тригер на списание средств после покупки валюты
CREATE TRIGGER pay_currency
AFTER INSERT ON buy_currency
FOR EACH ROW
BEGIN
	DECLARE sum_buy DECIMAL(15,2);
	SELECT (NEW.count_currency * currency.currency_cost) INTO sum_buy FROM currency WHERE NEW.currency_id = currency.currency_id;
	UPDATE profiles 
		SET  sum_of_client = sum_of_client - sum_buy
	WHERE
		NEW.for_client_id = profiles.client_id;
END//

DELIMITER ;

# проверка - вставляем в таблицу покупок запись, тригерры проверяет достаточность средств и списывают с указанного клиента деньги.
INSERT INTO buy_currency(for_client_id, count_currency,currency_id) VALUES (1,1000,2);


# представления

# 1. Создаем представления с именами и фамилиями клиетов из clients и суммой на счету из profiles. Сортируем по сумме средств по убыванию. Выводим 5 самых богатых клиентов. Используем JOIN
CREATE OR REPLACE VIEW top_reach_clients AS
SELECT
	clients.firstname AS name,
	clients.lastname AS surname,
	profiles.sum_of_client AS money 
FROM clients 
JOIN profiles
	ON profiles.client_id = clients.id
ORDER BY money DESC
LIMIT 5;

SELECT * FROM top_reach_clients;

# 2. Создаем представление, которое отображает имена и фамилии пользователей и количество полученных денежных переводов, располагаем по убыванию. Используем вложенные запросы.
CREATE OR REPLACE VIEW count_rem_clients AS
SELECT 
	(SELECT firstname FROM clients WHERE to_client_id = clients.id) AS name,
	(SELECT lastname FROM clients WHERE to_client_id = clients.id) AS surname,
	to_client_id AS client_id,
	count(*) AS sum_rem
FROM remittances
GROUP BY to_client_id
ORDER BY count(*) DESC; 

SELECT * FROM count_rem_clients;