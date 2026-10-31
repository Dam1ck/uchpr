-- ============================================================
--  Магазин обуви «Шаг» · структура БД, версия 1 (create_v1.sql)
--  Получено из ER-модели db/магазин.mwb:
--  File -> Export -> Forward Engineer SQL CREATE Script (Ctrl+Shift+G)
--  Запускать целиком (File -> Open SQL Script -> молния).
--  Скрипт пересоздаёт схема `shoe_shop` с нуля.
-- ============================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP SCHEMA IF EXISTS `shoe_shop`;
CREATE SCHEMA IF NOT EXISTS `shoe_shop` DEFAULT CHARACTER SET utf8mb4;
USE `shoe_shop`;

-- ---------- справочники ----------
CREATE TABLE `categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `manufacturers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `suppliers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `orderstatus` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

-- ---------- товары ----------
CREATE TABLE `products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `article` VARCHAR(20) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `unit` VARCHAR(10) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `discount` INT NULL,
  `stock_qty` INT NOT NULL,
  `description` TEXT NULL,
  `photo` VARCHAR(255) NULL,
  `category_id` INT NOT NULL,
  `manufacturer_id` INT NOT NULL,
  `supplier_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_products_category_idx` (`category_id` ASC),
  INDEX `fk_products_manufacturer_idx` (`manufacturer_id` ASC),
  INDEX `fk_products_supplier_idx` (`supplier_id` ASC),
  CONSTRAINT `fk_products_category`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_manufacturer`
    FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_supplier`
    FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ---------- пользователи ----------
CREATE TABLE `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(60) NOT NULL,
  `login` VARCHAR(50) NOT NULL,
  `password` VARCHAR(30) NOT NULL,
  `role_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_role_idx` (`role_id` ASC),
  CONSTRAINT `fk_users_role`
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ---------- пункты выдачи ----------
CREATE TABLE `pvz` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `postcode` CHAR(6) NOT NULL,
  `city` VARCHAR(30) NOT NULL,
  `street` VARCHAR(30) NOT NULL,
  `house` VARCHAR(5) NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;

-- ---------- заказы ----------
CREATE TABLE `orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATETIME NOT NULL,
  `delivery_date` DATETIME NULL,
  `pvz_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `receive_code` VARCHAR(10) NOT NULL,
  `status_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_orders_pvz_idx` (`pvz_id` ASC),
  INDEX `fk_orders_user_idx` (`user_id` ASC),
  INDEX `fk_orders_status_idx` (`status_id` ASC),
  CONSTRAINT `fk_orders_pvz`
    FOREIGN KEY (`pvz_id`) REFERENCES `pvz` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_status`
    FOREIGN KEY (`status_id`) REFERENCES `orderstatus` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- ---------- состав заказа ----------
CREATE TABLE `prodorders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `qty` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_prodorders_order_idx` (`order_id` ASC),
  INDEX `fk_prodorders_product_idx` (`product_id` ASC),
  CONSTRAINT `fk_prodorders_order`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
    ON DELETE CASCADE ON UPDATE NO ACTION,   -- удалили заказ -> удалился и его состав
  CONSTRAINT `fk_prodorders_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON DELETE NO ACTION ON UPDATE NO ACTION  -- купленный товар удалить нельзя (п. 3.16)
) ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
