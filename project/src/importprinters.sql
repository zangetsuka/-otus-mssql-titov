IF OBJECT_ID('tempdb..#TempPrinters') IS NOT NULL
    DROP TABLE #TempPrinters;

CREATE TABLE #TempPrinters (
    Наименование NVARCHAR(255),
    Организация NVARCHAR(255),
    Производитель NVARCHAR(255),
    Модель NVARCHAR(255),
    Отдел NVARCHAR(255),
    Картридж NVARCHAR(255),
    IP_адрес NVARCHAR(50)
);
BULK INSERT #TempPrinters
FROM 'C:\Users\Администратор\Documents\csv_output\printers.csv'
WITH (
    FIELDTERMINATOR = '~',  -- Указываем новый разделитель
    ROWTERMINATOR = '\n',   -- Конец строки
    FIRSTROW = 2,          -- Пропуск первой строки (заголовок)
    CODEPAGE = '65001',    -- Для кодировки UTF-8
    DATAFILETYPE = 'char'  -- Тип данных
);
INSERT INTO Принтер (название, модель, отдел_id, IP_адрес)
SELECT 
    t.Наименование AS название,
    t.Модель AS модель,
    o.id AS отдел_id,
    t.IP_адрес
FROM #TempPrinters t
JOIN Отдел o
    ON o.название_id = (SELECT id FROM Названия_Отделов WHERE название = t.Отдел)
   AND o.организация_id = (SELECT id FROM Организация WHERE название = t.Организация);