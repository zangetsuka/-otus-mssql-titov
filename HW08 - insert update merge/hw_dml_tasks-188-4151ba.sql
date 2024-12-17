/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
SELECT * 
FROM sys.spatial_reference_systems;

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO Sales.Customers 
(CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID,
DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber,
FaxNumber, DeliveryRun, RunPosition, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1,
PostalAddressLine2, PostalPostalCode, LastEditedBy)
VALUES
(NEXT VALUE FOR Sequences.CustomerID, 'Ivanov1', 1061, 5, NULL, 3261, NULL, 3, 19881, 19881, 1600.00, '2016-05-07', 0.000, 0, 0, 7, '(206) 555-0100', '(206) 555-0101', 
NULL, NULL, 'http://www.microsoft.com/', 'Shop 12', '652 Victoria Lane', '90243', geography::STGeomFromText('POINT(23.71622 37.97945)', 4120), 
'PO Box 8112', 'Milicaville', '90243', 1),
(NEXT VALUE FOR Sequences.CustomerID, 'Captain Crunch', 1061, 5, NULL, 3261, NULL, 3, 19881, 19881, 1800.00, '2016-06-01', 0.000, 0, 0, 7, '(207) 555-0200', '(207) 555-0201', 
NULL, NULL, 'http://www.example.com/', 'Shop 14', '650 Sunset Avenue', '90244', geography::STGeomFromText('POINT(23.71800 37.97890)', 4120), 
'PO Box 8222', 'Milicaville', '90244', 1),
(NEXT VALUE FOR Sequences.CustomerID, 'Sir Laugh-a-Lot', 1061, 5, NULL, 3261, NULL, 3, 19881, 19881, 1900.00, '2016-06-05', 0.000, 0, 0, 7, '(208) 555-0300', '(208) 555-0301', 
NULL, NULL, 'http://www.example.org/', 'Shop 16', '648 Ocean Boulevard', '90245', geography::STGeomFromText('POINT(23.71950 37.97785)', 4120), 
'PO Box 8333', 'Milicaville', '90245', 1),
(NEXT VALUE FOR Sequences.CustomerID, 'The Mighty Shopper', 1061, 5, NULL, 3261, NULL, 3, 19881, 19881, 2000.00, '2016-06-10', 0.000, 0, 0, 7, '(209) 555-0400', '(209) 555-0401', 
NULL, NULL, 'http://www.example.net/', 'Shop 18', '646 Forest Road', '90246', geography::STGeomFromText('POINT(23.72100 37.97675)', 4120), 
'PO Box 8444', 'Milicaville', '90246', 1),
(NEXT VALUE FOR Sequences.CustomerID, 'Princess Bargain', 1061, 5, NULL, 3261, NULL, 3, 19881, 19881, 2100.00, '2016-06-15', 0.000, 0, 0, 7, '(210) 555-0500', '(210) 555-0501', 
NULL, NULL, 'http://www.example.biz/', 'Shop 20', '644 Greenway Drive', '90247', geography::STGeomFromText('POINT(23.72250 37.97560)', 4120), 
'PO Box 8555', 'Milicaville', '90247', 1);
/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM	Sales.Customers
	WHERE CustomerName = 'Captain Crunch' 


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers
SET CustomerName = 'Sir Giggle-a-Lot'
WHERE CustomerName = 'Sir Laugh-a-Lot';

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

DECLARE @CustomerID INT = 5556,
        @CustomerName NVARCHAR(100) = 'Sidorov',
        @BillToCustomerID INT = 5556,
        @CustomerCategoryID INT = 3,
        @PostalCityID INT = 1,   
        @DeliveryCityID INT = 1, 
        @DeliveryMethodID INT = 1,  
        @PrimaryContactPersonID INT = 1001;  

MERGE Sales.Customers AS target
USING (SELECT 
            @CustomerID AS CustomerID, 
            @CustomerName AS CustomerName, 
            @BillToCustomerID AS BillToCustomerID, 
            @CustomerCategoryID AS CustomerCategoryID,
            @PostalCityID AS PostalCityID,
            @DeliveryCityID AS DeliveryCityID,
            @DeliveryMethodID AS DeliveryMethodID,
            @PrimaryContactPersonID AS PrimaryContactPersonID)  
AS source (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PostalCityID, DeliveryCityID, DeliveryMethodID, PrimaryContactPersonID)

-- Сравниваем записи по уникальному CustomerID
ON (target.CustomerID = source.CustomerID)  

-- Если запись существует, обновляем ее
WHEN MATCHED THEN
    UPDATE SET 
        target.CustomerName = source.CustomerName,
        target.BillToCustomerID = source.BillToCustomerID,
        target.CustomerCategoryID = source.CustomerCategoryID,
        target.PostalCityID = source.PostalCityID,
        target.DeliveryCityID = source.DeliveryCityID,
        target.DeliveryMethodID = source.DeliveryMethodID,
        target.PrimaryContactPersonID = source.PrimaryContactPersonID

-- Если записи нет, вставляем новую
WHEN NOT MATCHED THEN
    INSERT (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, 
            PostalCityID, DeliveryCityID, DeliveryMethodID, PrimaryContactPersonID, BuyingGroupID, AlternateContactPersonID, 
            CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, 
            PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL, 
            DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, 
            DeliveryLocation, PostalAddressLine1, PostalAddressLine2, 
            PostalPostalCode, LastEditedBy)
    VALUES (@CustomerID, @CustomerName, @BillToCustomerID, @CustomerCategoryID, 
            @PostalCityID, @DeliveryCityID, @DeliveryMethodID, @PrimaryContactPersonID, NULL, NULL, 
            1600.00, '2016-05-07', 0.000, 0, 0, 7, 
            '(206) 555-0100', '(206) 555-0101', NULL, NULL, 
            'http://www.microsoft.com/', 'Shop 12', '652 Victoria Lane', 90243, 
            0xE6100000010C11154FE2182D4740159ADA087A035FC0, 'PO Box 8112', 'Milicaville', 90243, 1)

OUTPUT deleted.*, $action, inserted.*;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

bcp "USE WideWorldImporters; SELECT * FROM Sales.Customers" queryout "C:\SQL2022\customers_data.dat" -c -t, -S WIN-IKGEK7F7TQ9\SQLOTUS -U sa -P GHsW2P12#@!2024



-- Удаляем таблицу, если она существует
DROP TABLE IF EXISTS TempCustomers;

-- Создание временной таблицы для загрузки данных
CREATE TABLE TempCustomers (
    CustomerID INT, -- ID клиента
    CustomerName NVARCHAR(255), -- Имя клиента
    BillToCustomerID NVARCHAR(50) -- Временно используем NVARCHAR для преобразования
);

-- Шаг 2: BULK INSERT данных из файла
BULK INSERT TempCustomers
FROM 'C:\SQL2022\customers_data.dat'
WITH (
    FIELDTERMINATOR = ',', -- Разделитель колонок
    ROWTERMINATOR = '\n',  -- Разделитель строк
    FIRSTROW = 2,          -- Пропускаем заголовок
    CODEPAGE = '65001'     -- Указываем UTF-8
);

-- Шаг 3: Проверка данных на некорректные значения
SELECT *
FROM TempCustomers
WHERE ISNUMERIC(BillToCustomerID) = 0;

-- Преобразование данных и загрузка в основную таблицу, исключая некорректные строки
INSERT INTO Sales.Customers (CustomerID, CustomerName, BillToCustomerID)
SELECT
    CustomerID,
    CustomerName,
    CASE 
        WHEN ISNUMERIC(BillToCustomerID) = 1 THEN CAST(BillToCustomerID AS INT) -- Преобразуем в INT
        ELSE NULL -- Если некорректные данные, ставим NULL
    END AS BillToCustomerID
FROM TempCustomers;

--Что-то немогу понять почему не импортируется никак... 



