-- Задание 1 Выбрать всех читателей, родившихся в 1990 году и проживающих на Шипиловской улице.
SELECT *
FROM Readers
WHERE EXTRACT(YEAR FROM Birth_date) =
1990
AND (Address ILIKE 'Shipilovskaya'
OR Address ILIKE 'Шипиловская');

-- Задание 2 Выбрать телефонные номера всех читателей, фамилии которых начинаются на «А», «Б» или «В».
SELECT Last_name, Phone
FROM Readers
WHERE LEFT(Last_name, 1) IN ('A', 'B', 'V', 'А', 'Б', 'В');


-- Задание 3 Создать таблицу, содержащую данные 1 запроса, при условии, что эти читатели не пользовались абонементом
DROP TABLE IF EXISTS Readers_new;
SELECT r.*
INTO Readers_new
FROM Readers r
WHERE EXTRACT(YEAR FROM r.Birth_date) = 1990
  AND (r.Address ILIKE '%Shipilovskaya%' OR r.Address ILIKE '%Шипиловск%')
  AND NOT EXISTS (SELECT 1 FROM Loans l WHERE l.Reader_ID = r.Reader_ID);
SELECT * FROM Readers_new;


-- Задание 4 Добавить в созданную таблицу читателей, у которых нет телефона.
INSERT INTO Readers_new
SELECT *
FROM Readers
WHERE (Phone IS NULL OR TRIM(Phone) = '')
  AND Reader_ID NOT IN (SELECT Reader_ID FROM Readers_new);
SELECT * FROM Readers_new;


-- Задание 5 В созданной таблице для всех читателей, проживающих на Домодедовской улице, изменить адрес на Борисовский проезд.
UPDATE Readers_new
SET Address = 'Borisovsky proezd'
WHERE Address ILIKE '%Domodedovskaya%' OR Address ILIKE '%Домодедовск%';

SELECT * FROM Readers_new;


-- Задание 6 Удалить из созданной таблицы записи для всех читателей, у которых не указаны паспортные данные.
DELETE FROM Readers_new
WHERE Passport_data IS NULL OR TRIM(Passport_data) = '';

SELECT * FROM Readers_new;


-- Задание 7 Посчитать количество книг, взятых в библиотеке каждым из читателей
SELECT r.Reader_ID,
       r.Last_name,
       r.First_name,
       COUNT(l.Book_ID) AS books_taken
FROM Readers r
LEFT JOIN Loans l ON l.Reader_ID = r.Reader_ID
GROUP BY r.Reader_ID, r.Last_name, r.First_name
ORDER BY books_taken DESC, r.Last_name;
