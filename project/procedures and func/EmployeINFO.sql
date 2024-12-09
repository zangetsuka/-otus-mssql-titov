USE PrinterTrack
GO

CREATE PROCEDURE GetEmployeesByDepartment
    @Организация NVARCHAR(255), -- Название организации
    @Отдел NVARCHAR(255)        -- Название отдела
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.ФИО, s.должность, o.id AS Отдел_ID, n.название AS Название_Отдела, org.название AS Организация
    FROM Сотрудник s
    JOIN Отдел o ON s.отдел_id = o.id
    JOIN Названия_Отделов n ON o.название_id = n.id
    JOIN Организация org ON o.организация_id = org.id
    WHERE org.название = @Организация AND n.название = @Отдел;
END;
GO