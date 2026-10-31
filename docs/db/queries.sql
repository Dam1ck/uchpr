-- ============================================================
--  Магазин обуви «Шаг» · SQL-запросы для приложения (queries.sql)
--  Знак ? — параметр, который в C#-коде подставляется из формы.
--  В Workbench для проверки замените ? на реальное значение.
--  Номера в скобках — пункты чек-листа ДЭ.
-- ============================================================
USE `shoe_shop`;

-- ------------------------------------------------------------
-- 1. Вход в приложение (2.5, 2.6, 3.17)
--    пусто -> «неверный логин/пароль»; 1 строка -> ФИО и роль для шапки окна
-- ------------------------------------------------------------
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;

-- проверка на реальном пользователе (должна вернуться ровно 1 строка):
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = '94d5ous@gmail.com' AND u.password = 'uzWC67';

-- ------------------------------------------------------------
-- 2. Каталог товаров — окно Гостя и Администратора (2.7–2.11)
--    JOIN подтягивает названия вместо голых id
-- ------------------------------------------------------------
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories    c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers     s ON s.id = p.supplier_id;

-- ------------------------------------------------------------
-- 3. Поиск + фильтр + сортировка одновременно (3.2–3.6)
--    Условия WHERE/ORDER BY добавляются по необходимости:
--    убрали условие — осталось одно поведение (только поиск, только фильтр…)
-- ------------------------------------------------------------
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories    c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers     s ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%')   -- поиск по названию (3.2)
  AND p.supplier_id = ?                 -- фильтр по поставщику (3.4–3.5)
ORDER BY p.stock_qty DESC;              -- сортировка по остатку (3.2–3.3); ASC — по возрастанию

-- ------------------------------------------------------------
-- 4. Форма добавления / редактирования товара (3.7, 3.10, 3.12, 3.19)
-- ------------------------------------------------------------
-- справочники для выпадающих списков
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- добавление товара
INSERT INTO products
  (article, name, unit, price, discount, stock_qty, description, photo,
   category_id, manufacturer_id, supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- открыть товар для редактирования — заполнить все поля формы сразу
SELECT * FROM products WHERE id = ?;

-- сохранить изменения
UPDATE products
SET article = ?, name = ?, unit = ?, price = ?, discount = ?, stock_qty = ?,
    description = ?, photo = ?,
    category_id = ?, manufacturer_id = ?, supplier_id = ?
WHERE id = ?;

-- ------------------------------------------------------------
-- 5. Защита от удаления купленного товара (3.16)
-- ------------------------------------------------------------
-- сколько раз товар встречается в заказах (> 0 -> показать предупреждение)
SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = ?;

-- удаление: если товар есть в заказах, СУБД откажет —
-- «Cannot delete or update a parent row: a foreign key constraint fails»
-- (связь prodorders -> products без CASCADE, пара 10)
DELETE FROM products WHERE id = ?;
