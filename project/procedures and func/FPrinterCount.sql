CREATE FUNCTION GetPrinterCountByDepartment
(
    @Название_Отдела NVARCHAR(255),
    @Название_Организации NVARCHAR(255)
)
RETURNS INT
AS
BEGIN
    DECLARE @PrinterCount INT;

    SELECT @PrinterCount = COUNT(*)
    FROM Принтер p
    JOIN Отдел o ON p.отдел_id = o.id
    JOIN Названия_Отделов n ON o.название_id = n.id
    JOIN Организация org ON o.организация_id = org.id
    WHERE n.название = @Название_Отдела AND org.название = @Название_Организации;

    RETURN @PrinterCount;
END;
