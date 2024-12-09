USE PrinterTrack
GO

CREATE PROCEDURE AddPrinter
    @Название NVARCHAR(255),         -- Наименование принтера
    @Модель NVARCHAR(255),           -- Модель принтера
    @Организация NVARCHAR(255),      -- Название организации
    @Отдел NVARCHAR(255),            -- Название отдела
    @IP_адрес NVARCHAR(50) = NULL    -- IP-адрес принтера (по умолчанию NULL)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Отдел_ID INT;
    DECLARE @Организация_ID INT;

    -- Получение ID организации
    SELECT @Организация_ID = id
    FROM Организация
    WHERE название = @Организация;

    IF @Организация_ID IS NULL
    BEGIN
        PRINT 'Организация не найдена!';
        RETURN;
    END

    -- Получение ID отдела
    SELECT @Отдел_ID = o.id
    FROM Отдел o
    JOIN Названия_Отделов n ON o.название_id = n.id
    WHERE n.название = @Отдел AND o.организация_id = @Организация_ID;

    IF @Отдел_ID IS NULL
    BEGIN
        PRINT 'Отдел не найден!';
        RETURN;
    END

    -- Добавление принтера
    INSERT INTO Принтер (название, модель, отдел_id, ip_адрес)
    VALUES (@Название, @Модель, @Отдел_ID, @IP_адрес);

    PRINT 'Принтер успешно добавлен!';
END;

GO