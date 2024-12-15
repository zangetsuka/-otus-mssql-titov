/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

USE WideWorldImporters;
GO

-- Создание функции для нахождения клиента с наибольшей суммой покупки
CREATE OR ALTER FUNCTION Sales.TopSpender()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        cust.CustomerID,
        cust.CustomerName,
        SUM(line.Quantity * line.UnitPrice) AS TotalPurchase
    FROM Sales.Invoices AS inv
    INNER JOIN Sales.InvoiceLines AS line ON inv.InvoiceID = line.InvoiceID
    INNER JOIN Sales.Customers AS cust ON cust.CustomerID = inv.CustomerID
    GROUP BY cust.CustomerID, cust.CustomerName
    ORDER BY TotalPurchase DESC
);
GO

SELECT * FROM Sales.TopSpender();

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

-- Создание хранимой процедуры для получения суммы покупок клиента
CREATE OR ALTER PROCEDURE Sales.GetCustomerTotalPurchase
    @CustomerID INT
AS
BEGIN
    SELECT 
        cust.CustomerID,
        cust.CustomerName,
        SUM(line.Quantity * line.UnitPrice) AS TotalPurchase
    FROM Sales.Invoices AS inv
    INNER JOIN Sales.InvoiceLines AS line ON inv.InvoiceID = line.InvoiceID
    INNER JOIN Sales.Customers AS cust ON cust.CustomerID = inv.CustomerID
    WHERE cust.CustomerID = @CustomerID
    GROUP BY cust.CustomerID, cust.CustomerName;
END;
GO

-- Пример вызова процедуры
EXEC Sales.GetCustomerTotalPurchase @CustomerID = 1;

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

-- Создание функции для получения суммы покупок клиента для сравнения.
CREATE OR ALTER FUNCTION Sales.GetCustomerTotalPurchaseFunc(@CustomerID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        cust.CustomerID,
        cust.CustomerName,
        SUM(line.Quantity * line.UnitPrice) AS TotalPurchase
    FROM Sales.Invoices AS inv
    INNER JOIN Sales.InvoiceLines AS line ON inv.InvoiceID = line.InvoiceID
    INNER JOIN Sales.Customers AS cust ON cust.CustomerID = inv.CustomerID
    WHERE cust.CustomerID = @CustomerID
    GROUP BY cust.CustomerID, cust.CustomerName
);
GO

-- Сравниваем
SET STATISTICS TIME ON;

SELECT * FROM Sales.GetCustomerTotalPurchaseFunc(1);
--SQL Server parse and compile time: 
--  CPU time = 16 ms, elapsed time = 24 ms.
--(1 row affected)

 --SQL Server Execution Times:
 --CPU time = 31 ms,  elapsed time = 253 ms.
--Completion time: 2024-12-15T13:59:46.2394176+03:00

EXEC Sales.GetCustomerTotalPurchase @CustomerID = 1;

--SQL Server parse and compile time: 
--   CPU time = 0 ms, elapsed time = 0 ms.
--SQL Server parse and compile time: 
--   CPU time = 0 ms, elapsed time = 0 ms.
--(1 row affected)

-- SQL Server Execution Times:
--   CPU time = 31 ms,  elapsed time = 257 ms.
-- SQL Server Execution Times:
 --  CPU time = 31 ms,  elapsed time = 258 ms.

SET STATISTICS TIME OFF;

-- Краткое резюме по сравнению производительности:
-- 1. Хранимая процедура быстрее разбирается и компилируется, так как выполняется как отдельный объект.
-- 2. Функция лучше интегрируется в SELECT-запросы, но её выполнение может быть менее эффективным из-за необходимости оптимизировать план встраивания.
-- 3. Общее время выполнения для простых запросов сопоставимо (разница в пределах погрешности).
-- 4. Используйте процедуру для сложной бизнес-логики, а функцию — для встраивания в более сложные запросы.

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

CREATE OR ALTER FUNCTION Sales.GetCustomerTotal 
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN 
(
    SELECT 
        i.CustomerID, 
        c.CustomerName,
        SUM(il.Quantity * il.UnitPrice) AS TotalAmount
    FROM Sales.Invoices i
    INNER JOIN Sales.InvoiceLines il 
        ON i.InvoiceID = il.InvoiceID
    INNER JOIN Sales.Customers c
        ON c.CustomerID = i.CustomerID
    WHERE c.CustomerID = @CustomerID
    GROUP BY i.CustomerID, c.CustomerName
)
GO

-- Вызов функции 
SELECT 
    cust.CustomerID AS ClientID,
    cust.CustomerName AS ClientName,
    COALESCE(CustomerTotal.TotalAmount, 0) AS TotalAmount
FROM Sales.Customers cust
CROSS APPLY Sales.GetCustomerTotal(cust.CustomerID) AS CustomerTotal
ORDER BY cust.CustomerID;


/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
