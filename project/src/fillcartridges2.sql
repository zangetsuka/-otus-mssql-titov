IF OBJECT_ID('tempdb..#TempPrintCart') IS NOT NULL
    DROP TABLE #TempPrintCart;

CREATE TABLE #TempPrintCart (
    Модель NVARCHAR(255),
    Картридж NVARCHAR(255)
);

BULK INSERT #TempPrintCart
FROM 'C:\Users\Администратор\Documents\csv_output\printcart.csv'
WITH (
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    DATAFILETYPE = 'char'
);
-- Добавляем картриджи, используя данные из файла
INSERT INTO Картридж (название, модель, принтер_id)
SELECT 
    pc.Картридж AS название,
    pc.Модель AS модель,
    p.id AS принтер_id
FROM Принтер p
JOIN #TempPrintCart pc ON p.модель = pc.Модель;

-- Добавляем картриджи в таблицу расходных материалов
INSERT INTO Расходные_материалы (название, категория, количество, картридж_id, принтер_id)
SELECT 
    pc.Картридж AS название,
    N'Картридж' AS категория,
    2 AS количество,  -- Например, 2 картриджа на принтер
    c.id AS картридж_id,
    p.id AS принтер_id
FROM Принтер p
JOIN #TempPrintCart pc ON p.модель = pc.Модель
JOIN Картридж c ON p.id = c.принтер_id;

-- Добавляем фотобарабаны в таблицу расходных материалов
INSERT INTO Расходные_материалы (название, категория, количество, картридж_id, принтер_id)
SELECT 
    CONCAT(p.модель, ' Фотобарабан') AS название,
    N'Фотобарабан' AS категория,
    1 AS количество,  -- Обычно 1 фотобарабан на принтер
    NULL AS картридж_id,  -- Для фотобарабана картридж не нужен
    p.id AS принтер_id
FROM Принтер p;