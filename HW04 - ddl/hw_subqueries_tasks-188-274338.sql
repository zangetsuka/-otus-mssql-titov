/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

TODO: 
SELECT
    P.PersonID,
    P.FullName
FROM
    Application.People P
WHERE
    P.IsSalesPerson = 1
    AND P.PersonID NOT IN (
        SELECT
            I.SalespersonPersonID
        FROM
            Sales.Invoices I
        WHERE
            I.InvoiceDate = '2015-07-04'
    );

	/*2. Вариант через WITH (CTE)*/

WITH SalesOnDate AS (
    SELECT DISTINCT
        I.SalespersonPersonID
    FROM
        Sales.Invoices I
    WHERE
        I.InvoiceDate = '2015-07-04'
)
SELECT
    P.PersonID,
    P.FullName
FROM
    Application.People P
LEFT JOIN
    SalesOnDate S ON P.PersonID = S.SalespersonPersonID
WHERE
    P.IsSalesPerson = 1
    AND S.SalespersonPersonID IS NULL;
/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

TODO: 
SELECT
    SI.StockItemID AS [ИД товара],
    SI.StockItemName AS [Наименование товара],
    SI.UnitPrice AS [Цена]
FROM
    Warehouse.StockItems SI
WHERE
    SI.UnitPrice = (
        SELECT MIN(S.UnitPrice)
        FROM Warehouse.StockItems S
    );

/*Вариант используя подзапрос в JOIN */
	WITH MinPrice AS (
    SELECT MIN(UnitPrice) AS MinPrice
    FROM Warehouse.StockItems
)
SELECT
    SI.StockItemID AS [ИД товара],
    SI.StockItemName AS [Наименование товара],
    SI.UnitPrice AS [Цена]
FROM
    Warehouse.StockItems SI
INNER JOIN
    MinPrice MP ON SI.UnitPrice = MP.MinPrice;
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
/*Вариант используя подзапрос в WHERE */
TODO: 
SELECT
    C.CustomerID,
    C.CustomerName,
    CT.TransactionAmount
FROM
    Sales.CustomerTransactions CT
    INNER JOIN Sales.Customers C ON CT.CustomerID = C.CustomerID
WHERE
    CT.TransactionAmount IN (
        SELECT TOP 5
            TransactionAmount
        FROM
            Sales.CustomerTransactions
        ORDER BY
            TransactionAmount DESC
    )
ORDER BY
    CT.TransactionAmount DESC;

	/*Вариант используя CTE */

	WITH TopPayments AS (
    SELECT
        TransactionAmount,
        ROW_NUMBER() OVER (ORDER BY TransactionAmount DESC) AS RowNum
    FROM
        Sales.CustomerTransactions
)
SELECT
    C.CustomerID,
    C.CustomerName,
    TP.TransactionAmount
FROM
    TopPayments TP
    INNER JOIN Sales.CustomerTransactions CT ON TP.TransactionAmount = CT.TransactionAmount
    INNER JOIN Sales.Customers C ON CT.CustomerID = C.CustomerID
WHERE
    TP.RowNum <= 5
ORDER BY
    TP.TransactionAmount DESC;
/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

TODO: 

WITH TopThreeProducts AS (
    SELECT TOP 3
        StockItemID,
        StockItemName,
        UnitPrice
    FROM
        Warehouse.StockItems
    ORDER BY
        UnitPrice DESC
)

SELECT DISTINCT
    C.CityID AS [ИД города],
    C.CityName AS [Название города],
    P.FullName AS [Имя сотрудника]
FROM
    Sales.Invoices I
    INNER JOIN Sales.InvoiceLines IL ON I.InvoiceID = IL.InvoiceID
    INNER JOIN Warehouse.StockItems SI ON IL.StockItemID = SI.StockItemID
    INNER JOIN Application.Cities C ON I.DeliveryMethodID = C.CityID
    INNER JOIN Application.People P ON I.PackedByPersonID = P.PersonID
WHERE
    SI.StockItemID IN (SELECT StockItemID FROM TopThreeProducts);

	--CTE
WITH TopThreeProducts AS (
    SELECT TOP 3
        StockItemID,
        StockItemName,
        UnitPrice
    FROM
        Warehouse.StockItems
    ORDER BY
        UnitPrice DESC
)

SELECT DISTINCT
    C.CityID AS [ИД города],
    C.CityName AS [Название города],
    P.FullName AS [Имя сотрудника]
FROM
    Sales.Invoices I
    INNER JOIN Sales.InvoiceLines IL ON I.InvoiceID = IL.InvoiceID
    INNER JOIN Warehouse.StockItems SI ON IL.StockItemID = SI.StockItemID
    INNER JOIN Application.Cities C ON I.DeliveryMethodID = C.CityID
    INNER JOIN Application.People P ON I.PackedByPersonID = P.PersonID
WHERE
    SI.StockItemID IN (SELECT StockItemID FROM TopThreeProducts);
-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
