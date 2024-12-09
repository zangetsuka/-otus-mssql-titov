USE PrinterTrack;

-- Создаем таблицы
CREATE TABLE Организация (
    id INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL
);

CREATE TABLE Отдел (
    id INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    организация_id INT,
    FOREIGN KEY (организация_id) REFERENCES Организация(id) ON DELETE CASCADE
);

CREATE TABLE Сотрудник (
    id INT IDENTITY(1,1) PRIMARY KEY,
    ФИО NVARCHAR(255) NOT NULL,
    должность NVARCHAR(255),
    отдел_id INT,
    FOREIGN KEY (отдел_id) REFERENCES Отдел(id) ON DELETE SET NULL
);

CREATE TABLE Принтер (
    id INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    модель NVARCHAR(255) NOT NULL,
    отдел_id INT,
    FOREIGN KEY (отдел_id) REFERENCES Отдел(id) ON DELETE CASCADE
);

CREATE TABLE Картридж (
    id INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    модель NVARCHAR(255) NOT NULL,
    принтер_id INT,
    статус NVARCHAR(50) CHECK (статус IN ('заправлен', 'незаправлен')),
    FOREIGN KEY (принтер_id) REFERENCES Принтер(id) ON DELETE CASCADE
);

CREATE TABLE Лог_замены (
    id INT IDENTITY(1,1) PRIMARY KEY,
    картридж_id INT,
    сотрудник_id INT,
    дата_замены DATETIME DEFAULT GETDATE(),
    комментарий NVARCHAR(MAX),
    FOREIGN KEY (картридж_id) REFERENCES Картридж(id) ON DELETE CASCADE,
    FOREIGN KEY (сотрудник_id) REFERENCES Сотрудник(id) ON DELETE SET NULL
);

CREATE TABLE Расходные_материалы (
    id INT IDENTITY(1,1) PRIMARY KEY,
    название NVARCHAR(255) NOT NULL,
    категория NVARCHAR(100),
    количество INT DEFAULT 0,
    принтер_id INT,
    FOREIGN KEY (принтер_id) REFERENCES Принтер(id) ON DELETE CASCADE
);

CREATE TABLE Сервисное_обслуживание (
    id INT IDENTITY(1,1) PRIMARY KEY,
    принтер_id INT,
    дата_последнего_ТО DATE,
    дата_следующего_ТО DATE,
    комментарий NVARCHAR(MAX),
    FOREIGN KEY (принтер_id) REFERENCES Принтер(id) ON DELETE CASCADE
);

CREATE TABLE Логи (
    id INT IDENTITY(1,1) PRIMARY KEY,
    сотрудник_id INT,
    действие NVARCHAR(MAX),
    дата_времени DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (сотрудник_id) REFERENCES Сотрудник(id) ON DELETE SET NULL
);

CREATE TABLE Запросы (
    id INT IDENTITY(1,1) PRIMARY KEY,
    сотрудник_id INT,
    тип_запроса NVARCHAR(50) CHECK (тип_запроса IN ('Заправка', 'Ремонт')),
    принтер_id INT,
    комментарий NVARCHAR(MAX),
    статус NVARCHAR(50) DEFAULT 'Ожидает обработки',
    дата_создания DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (сотрудник_id) REFERENCES Сотрудник(id) ON DELETE SET NULL,
    FOREIGN KEY (принтер_id) REFERENCES Принтер(id) ON DELETE CASCADE
);
