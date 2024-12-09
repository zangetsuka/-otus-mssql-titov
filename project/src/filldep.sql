use PrinterTrack


CREATE TABLE Названия_Отделов (
    id INT IDENTITY PRIMARY KEY,
    название NVARCHAR(255) NOT NULL UNIQUE
);
INSERT INTO Названия_Отделов (название)
VALUES
('Отдел маркетинга'),
('Финансовый отдел'),
('Руководство'),
('Юридический отдел'),
('Отдел запасных частей'),
('Отдел сервиса автомобилей Geely'),
('Отдел продаж автомобилей Geely'),
('Отдел сервиса автомобилей Exeed'),
('Кредитный отдел'),
('Отдел продаж автомобилей с пробегом'),
('Линейный отдел'),
('Корпоративный отдел');
SELECT DISTINCT название FROM Отдел;
UPDATE Отдел
SET название_id = (SELECT id FROM Названия_Отделов WHERE Названия_Отделов.название = Отдел.название);
ALTER TABLE Отдел DROP COLUMN название;
ALTER TABLE Отдел
ADD CONSTRAINT FK_Отдел_Названия FOREIGN KEY (название_id) REFERENCES Названия_Отделов(id);