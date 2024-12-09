USE PrinterTrack
GO

CREATE PROCEDURE UpdatePrinter
    @Название NVARCHAR(255),      -- Наименование принтера
    @Новый_IP NVARCHAR(50) = NULL, -- Новый IP-адрес (по умолчанию NULL)
    @Новый_Отдел NVARCHAR(255) = NULL -- Новый отдел (по умолчанию NULL)
AS
BEGIN
    SET NOCOUNT ON;

    -- Обновление IP-адреса, если он указан
    IF @Новый_IP IS NOT NULL
    BEGIN
        UPDATE Принтер
        SET ip_адрес = @Новый_IP
        WHERE название = @Название;
    END

    -- Обновление отдела, если он указан
    IF @Новый_Отдел IS NOT NULL
    BEGIN
        DECLARE @Новый_Отдел_ID INT;

        SELECT @Новый_Отдел_ID = o.id
        FROM Отдел o
        JOIN Названия_Отделов n ON o.название_id = n.id
        WHERE n.название = @Новый_Отдел;

        IF @Новый_Отдел_ID IS NULL
        BEGIN
            PRINT 'Отдел не найден!';
            RETURN;
        END

        UPDATE Принтер
        SET отдел_id = @Новый_Отдел_ID
        WHERE название = @Название;
    END

    PRINT 'Информация о принтере успешно обновлена!';
END;

GO
