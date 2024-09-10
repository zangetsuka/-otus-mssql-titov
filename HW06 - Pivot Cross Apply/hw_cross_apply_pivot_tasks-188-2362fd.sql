/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

WITH CustomerNames AS (
    SELECT
        CustomerID,
        LTRIM(RTRIM(SUBSTRING(CustomerName, CHARINDEX('(', CustomerName) + 1, CHARINDEX(')', CustomerName) - CHARINDEX('(', CustomerName) - 1))) AS CustomerLocation
    FROM Sales.Customers
    WHERE CustomerID BETWEEN 2 AND 6
),
InvoiceSummary AS (
    SELECT
        CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, InvoiceDate), 0) AS DATE) AS InvoiceMonth,
        c.CustomerLocation,
        COUNT(i.InvoiceID) AS PurchaseCount
    FROM Sales.Invoices i
    INNER JOIN CustomerNames c ON i.CustomerID = c.CustomerID
    GROUP BY
        CAST(DATEADD(MONTH, DATEDIFF(MONTH, 0, InvoiceDate), 0) AS DATE),
        c.CustomerLocation
)
SELECT 
    FORMAT(InvoiceMonth, 'dd.MM.yyyy') AS InvoiceMonth,
    ISNULL([Peeples Valley, AZ], 0) AS [Peeples Valley, AZ],
    ISNULL([Medicine Lodge, KS], 0) AS [Medicine Lodge, KS],
    ISNULL([Gasport, NY], 0) AS [Gasport, NY],
    ISNULL([Sylvanite, MT], 0) AS [Sylvanite, MT],
    ISNULL([Jessie, ND], 0) AS [Jessie, ND]
FROM InvoiceSummary
PIVOT (
    SUM(PurchaseCount)
    FOR CustomerLocation IN ([Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND])
) AS PivotTable
ORDER BY InvoiceMonth;


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT 
    c.CustomerName,
    c.DeliveryAddressLine1 AS AddressLine
FROM 
    Sales.Customers c
WHERE 
    c.CustomerName LIKE '%Tailspin Toys%'
ORDER BY 
    c.CustomerName, c.DeliveryAddressLine1;

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT 
    CountryID,
    CountryName,
    IsoAlpha3Code AS Code
FROM 
    Application.Countries

UNION ALL

SELECT 
    CountryID,
    CountryName,
    CAST(IsoNumericCode AS VARCHAR(10)) AS Code
FROM 
    Application.Countries

ORDER BY 
    CountryID, CountryName, Code;


/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

WITH RankedItems AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        il.StockItemID,
        il.UnitPrice,
        i.InvoiceDate,
        ROW_NUMBER() OVER (PARTITION BY c.CustomerID ORDER BY il.UnitPrice DESC) AS rn
    FROM
        Sales.InvoiceLines il
    JOIN
        Sales.Invoices i ON il.InvoiceID = i.InvoiceID
    JOIN
        Sales.Customers c ON i.CustomerID = c.CustomerID
)

SELECT
    CustomerID,
    CustomerName,
    StockItemID,
    UnitPrice,
    InvoiceDate
FROM
    RankedItems
WHERE
    rn <= 2
ORDER BY
    CustomerID, rn;