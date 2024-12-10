ALTER PROCEDURE AddEmployee
    @ФИО NVARCHAR(255),               
    @должность NVARCHAR(255),         
    @отдел_название NVARCHAR(255),    
    @организация_название NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @отдел_id INT;
    DECLARE @организация_id INT;

    -- Получение ID организации
    SELECT @организация_id = id
    FROM Организация
    WHERE название = @организация_название;

    IF @организация_id IS NULL
    BEGIN
        PRINT 'Организация не найдена!';
        RETURN;
    END;

    -- Получение ID отдела
    SELECT @отдел_id = id
    FROM Отдел
    WHERE название_id = (SELECT id FROM Названия_Отделов WHERE название = @отдел_название)
      AND организация_id = @организация_id;

    IF @отдел_id IS NOT NULL
    BEGIN
        -- Проверка на дублирование
        IF EXISTS (
            SELECT 1 
            FROM Сотрудник
            WHERE ФИО = @ФИО AND должность = @должность AND отдел_id = @отдел_id
        )
        BEGIN
            PRINT 'Сотрудник уже существует!';
        END
        ELSE
        BEGIN
            -- Добавление сотрудника
            INSERT INTO Сотрудник (ФИО, должность, отдел_id)
            VALUES (@ФИО, @должность, @отдел_id);

            PRINT 'Сотрудник добавлен успешно!';
        END
    END
    ELSE
    BEGIN
        PRINT 'Отдел не найден!';
    END;
END;
GO
