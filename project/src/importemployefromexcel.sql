-- Шаг 1: Создаем временную таблицу для импорта данных
CREATE TABLE #TempEmployees (
    ФИО NVARCHAR(255),
    Должность NVARCHAR(255),
    Название_Отдела NVARCHAR(255),
    Название_Организации NVARCHAR(255)
);

-- Шаг 2: Импортируем данные из CSV
BULK INSERT #TempEmployees
FROM 'C:\Users\Администратор\Documents\csv_output\employe.csv'
WITH (
    FIELDTERMINATOR = ';', -- Указание разделителя между полями
    ROWTERMINATOR = '\n',  -- Указание разделителя строк
    FIRSTROW = 2,          -- Пропускаем заголовок
    CODEPAGE = '65001',    -- Поддержка UTF-8
    DATAFILETYPE = 'char'  -- Указание текстового формата файла
);

-- Шаг 3: Переносим данные в таблицу Сотрудник, исключая дубликаты
INSERT INTO Сотрудник (ФИО, должность, отдел_id)
SELECT 
    t.ФИО,
    t.Должность,
    o.id AS отдел_id
FROM 
    #TempEmployees t
JOIN 
    Отдел o 
    ON o.название_id = (SELECT id FROM Названия_Отделов WHERE название = t.Название_Отдела)
    AND o.организация_id = (SELECT id FROM Организация WHERE название = t.Название_Организации)
WHERE NOT EXISTS (
    SELECT 1 
    FROM Сотрудник s
    WHERE s.ФИО = t.ФИО 
      AND s.должность = t.Должность 
      AND s.отдел_id = o.id
);

-- Шаг 4: Удаляем временную таблицу
DROP TABLE #TempEmployees;
