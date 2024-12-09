CREATE FUNCTION GetTotalConsumables
(
    @Принтер NVARCHAR(255), -- Название принтера
    @Отдел NVARCHAR(255)    -- Название отдела
)
RETURNS INT
AS
BEGIN
    DECLARE @Total INT;

    SELECT @Total = SUM(rm.количество)
    FROM Расходные_Материалы rm
    JOIN Принтер p ON rm.принтер_id = p.id
    JOIN Отдел o ON p.отдел_id = o.id
    JOIN Названия_Отделов n ON o.название_id = n.id
    WHERE p.название = @Принтер
      AND n.название = @Отдел;

    RETURN ISNULL(@Total, 0); -- Возвращаем 0, если записей не найдено
END;
