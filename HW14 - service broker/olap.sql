ALTER TABLE Запросы
ADD дата_выполнения DATETIME NULL;

--решил добавить окончание таска для бд
ALTER TABLE Запросы 
ADD приоритет INT NOT NULL DEFAULT 1;

-- Добавляем задачи в таблицу Запросы
INSERT INTO Запросы (сотрудник_id, принтер_id, тип_запроса, комментарий, статус, дата_создания, приоритет)
VALUES (14, 48, 'Замена', 'Обновление картриджа', 'В очереди', GETDATE(), 1);


--Процедура
CREATE PROCEDURE ProcessNextTask
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TaskID INT;

    -- Извлекаем задачу с наивысшим приоритетом
    SELECT TOP 1 @TaskID = id
    FROM Запросы
    WHERE статус = 'В очереди'
    ORDER BY приоритет DESC, дата_создания;

    -- Проверяем, есть ли задача
    IF @TaskID IS NOT NULL
    BEGIN
        -- Обновляем статус на "Выполняется"
        UPDATE Запросы
        SET статус = 'Выполняется'
        WHERE id = @TaskID;

        -- Здесь должна быть ваша логика обработки задачи

        -- После завершения обновляем статус на "Завершено"
        UPDATE Запросы
        SET статус = 'Завершено', дата_выполнения = GETDATE()
        WHERE id = @TaskID;

        PRINT 'Задача успешно обработана.';
    END
    ELSE
    BEGIN
        PRINT 'Нет задач в очереди.';
    END
END;

-- Выполняем обработку следующей задачи
EXEC ProcessNextTask;


--Проверка результата
SELECT * FROM Запросы
WHERE статус IN ('Выполняется', 'Завершено');