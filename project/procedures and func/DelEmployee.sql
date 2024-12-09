USE PrinterTrack
GO

CREATE PROCEDURE DeleteEmployee
    @ФИО NVARCHAR(255) -- ФИО сотрудника
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Сотрудник
    WHERE ФИО = @ФИО;

    PRINT 'Сотрудник удалён.';
END;

GO