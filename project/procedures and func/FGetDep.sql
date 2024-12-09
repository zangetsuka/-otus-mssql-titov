USE PrinterTrack;
GO

CREATE FUNCTION GetDepartmentID
(
    @Название_Отдела NVARCHAR(255),
    @Название_Организации NVARCHAR(255)
)
RETURNS INT
AS
BEGIN
    DECLARE @Отдел_ID INT;

    SELECT @Отдел_ID = o.id
    FROM Отдел o
    JOIN Названия_Отделов n ON o.название_id = n.id
    JOIN Организация org ON o.организация_id = org.id
    WHERE n.название = @Название_Отдела AND org.название = @Название_Организации;

    RETURN @Отдел_ID;
END;

GO