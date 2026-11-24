-- =====================================================================
-- Лабораторная работа №2. Создание запросов. Вариант 7
-- Таблицы: products (Товар), order_items (Содержимое заказов)
-- Страна "Russia" = отечественный товар, остальные = зарубежный
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. ПОДГОТОВКА ДАННЫХ (выполнить ОДИН раз)
-- ---------------------------------------------------------------------

-- Для задания 5 нужны товары без производителя
ALTER TABLE products ALTER COLUMN manufacturer DROP NOT NULL;

-- Дополнительные товары: ножницы, просроченные продукты
INSERT INTO products
(product_name, units_per_pack, color, specifications, country, manufacturer, expiration_date)
VALUES
('Scissors office', 12, 'Orange', 'Plastic handles, 17 cm', 'Russia', 'Erich Krause', NULL),
('Scissors office', 12, 'Orange', 'Plastic handles, 21 cm', 'Russia', NULL,           NULL),
('Scissors office', 12, 'Orange', 'Plastic handles, 13 cm', 'China',  'Deli',        NULL),
('Scissors office', 12, 'Green',  'Metal handles, 21 cm',    'Russia', 'Hatber',      NULL),
('Yogurt',          12, 'White',  '125 g',                   'Russia', 'Danone',      '2026-10-15'),
('Cottage cheese',  10, 'White',  '200 g',                   'Russia', 'Prostokvashino', '2026-11-10');

-- Заказы с новыми товарами (код товара берем по названию и характеристикам)
INSERT INTO order_items (order_number, product_id, quantity, package)
SELECT 1007, product_id, 5, 'Box' FROM products
 WHERE product_name = 'Scissors office' AND specifications = 'Plastic handles, 17 cm';
INSERT INTO order_items (order_number, product_id, quantity, package)
SELECT 1008, product_id, 3, 'Box' FROM products
 WHERE product_name = 'Scissors office' AND specifications = 'Plastic handles, 21 cm';
INSERT INTO order_items (order_number, product_id, quantity, package)
SELECT 1008, product_id, 2, 'Pack' FROM products
 WHERE product_name = 'Scissors office' AND specifications = 'Plastic handles, 13 cm';
INSERT INTO order_items (order_number, product_id, quantity, package)
SELECT 1009, product_id, 4, 'Box' FROM products
 WHERE product_name = 'Scissors office' AND specifications = 'Metal handles, 21 cm';
INSERT INTO order_items (order_number, product_id, quantity, package)
SELECT 1009, product_id, 6, 'Box' FROM products WHERE product_name = 'Yogurt';


-- ---------------------------------------------------------------------
-- 1. Выбрать товар, у которого закончился срок годности
--    (функция CURRENT_DATE - текущая дата)
-- ---------------------------------------------------------------------
SELECT *
FROM products
WHERE expiration_date < CURRENT_DATE;


-- ---------------------------------------------------------------------
-- 2. Выбрать все ножницы с пластмассовыми ручками оранжевого цвета
-- ---------------------------------------------------------------------
SELECT *
FROM products
WHERE product_name ILIKE 'Scissors%'
  AND color = 'Orange'
  AND specifications ILIKE '%plastic handles%';


-- ---------------------------------------------------------------------
-- 3. Создать таблицу с данными 2 запроса с указанием номеров заказов
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS scissors_orders;

SELECT p.product_id, p.product_name, p.units_per_pack, p.color,
       p.specifications, p.country, p.manufacturer, p.expiration_date,
       oi.order_number
INTO scissors_orders
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
WHERE p.product_name ILIKE 'Scissors%'
  AND p.color = 'Orange'
  AND p.specifications ILIKE '%plastic handles%';

SELECT * FROM scissors_orders;


-- ---------------------------------------------------------------------
-- 4. Добавить в созданную таблицу номера заказов, содержащих любые
--    канцтовары (Insert ... Select)
--    Канцтовары: тетради, ручки, ножницы, карандаши, линейки
-- ---------------------------------------------------------------------
INSERT INTO scissors_orders
       (product_id, product_name, units_per_pack, color, specifications,
        country, manufacturer, expiration_date, order_number)
SELECT p.product_id, p.product_name, p.units_per_pack, p.color,
       p.specifications, p.country, p.manufacturer, p.expiration_date,
       oi.order_number
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
WHERE (p.product_name ILIKE 'Notebook%'
    OR p.product_name ILIKE 'Ballpoint pen%'
    OR p.product_name ILIKE 'Scissors%'
    OR p.product_name ILIKE 'Pencil%'
    OR p.product_name ILIKE 'Ruler%')
  AND NOT EXISTS (SELECT 1
                  FROM scissors_orders s
                  WHERE s.product_id = p.product_id
                    AND s.order_number = oi.order_number);

SELECT * FROM scissors_orders ORDER BY order_number;


-- ---------------------------------------------------------------------
-- 5. В созданной таблице для каждого товара, у которого не указан
--    производитель, изменить цвет на черный (Update)
-- ---------------------------------------------------------------------
UPDATE scissors_orders
SET color = 'Black'
WHERE manufacturer IS NULL;

SELECT * FROM scissors_orders ORDER BY order_number;


-- ---------------------------------------------------------------------
-- 6. Удалить из созданной таблицы весь товар зарубежного производства
--    (Delete)
-- ---------------------------------------------------------------------
DELETE FROM scissors_orders
WHERE country <> 'Russia';

SELECT * FROM scissors_orders ORDER BY order_number;


-- ---------------------------------------------------------------------
-- 7. Посчитать количество наименований товара для каждого
--    отечественного производителя
--    (агрегатная функция COUNT)
-- ---------------------------------------------------------------------
SELECT manufacturer,
       COUNT(DISTINCT product_name) AS product_names_count
FROM products
WHERE country = 'Russia'
  AND manufacturer IS NOT NULL
GROUP BY manufacturer
ORDER BY manufacturer;
