USE PrinterTrack
GO

CREATE INDEX IX_Сотрудник_ФИО
ON Сотрудник (ФИО);
CREATE INDEX IX_Принтер_Модель
ON Принтер (модель);
CREATE INDEX IX_Запросы_Тип_Статус
ON Запросы (тип_запроса, статус);
CREATE INDEX IX_Расходные_материалы_Название
ON Расходные_материалы (название, принтер_id);
CREATE INDEX IX_Отдел_Название
ON Отдел (название_id, организация_id);

GO