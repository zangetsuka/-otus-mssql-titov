USE PrinterTrack
ALTER DATABASE PrinterTrack SET ENABLE_BROKER;

--Создание типов сообщений
CREATE MESSAGE TYPE [RequestMessage] VALIDATION = NONE;
CREATE MESSAGE TYPE [ResponseMessage] VALIDATION = NONE;

--Создание контракта
CREATE CONTRACT [RequestProcessingContract]
([RequestMessage] SENT BY INITIATOR,
 [ResponseMessage] SENT BY TARGET);

 --Создание очередей
CREATE QUEUE [RequestQueue];
CREATE QUEUE [ResponseQueue];

--Создание сервисов
CREATE SERVICE [RequestService]
ON QUEUE [RequestQueue]
([RequestProcessingContract]);

CREATE SERVICE [ResponseService]
ON QUEUE [ResponseQueue]
([RequestProcessingContract]);



--Процедура для отправки задач в очередь
--Эта процедура добавляет заявки из таблицы Запросы в очередь для обработки.

USE PrinterTrack
GO
ALTER PROCEDURE AddRequestToQueue
    @RequestID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DialogHandle UNIQUEIDENTIFIER;

    BEGIN TRY
        -- Создание диалога
        BEGIN DIALOG CONVERSATION @DialogHandle
        FROM SERVICE [RequestService]
        TO SERVICE 'ResponseService'
        ON CONTRACT [RequestProcessingContract];

        PRINT 'Диалог создан. Handle: ' + CAST(@DialogHandle AS NVARCHAR(MAX));

        -- Отправка сообщения
        SEND ON CONVERSATION @DialogHandle
        MESSAGE TYPE [RequestMessage]
        (CAST(@RequestID AS NVARCHAR(MAX)));

        PRINT 'Сообщение отправлено для RequestID: ' + CAST(@RequestID AS NVARCHAR(MAX));
    END TRY
    BEGIN CATCH
        PRINT 'Ошибка в процедуре AddRequestToQueue: ' + ERROR_MESSAGE();
    END CATCH;
END;

GO

--Процедура для обработки задач из очереди
--Эта процедура читает сообщения из очереди и обновляет статус заявки в таблице Запросы.
USE PrinterTrack
GO
ALTER PROCEDURE ProcessRequestQueue
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MessageBody NVARCHAR(MAX);
    DECLARE @DialogHandle UNIQUEIDENTIFIER;
    DECLARE @RequestID INT;

    -- Чтение сообщений из очереди
    WHILE (1 = 1)
    BEGIN
        BEGIN TRY
            WAITFOR (
                RECEIVE TOP(1)
                    @MessageBody = CAST(message_body AS NVARCHAR(MAX)),
                    @DialogHandle = conversation_handle
                FROM [RequestQueue]
            ), TIMEOUT 5000;

            IF @@ROWCOUNT = 0
                BREAK;

            -- Логирование полученного сообщения
            PRINT 'Получено сообщение: ' + ISNULL(@MessageBody, 'NULL');

            -- Парсим RequestID из сообщения
            SET @RequestID = CAST(@MessageBody AS INT);

            -- Логирование ID запроса
            PRINT 'Обрабатываем запрос с ID: ' + CAST(@RequestID AS NVARCHAR(MAX));

            -- Логика обработки запроса
            UPDATE Запросы
            SET статус = 'Выполняется'
            WHERE id = @RequestID;

            -- Симуляция обработки задачи
            WAITFOR DELAY '00:00:05';

            UPDATE Запросы
            SET статус = 'Завершено', дата_выполнения = GETDATE()
            WHERE id = @RequestID;

            PRINT 'Запрос обработан: ' + CAST(@RequestID AS NVARCHAR(MAX));

            -- Закрытие диалога
            END CONVERSATION @DialogHandle;

            PRINT 'Диалог закрыт для RequestID: ' + CAST(@RequestID AS NVARCHAR(MAX));
        END TRY
        BEGIN CATCH
            PRINT 'Ошибка при обработке сообщения: ' + ERROR_MESSAGE();
        END CATCH;
    END;
END;
GO
--Настройка автоматической обработки
--Создал таск в задании агента периодического выполнения процедуры ProcessRequestQueue (каждые 5 мин)
--Тестирование. Добавил тестовый запрос в таблицу "Запросы" 

INSERT INTO Запросы (сотрудник_id, принтер_id, тип_запроса, комментарий, статус, дата_создания, приоритет)
VALUES (17, 48, 'Замена', 'Обновление картриджа', 'В очереди', GETDATE(), 1);

SELECT * FROM [RequestQueue];

EXEC ProcessRequestQueue;

SELECT * FROM Запросы

SELECT * FROM Запросы WHERE id = 8;
EXEC AddRequestToQueue @RequestID = 8;

SELECT CAST(message_body AS NVARCHAR(MAX)) AS MessageBody, conversation_handle
FROM RequestQueue;



--Service Broker  используется для фоновой обработки заявок из таблицы Запросы, для автоматизации обслуживания оргтехники





