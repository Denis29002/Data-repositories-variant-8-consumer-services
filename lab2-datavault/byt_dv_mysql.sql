-- =====================================================================
-- Вариант 8. Служба быта. Модель Data Vault (хабы, связи, сателлиты)
-- Построена на основе 3НФ-схемы sluzhba_byta. СУБД: MySQL 8
-- hash key = MD5(бизнес-ключ), hash_diff = MD5(атрибуты сателлита)
-- =====================================================================
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `sluzhba_byta_dv`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE `sluzhba_byta_dv`;

-- =====================================================================
-- HUBS (бизнес-ключи)
-- =====================================================================

-- Хаб: должность
CREATE TABLE IF NOT EXISTS `hub_dolzhnost` (
  `dolzhnost_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `nazvanie` VARCHAR(45) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`dolzhnost_hk`),
  UNIQUE INDEX `hub_dolzhnost_bk_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: должность';

-- Хаб: категория услуг
CREATE TABLE IF NOT EXISTS `hub_kategoriya` (
  `kategoriya_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `nazvanie` VARCHAR(60) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`kategoriya_hk`),
  UNIQUE INDEX `hub_kategoriya_bk_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: категория услуг';

-- Хаб: статус заказа
CREATE TABLE IF NOT EXISTS `hub_status` (
  `status_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `nazvanie` VARCHAR(30) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`status_hk`),
  UNIQUE INDEX `hub_status_bk_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: статус заказа';

-- Хаб: способ оплаты
CREATE TABLE IF NOT EXISTS `hub_sposob_oplaty` (
  `sposob_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `nazvanie` VARCHAR(30) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`sposob_hk`),
  UNIQUE INDEX `hub_sposob_oplaty_bk_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: способ оплаты';

-- Хаб: пункт приёма
CREATE TABLE IF NOT EXISTS `hub_punkt` (
  `punkt_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `nazvanie` VARCHAR(60) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`punkt_hk`),
  UNIQUE INDEX `hub_punkt_bk_UNIQUE` (`nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: пункт приёма';

-- Хаб: клиент
CREATE TABLE IF NOT EXISTS `hub_klient` (
  `klient_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `telefon` VARCHAR(15) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`klient_hk`),
  UNIQUE INDEX `hub_klient_bk_UNIQUE` (`telefon` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: клиент';

-- Хаб: сотрудник
CREATE TABLE IF NOT EXISTS `hub_sotrudnik` (
  `sotrudnik_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `telefon` VARCHAR(15) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`sotrudnik_hk`),
  UNIQUE INDEX `hub_sotrudnik_bk_UNIQUE` (`telefon` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: сотрудник';

-- Хаб: услуга
CREATE TABLE IF NOT EXISTS `hub_usluga` (
  `usluga_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `nazvanie` VARCHAR(100) NOT NULL,
  `kategoriya_nazvanie` VARCHAR(60) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`usluga_hk`),
  UNIQUE INDEX `hub_usluga_bk_UNIQUE` (`nazvanie` ASC, `kategoriya_nazvanie` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: услуга';

-- Хаб: заказ
CREATE TABLE IF NOT EXISTS `hub_zakaz` (
  `zakaz_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ бизнес-ключа',
  `nomer_zakaza` VARCHAR(20) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`zakaz_hk`),
  UNIQUE INDEX `hub_zakaz_bk_UNIQUE` (`nomer_zakaza` ASC) VISIBLE
) ENGINE = InnoDB
  COMMENT = 'Хаб: заказ';


-- =====================================================================
-- LINKS (связи)
-- =====================================================================

-- Связь: сотрудник — должность
CREATE TABLE IF NOT EXISTS `link_sotrudnik_dolzhnost` (
  `link_sotr_dolzh_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `dolzhnost_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_sotr_dolzh_hk`),
  UNIQUE INDEX `link_sotrudnik_dolzhnost_uniq_UNIQUE` (`sotrudnik_hk` ASC, `dolzhnost_hk` ASC) VISIBLE,
  INDEX `fk_link_sotrudnik_dolzhnost_sotrudnik_hk_idx` (`sotrudnik_hk` ASC) VISIBLE,
  INDEX `fk_link_sotrudnik_dolzhnost_dolzhnost_hk_idx` (`dolzhnost_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_sotrudnik_dolzhnost_sotrudnik_hk`
    FOREIGN KEY (`sotrudnik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_sotrudnik_dolzhnost_dolzhnost_hk`
    FOREIGN KEY (`dolzhnost_hk`) REFERENCES `hub_dolzhnost` (`dolzhnost_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: сотрудник — должность';

-- Связь: сотрудник — пункт приёма
CREATE TABLE IF NOT EXISTS `link_sotrudnik_punkt` (
  `link_sotr_punkt_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `punkt_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_sotr_punkt_hk`),
  UNIQUE INDEX `link_sotrudnik_punkt_uniq_UNIQUE` (`sotrudnik_hk` ASC, `punkt_hk` ASC) VISIBLE,
  INDEX `fk_link_sotrudnik_punkt_sotrudnik_hk_idx` (`sotrudnik_hk` ASC) VISIBLE,
  INDEX `fk_link_sotrudnik_punkt_punkt_hk_idx` (`punkt_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_sotrudnik_punkt_sotrudnik_hk`
    FOREIGN KEY (`sotrudnik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_sotrudnik_punkt_punkt_hk`
    FOREIGN KEY (`punkt_hk`) REFERENCES `hub_punkt` (`punkt_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: сотрудник — пункт приёма';

-- Связь: услуга — категория
CREATE TABLE IF NOT EXISTS `link_usluga_kategoriya` (
  `link_usl_kat_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `usluga_hk` CHAR(32) NOT NULL,
  `kategoriya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_usl_kat_hk`),
  UNIQUE INDEX `link_usluga_kategoriya_uniq_UNIQUE` (`usluga_hk` ASC, `kategoriya_hk` ASC) VISIBLE,
  INDEX `fk_link_usluga_kategoriya_usluga_hk_idx` (`usluga_hk` ASC) VISIBLE,
  INDEX `fk_link_usluga_kategoriya_kategoriya_hk_idx` (`kategoriya_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_usluga_kategoriya_usluga_hk`
    FOREIGN KEY (`usluga_hk`) REFERENCES `hub_usluga` (`usluga_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_usluga_kategoriya_kategoriya_hk`
    FOREIGN KEY (`kategoriya_hk`) REFERENCES `hub_kategoriya` (`kategoriya_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: услуга — категория';

-- Связь: заказ — клиент — пункт — приёмщик
CREATE TABLE IF NOT EXISTS `link_zakaz` (
  `link_zakaz_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `zakaz_hk` CHAR(32) NOT NULL,
  `klient_hk` CHAR(32) NOT NULL,
  `punkt_hk` CHAR(32) NOT NULL,
  `priemshchik_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zakaz_hk`),
  UNIQUE INDEX `link_zakaz_uniq_UNIQUE` (`zakaz_hk` ASC, `klient_hk` ASC, `punkt_hk` ASC, `priemshchik_hk` ASC) VISIBLE,
  INDEX `fk_link_zakaz_zakaz_hk_idx` (`zakaz_hk` ASC) VISIBLE,
  INDEX `fk_link_zakaz_klient_hk_idx` (`klient_hk` ASC) VISIBLE,
  INDEX `fk_link_zakaz_punkt_hk_idx` (`punkt_hk` ASC) VISIBLE,
  INDEX `fk_link_zakaz_priemshchik_hk_idx` (`priemshchik_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_zakaz_zakaz_hk`
    FOREIGN KEY (`zakaz_hk`) REFERENCES `hub_zakaz` (`zakaz_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_zakaz_klient_hk`
    FOREIGN KEY (`klient_hk`) REFERENCES `hub_klient` (`klient_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_zakaz_punkt_hk`
    FOREIGN KEY (`punkt_hk`) REFERENCES `hub_punkt` (`punkt_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_zakaz_priemshchik_hk`
    FOREIGN KEY (`priemshchik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: заказ — клиент — пункт — приёмщик';

-- Связь: смена статуса заказа (история обработки)
CREATE TABLE IF NOT EXISTS `link_zakaz_status` (
  `link_zakaz_status_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `zakaz_hk` CHAR(32) NOT NULL,
  `status_hk` CHAR(32) NOT NULL,
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `data_izmeneniya` DATETIME NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_zakaz_status_hk`),
  UNIQUE INDEX `link_zakaz_status_uniq_UNIQUE` (`zakaz_hk` ASC, `status_hk` ASC, `sotrudnik_hk` ASC, `data_izmeneniya` ASC) VISIBLE,
  INDEX `fk_link_zakaz_status_zakaz_hk_idx` (`zakaz_hk` ASC) VISIBLE,
  INDEX `fk_link_zakaz_status_status_hk_idx` (`status_hk` ASC) VISIBLE,
  INDEX `fk_link_zakaz_status_sotrudnik_hk_idx` (`sotrudnik_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_zakaz_status_zakaz_hk`
    FOREIGN KEY (`zakaz_hk`) REFERENCES `hub_zakaz` (`zakaz_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_zakaz_status_status_hk`
    FOREIGN KEY (`status_hk`) REFERENCES `hub_status` (`status_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_zakaz_status_sotrudnik_hk`
    FOREIGN KEY (`sotrudnik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: смена статуса заказа (история обработки)';

-- Связь: позиция заказа (заказ — услуга)
CREATE TABLE IF NOT EXISTS `link_pozitsiya_zakaza` (
  `link_pozitsiya_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `zakaz_hk` CHAR(32) NOT NULL,
  `usluga_hk` CHAR(32) NOT NULL,
  `nomer_pozitsii` VARCHAR(20) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_pozitsiya_hk`),
  UNIQUE INDEX `link_pozitsiya_zakaza_uniq_UNIQUE` (`zakaz_hk` ASC, `usluga_hk` ASC, `nomer_pozitsii` ASC) VISIBLE,
  INDEX `fk_link_pozitsiya_zakaza_zakaz_hk_idx` (`zakaz_hk` ASC) VISIBLE,
  INDEX `fk_link_pozitsiya_zakaza_usluga_hk_idx` (`usluga_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_pozitsiya_zakaza_zakaz_hk`
    FOREIGN KEY (`zakaz_hk`) REFERENCES `hub_zakaz` (`zakaz_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_pozitsiya_zakaza_usluga_hk`
    FOREIGN KEY (`usluga_hk`) REFERENCES `hub_usluga` (`usluga_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: позиция заказа (заказ — услуга)';

-- Связь: исполнитель позиции заказа
CREATE TABLE IF NOT EXISTS `link_ispolnitel` (
  `link_ispolnitel_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `link_pozitsiya_hk` CHAR(32) NOT NULL,
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_ispolnitel_hk`),
  UNIQUE INDEX `link_ispolnitel_uniq_UNIQUE` (`link_pozitsiya_hk` ASC, `sotrudnik_hk` ASC) VISIBLE,
  INDEX `fk_link_ispolnitel_link_pozitsiya_hk_idx` (`link_pozitsiya_hk` ASC) VISIBLE,
  INDEX `fk_link_ispolnitel_sotrudnik_hk_idx` (`sotrudnik_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_ispolnitel_link_pozitsiya_hk`
    FOREIGN KEY (`link_pozitsiya_hk`) REFERENCES `link_pozitsiya_zakaza` (`link_pozitsiya_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_ispolnitel_sotrudnik_hk`
    FOREIGN KEY (`sotrudnik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: исполнитель позиции заказа';

-- Связь: платёж (заказ — способ оплаты — кассир)
CREATE TABLE IF NOT EXISTS `link_platezh` (
  `link_platezh_hk` CHAR(32) NOT NULL COMMENT 'Хеш-ключ связи',
  `zakaz_hk` CHAR(32) NOT NULL,
  `sposob_hk` CHAR(32) NOT NULL,
  `prinyal_hk` CHAR(32) NOT NULL,
  `nomer_platezha` VARCHAR(20) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_platezh_hk`),
  UNIQUE INDEX `link_platezh_uniq_UNIQUE` (`zakaz_hk` ASC, `sposob_hk` ASC, `prinyal_hk` ASC, `nomer_platezha` ASC) VISIBLE,
  INDEX `fk_link_platezh_zakaz_hk_idx` (`zakaz_hk` ASC) VISIBLE,
  INDEX `fk_link_platezh_sposob_hk_idx` (`sposob_hk` ASC) VISIBLE,
  INDEX `fk_link_platezh_prinyal_hk_idx` (`prinyal_hk` ASC) VISIBLE,
  CONSTRAINT `fk_link_platezh_zakaz_hk`
    FOREIGN KEY (`zakaz_hk`) REFERENCES `hub_zakaz` (`zakaz_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_platezh_sposob_hk`
    FOREIGN KEY (`sposob_hk`) REFERENCES `hub_sposob_oplaty` (`sposob_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_link_platezh_prinyal_hk`
    FOREIGN KEY (`prinyal_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Связь: платёж (заказ — способ оплаты — кассир)';


-- =====================================================================
-- SATELLITES (описательные атрибуты с историей)
-- =====================================================================

-- Сателлит категории услуг
CREATE TABLE IF NOT EXISTS `sat_kategoriya` (
  `kategoriya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `opisanie` VARCHAR(255) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`kategoriya_hk`, `load_date`),
  CONSTRAINT `fk_sat_kategoriya_kategoriya_hk`
    FOREIGN KEY (`kategoriya_hk`) REFERENCES `hub_kategoriya` (`kategoriya_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит категории услуг';

-- Сателлит статуса заказа
CREATE TABLE IF NOT EXISTS `sat_status` (
  `status_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `konechnyy` TINYINT(1) NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`status_hk`, `load_date`),
  CONSTRAINT `fk_sat_status_status_hk`
    FOREIGN KEY (`status_hk`) REFERENCES `hub_status` (`status_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит статуса заказа';

-- Сателлит пункта приёма
CREATE TABLE IF NOT EXISTS `sat_punkt` (
  `punkt_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `adres` VARCHAR(255) NOT NULL,
  `telefon` VARCHAR(15) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`punkt_hk`, `load_date`),
  CONSTRAINT `fk_sat_punkt_punkt_hk`
    FOREIGN KEY (`punkt_hk`) REFERENCES `hub_punkt` (`punkt_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит пункта приёма';

-- Сателлит клиента
CREATE TABLE IF NOT EXISTS `sat_klient` (
  `klient_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `imya` VARCHAR(45) NOT NULL,
  `familiya` VARCHAR(45) NOT NULL,
  `otchestvo` VARCHAR(45) NULL,
  `email` VARCHAR(60) NULL,
  `adres` VARCHAR(255) NULL,
  `data_registratsii` DATE NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`klient_hk`, `load_date`),
  CONSTRAINT `fk_sat_klient_klient_hk`
    FOREIGN KEY (`klient_hk`) REFERENCES `hub_klient` (`klient_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит клиента';

-- Сателлит сотрудника
CREATE TABLE IF NOT EXISTS `sat_sotrudnik` (
  `sotrudnik_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `imya` VARCHAR(45) NOT NULL,
  `familiya` VARCHAR(45) NOT NULL,
  `otchestvo` VARCHAR(45) NULL,
  `data_priema` DATE NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`sotrudnik_hk`, `load_date`),
  CONSTRAINT `fk_sat_sotrudnik_sotrudnik_hk`
    FOREIGN KEY (`sotrudnik_hk`) REFERENCES `hub_sotrudnik` (`sotrudnik_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит сотрудника';

-- Сателлит услуги
CREATE TABLE IF NOT EXISTS `sat_usluga` (
  `usluga_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `tsena` DECIMAL(10,2) NOT NULL,
  `srok_dney` SMALLINT NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`usluga_hk`, `load_date`),
  CONSTRAINT `fk_sat_usluga_usluga_hk`
    FOREIGN KEY (`usluga_hk`) REFERENCES `hub_usluga` (`usluga_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит услуги';

-- Сателлит заказа
CREATE TABLE IF NOT EXISTS `sat_zakaz` (
  `zakaz_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `data_sozdaniya` DATETIME NOT NULL,
  `plan_data` DATE NOT NULL,
  `fakt_data` DATE NULL,
  `primechanie` VARCHAR(255) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`zakaz_hk`, `load_date`),
  CONSTRAINT `fk_sat_zakaz_zakaz_hk`
    FOREIGN KEY (`zakaz_hk`) REFERENCES `hub_zakaz` (`zakaz_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит заказа';

-- Сателлит позиции заказа
CREATE TABLE IF NOT EXISTS `sat_pozitsiya_zakaza` (
  `link_pozitsiya_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `kolichestvo` SMALLINT NOT NULL,
  `tsena_fiks` DECIMAL(10,2) NOT NULL,
  `primechanie` VARCHAR(255) NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_pozitsiya_hk`, `load_date`),
  CONSTRAINT `fk_sat_pozitsiya_zakaza_link_pozitsiya_hk`
    FOREIGN KEY (`link_pozitsiya_hk`) REFERENCES `link_pozitsiya_zakaza` (`link_pozitsiya_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит позиции заказа';

-- Сателлит платежа
CREATE TABLE IF NOT EXISTS `sat_platezh` (
  `link_platezh_hk` CHAR(32) NOT NULL,
  `load_date` DATETIME NOT NULL,
  `load_end_date` DATETIME NULL,
  `hash_diff` CHAR(32) NOT NULL,
  `summa` DECIMAL(10,2) NOT NULL,
  `data_platezha` DATETIME NOT NULL,
  `record_source` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`link_platezh_hk`, `load_date`),
  CONSTRAINT `fk_sat_platezh_link_platezh_hk`
    FOREIGN KEY (`link_platezh_hk`) REFERENCES `link_platezh` (`link_platezh_hk`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  COMMENT = 'Сателлит платежа';


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
