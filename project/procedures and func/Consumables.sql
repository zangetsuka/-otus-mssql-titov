CREATE PROCEDURE GetConsumablesByPrinter
    @Принтер NVARCHAR(255), -- Название принтера
    @Отдел NVARCHAR(255)    -- Название отдела
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        rm.название AS Расходный_Материал, 
        rm.категория, 
        rm.количество, 
        p.название AS Принтер, 
        n.название AS Отдел
    FROM Расходные_материалы rm
    JOIN Принтер p ON rm.принтер_id = p.id
    JOIN Отдел o ON p.отдел_id = o.id
    JOIN Названия_Отделов n ON o.название_id = n.id
    WHERE p.название = @Принтер
      AND n.название = @Отдел;
END;
