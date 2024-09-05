/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

USE WideWorldImporters;

SELECT
    DATEPART(YEAR, SI.InvoiceDate) AS [Год продажи],
    DATEPART(MONTH, SI.InvoiceDate) AS [Месяц продажи],
    AVG(SIL.UnitPrice) AS [Средняя цена за месяц],
    SUM(SIL.UnitPrice * SIL.Quantity) AS [Общая сумма продаж за месяц]
FROM
    Sales.Invoices SI
    INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
GROUP BY
    DATEPART(YEAR, SI.InvoiceDate),
    DATEPART(MONTH, SI.InvoiceDate)
ORDER BY
    [Год продажи],
    [Месяц продажи];

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
    DATEPART(YEAR, SI.InvoiceDate) AS [Год продажи],
    DATEPART(MONTH, SI.InvoiceDate) AS [Месяц продажи],
    SUM(SIL.UnitPrice * SIL.Quantity) AS [Общая сумма продаж]
FROM
    Sales.Invoices SI
    INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
GROUP BY
    DATEPART(YEAR, SI.InvoiceDate),
    DATEPART(MONTH, SI.InvoiceDate)
HAVING
    SUM(SIL.UnitPrice * SIL.Quantity) > 4600000
ORDER BY
    [Год продажи],
    [Месяц продажи];

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

WITH MonthlySales AS (
    SELECT
        YEAR(SI.InvoiceDate) AS SaleYear,
        MONTH(SI.InvoiceDate) AS SaleMonth,
        SIL.StockItemID,
        SI.InvoiceDate,
        SUM(SIL.UnitPrice * SIL.Quantity) AS TotalSales,
        SUM(SIL.Quantity) AS TotalQuantity
    FROM
        Sales.Invoices SI
        INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
    GROUP BY
        YEAR(SI.InvoiceDate),
        MONTH(SI.InvoiceDate),
        SIL.StockItemID,
        SI.InvoiceDate
),
FilteredSales AS (
    SELECT
        SaleYear,
        SaleMonth,
        StockItemID,
        MIN(InvoiceDate) AS FirstSaleDate,
        SUM(TotalSales) AS TotalSales,
        SUM(TotalQuantity) AS TotalQuantity
    FROM
        MonthlySales
    GROUP BY
        SaleYear,
        SaleMonth,
        StockItemID
    HAVING
        SUM(TotalQuantity) < 50
)
SELECT
    F.SaleYear AS [Год продажи],
    F.SaleMonth AS [Месяц продажи],
    SI.StockItemName AS [Наименование товара],
    F.TotalSales AS [Сумма продаж],
    F.FirstSaleDate AS [Дата первой продажи],
    F.TotalQuantity AS [Количество проданного]
FROM
    FilteredSales F
    INNER JOIN Warehouse.StockItems SI ON F.StockItemID = SI.StockItemID
ORDER BY
    F.SaleYear,
    F.SaleMonth,
    SI.StockItemName;

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
