USE PrinterTrack;
GO

CREATE FUNCTION GetOrganizationByDepartment
(
    @Название_Отдела NVARCHAR(255) -- Название отдела
)
RETURNS NVARCHAR(255)
AS
BEGIN
    DECLARE @Organization NVARCHAR(255); -- Переменная для хранения результата

    -- Получение названия организации по названию отдела
    SELECT @Organization = org.название
    FROM Отдел o
    JOIN Названия_Отделов n ON o.название_id = n.id
    JOIN Организация org ON o.организация_id = org.id
    WHERE n.название = @Название_Отдела;

    RETURN @Organization; -- Возвращаем название организации
END;
GO
