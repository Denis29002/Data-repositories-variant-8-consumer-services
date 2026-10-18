-- =====================================================================
-- Вариант 8. Обработка заказов в службе быта
-- Модель: 3НФ (третья нормальная форма). СУБД: MySQL 8 (MySQL Workbench)
-- Запуск: Workbench -> File -> Open SQL Script -> выполнить (молния)
-- =====================================================================
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `sluzhba_byta`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE `sluzhba_byta`;

-- =====================================================================
-- СПРАВОЧНИКИ
-- =====================================================================

-- Справочник должностей сотрудников
CREATE TABLE IF NOT EXISTS `dolzhnost` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `nazvanie` VARCHAR(45) NOT NULL COMMENT 'Название должности',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `dolzhnost_nazvanie_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Справочник должностей сотрудников';

-- Справочник категорий услуг
CREATE TABLE IF NOT EXISTS `kategoriya_uslugi` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `nazvanie` VARCHAR(60) NOT NULL COMMENT 'Название категории',
  `opisanie` VARCHAR(255) NULL COMMENT 'Описание',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `kategoriya_nazvanie_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Справочник категорий услуг';

-- Справочник статусов обработки заказа
CREATE TABLE IF NOT EXISTS `status_zakaza` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `nazvanie` VARCHAR(30) NOT NULL COMMENT 'Название статуса',
  `konechnyy` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 — конечный статус (выдан/отменён)',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `status_zakaza_nazvanie_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Справочник статусов обработки заказа';

-- Справочник способов оплаты
CREATE TABLE IF NOT EXISTS `sposob_oplaty` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `nazvanie` VARCHAR(30) NOT NULL COMMENT 'Название способа оплаты',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `sposob_oplaty_nazvanie_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Справочник способов оплаты';

-- Пункты приёма заказов
CREATE TABLE IF NOT EXISTS `punkt_priema` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `nazvanie` VARCHAR(60) NOT NULL COMMENT 'Название пункта',
  `adres` VARCHAR(255) NOT NULL COMMENT 'Адрес',
  `telefon` VARCHAR(15) NULL COMMENT 'Телефон',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB
  COMMENT = 'Пункты приёма заказов';


-- =====================================================================
-- УЧАСТНИКИ И УСЛУГИ
-- =====================================================================

-- Клиенты службы быта
CREATE TABLE IF NOT EXISTS `klient` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `imya` VARCHAR(45) NOT NULL,
  `familiya` VARCHAR(45) NOT NULL,
  `otchestvo` VARCHAR(45) NULL,
  `telefon` VARCHAR(15) NOT NULL COMMENT 'Телефон (бизнес-ключ)',
  `email` VARCHAR(60) NULL,
  `adres` VARCHAR(255) NULL,
  `data_registratsii` DATE NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `klient_telefon_UNIQUE` (`telefon` ASC) VISIBLE,
  INDEX `klient_familiya_idx` (`familiya` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Клиенты службы быта';

-- Сотрудники (приёмщики, мастера, администраторы)
CREATE TABLE IF NOT EXISTS `sotrudnik` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `imya` VARCHAR(45) NOT NULL,
  `familiya` VARCHAR(45) NOT NULL,
  `otchestvo` VARCHAR(45) NULL,
  `telefon` VARCHAR(15) NOT NULL COMMENT 'Телефон (бизнес-ключ)',
  `data_priema` DATE NOT NULL,
  `dolzhnost_id` INT NOT NULL,
  `punkt_id` INT NOT NULL COMMENT 'Пункт приёма, где работает',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `sotrudnik_telefon_UNIQUE` (`telefon` ASC) VISIBLE,
  INDEX `fk_sotrudnik_dolzhnost_id_idx` (`dolzhnost_id` ASC) VISIBLE,
  INDEX `fk_sotrudnik_punkt_id_idx` (`punkt_id` ASC) VISIBLE,
  CONSTRAINT `fk_sotrudnik_dolzhnost_id`
    FOREIGN KEY (`dolzhnost_id`) REFERENCES `dolzhnost` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_sotrudnik_punkt_id`
    FOREIGN KEY (`punkt_id`) REFERENCES `punkt_priema` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сотрудники (приёмщики, мастера, администраторы)';

-- Услуги (прайс-лист)
CREATE TABLE IF NOT EXISTS `usluga` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `kategoriya_id` INT NOT NULL,
  `nazvanie` VARCHAR(100) NOT NULL,
  `tsena` DECIMAL(10,2) NOT NULL COMMENT 'Действующая цена',
  `srok_dney` SMALLINT NOT NULL DEFAULT 1 COMMENT 'Типовой срок исполнения, дней',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `usluga_kat_nazvanie_UNIQUE` (`kategoriya_id` ASC, `nazvanie` ASC) VISIBLE,
  CONSTRAINT `fk_usluga_kategoriya_id`
    FOREIGN KEY (`kategoriya_id`) REFERENCES `kategoriya_uslugi` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Услуги (прайс-лист)';


-- =====================================================================
-- ЗАКАЗЫ И ИХ ОБРАБОТКА
-- =====================================================================

-- Заказ клиента (заголовок). Сумма не хранится, считается из позиций
CREATE TABLE IF NOT EXISTS `zakaz` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `nomer_zakaza` VARCHAR(20) NOT NULL COMMENT 'Номер заказа (бизнес-ключ)',
  `klient_id` INT NOT NULL,
  `punkt_id` INT NOT NULL,
  `priemshchik_id` INT NOT NULL COMMENT 'Сотрудник, принявший заказ',
  `status_id` INT NOT NULL COMMENT 'Текущий статус',
  `data_sozdaniya` DATETIME NOT NULL,
  `plan_data` DATE NOT NULL,
  `fakt_data` DATE NULL,
  `primechanie` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `zakaz_nomer_UNIQUE` (`nomer_zakaza` ASC) VISIBLE,
  INDEX `zakaz_daty_idx` (`data_sozdaniya` ASC, `plan_data` ASC) VISIBLE,
  INDEX `fk_zakaz_klient_id_idx` (`klient_id` ASC) VISIBLE,
  INDEX `fk_zakaz_punkt_id_idx` (`punkt_id` ASC) VISIBLE,
  INDEX `fk_zakaz_priemshchik_id_idx` (`priemshchik_id` ASC) VISIBLE,
  INDEX `fk_zakaz_status_id_idx` (`status_id` ASC) VISIBLE,
  CONSTRAINT `fk_zakaz_klient_id`
    FOREIGN KEY (`klient_id`) REFERENCES `klient` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_zakaz_punkt_id`
    FOREIGN KEY (`punkt_id`) REFERENCES `punkt_priema` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_zakaz_priemshchik_id`
    FOREIGN KEY (`priemshchik_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_zakaz_status_id`
    FOREIGN KEY (`status_id`) REFERENCES `status_zakaza` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Заказ клиента (заголовок). Сумма не хранится, считается из позиций';

-- Позиции (услуги) заказа
CREATE TABLE IF NOT EXISTS `pozitsiya_zakaza` (
  `zakaz_id` INT NOT NULL,
  `nomer_pozitsii` SMALLINT NOT NULL,
  `usluga_id` INT NOT NULL,
  `ispolnitel_id` INT NULL COMMENT 'Мастер-исполнитель',
  `kolichestvo` SMALLINT NOT NULL DEFAULT 1,
  `tsena_fiks` DECIMAL(10,2) NOT NULL COMMENT 'Цена на момент оформления',
  `primechanie` VARCHAR(255) NULL,
  PRIMARY KEY (`zakaz_id`, `nomer_pozitsii`),
  INDEX `fk_pozitsiya_zakaza_usluga_id_idx` (`usluga_id` ASC) VISIBLE,
  INDEX `fk_pozitsiya_zakaza_ispolnitel_id_idx` (`ispolnitel_id` ASC) VISIBLE,
  CONSTRAINT `fk_pozitsiya_zakaza_zakaz_id`
    FOREIGN KEY (`zakaz_id`) REFERENCES `zakaz` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pozitsiya_zakaza_usluga_id`
    FOREIGN KEY (`usluga_id`) REFERENCES `usluga` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pozitsiya_zakaza_ispolnitel_id`
    FOREIGN KEY (`ispolnitel_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Позиции (услуги) заказа';

-- Журнал обработки заказа: кто и когда сменил статус
CREATE TABLE IF NOT EXISTS `istoriya_statusov` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `zakaz_id` INT NOT NULL,
  `status_id` INT NOT NULL,
  `data_izmeneniya` DATETIME NOT NULL,
  `sotrudnik_id` INT NOT NULL,
  `primechanie` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_istoriya_statusov_zakaz_id_idx` (`zakaz_id` ASC) VISIBLE,
  INDEX `fk_istoriya_statusov_status_id_idx` (`status_id` ASC) VISIBLE,
  INDEX `fk_istoriya_statusov_sotrudnik_id_idx` (`sotrudnik_id` ASC) VISIBLE,
  CONSTRAINT `fk_istoriya_statusov_zakaz_id`
    FOREIGN KEY (`zakaz_id`) REFERENCES `zakaz` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_istoriya_statusov_status_id`
    FOREIGN KEY (`status_id`) REFERENCES `status_zakaza` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_istoriya_statusov_sotrudnik_id`
    FOREIGN KEY (`sotrudnik_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Журнал обработки заказа: кто и когда сменил статус';

-- Платежи по заказам (предоплата и оплата при выдаче)
CREATE TABLE IF NOT EXISTS `platezh` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'Суррогатный ключ',
  `zakaz_id` INT NOT NULL,
  `sposob_id` INT NOT NULL,
  `summa` DECIMAL(10,2) NOT NULL,
  `data_platezha` DATETIME NOT NULL,
  `prinyal_id` INT NOT NULL COMMENT 'Сотрудник, принявший оплату',
  PRIMARY KEY (`id`),
  INDEX `fk_platezh_zakaz_id_idx` (`zakaz_id` ASC) VISIBLE,
  INDEX `fk_platezh_sposob_id_idx` (`sposob_id` ASC) VISIBLE,
  INDEX `fk_platezh_prinyal_id_idx` (`prinyal_id` ASC) VISIBLE,
  CONSTRAINT `fk_platezh_zakaz_id`
    FOREIGN KEY (`zakaz_id`) REFERENCES `zakaz` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_platezh_sposob_id`
    FOREIGN KEY (`sposob_id`) REFERENCES `sposob_oplaty` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_platezh_prinyal_id`
    FOREIGN KEY (`prinyal_id`) REFERENCES `sotrudnik` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Платежи по заказам (предоплата и оплата при выдаче)';


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- =====================================================================
-- ТЕСТОВЫЕ ДАННЫЕ (для проверки и последующей загрузки в Data Vault)
-- =====================================================================
INSERT INTO `status_zakaza` (`id`,`nazvanie`,`konechnyy`) VALUES
 (1,'Принят',0),(2,'В работе',0),(3,'Готов к выдаче',0),(4,'Выдан',1),(5,'Отменён',1);
INSERT INTO `sposob_oplaty` (`id`,`nazvanie`) VALUES (1,'Наличные'),(2,'Банковская карта'),(3,'Безналичный перевод');
INSERT INTO `dolzhnost` (`id`,`nazvanie`) VALUES (1,'Приёмщик'),(2,'Мастер'),(3,'Администратор');
INSERT INTO `kategoriya_uslugi` (`id`,`nazvanie`,`opisanie`) VALUES
 (1,'Ремонт обуви','Набойки, молнии, подошвы'),(2,'Химчистка','Чистка верхней одежды и текстиля'),
 (3,'Ремонт одежды','Подгонка, замена фурнитуры'),(4,'Ремонт бытовой техники','Мелкая бытовая техника');
INSERT INTO `punkt_priema` (`id`,`nazvanie`,`adres`,`telefon`) VALUES
 (1,'Пункт №1','Рига, ул. Бривибас, 10','+37120000001'),(2,'Пункт №2','Рига, ул. Матиса, 25','+37120000002');
INSERT INTO `sotrudnik` (`id`,`imya`,`familiya`,`otchestvo`,`telefon`,`data_priema`,`dolzhnost_id`,`punkt_id`) VALUES
 (1,'Анна','Иванова','Петровна','+37121000001','2022-03-01',1,1),
 (2,'Олег','Сидоров','Иванович','+37121000002','2021-06-15',2,1),
 (3,'Янис','Берзиньш',NULL,'+37121000003','2020-09-10',2,2),
 (4,'Мария','Орлова','Сергеевна','+37121000004','2023-01-20',1,2),
 (5,'Наталья','Попова','Ивановна','+37121000005','2021-03-10',3,1);
INSERT INTO `usluga` (`id`,`kategoriya_id`,`nazvanie`,`tsena`,`srok_dney`) VALUES
 (1,1,'Замена набоек',8.00,1),(2,1,'Замена молнии',12.00,2),(3,2,'Химчистка пальто',20.00,3),
 (4,2,'Химчистка куртки',15.00,3),(5,3,'Подгонка брюк по длине',7.00,1),(6,4,'Ремонт утюга',18.00,5);
INSERT INTO `klient` (`id`,`imya`,`familiya`,`otchestvo`,`telefon`,`email`,`adres`,`data_registratsii`) VALUES
 (1,'Павел','Петров','Андреевич','+37126000001','petrov@example.com','Рига, ул. Лачплеша, 5','2024-01-11'),
 (2,'Елена','Кузнецова',NULL,'+37126000002','kuznetsova@example.com','Рига, ул. Дзирнаву, 12','2024-02-03'),
 (3,'Андрис','Лиепа',NULL,'+37126000003',NULL,NULL,'2024-03-18');
INSERT INTO `zakaz` (`id`,`nomer_zakaza`,`klient_id`,`punkt_id`,`priemshchik_id`,`status_id`,`data_sozdaniya`,`plan_data`,`fakt_data`,`primechanie`) VALUES
 (1,'ZK-2026-001',1,1,1,4,'2026-10-01 10:00:00','2026-10-04','2026-10-03',NULL),
 (2,'ZK-2026-002',2,2,4,2,'2026-10-14 11:20:00','2026-10-19',NULL,NULL),
 (3,'ZK-2026-003',3,1,1,1,'2026-10-16 09:30:00','2026-10-17',NULL,NULL);
INSERT INTO `pozitsiya_zakaza` (`zakaz_id`,`nomer_pozitsii`,`usluga_id`,`ispolnitel_id`,`kolichestvo`,`tsena_fiks`) VALUES
 (1,1,3,2,1,20.00),(1,2,5,2,1,7.00),(2,1,6,3,1,18.00),(3,1,1,NULL,1,8.00);
INSERT INTO `istoriya_statusov` (`zakaz_id`,`status_id`,`data_izmeneniya`,`sotrudnik_id`) VALUES
 (1,1,'2026-10-01 10:00:00',1),(1,2,'2026-10-01 14:00:00',2),(1,3,'2026-10-03 12:00:00',2),(1,4,'2026-10-03 17:30:00',1),
 (2,1,'2026-10-14 11:20:00',4),(2,2,'2026-10-15 09:00:00',3),(3,1,'2026-10-16 09:30:00',1);
INSERT INTO `platezh` (`zakaz_id`,`sposob_id`,`summa`,`data_platezha`,`prinyal_id`) VALUES
 (1,2,27.00,'2026-10-03 17:30:00',1),(2,1,5.00,'2026-10-14 11:25:00',4);

-- Контроль: сумма, оплата и долг по заказам
-- SELECT z.nomer_zakaza, SUM(p.kolichestvo*p.tsena_fiks) AS summa,
--        (SELECT COALESCE(SUM(summa),0) FROM platezh WHERE zakaz_id=z.id) AS oplacheno
--   FROM zakaz z JOIN pozitsiya_zakaza p ON p.zakaz_id=z.id GROUP BY z.id, z.nomer_zakaza;
