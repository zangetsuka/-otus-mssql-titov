/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

;WITH InvoiceData AS
(
    SELECT
        i.InvoiceID AS id_продажи,
        i.InvoiceDate AS дата_продажи,
        c.CustomerName AS название_клиента,
        SUM(il.Quantity * il.UnitPrice) AS сумма_продажи
    FROM Sales.Invoices i
    LEFT JOIN Sales.InvoiceLines il
        ON i.InvoiceID = il.InvoiceID
    JOIN Sales.Customers c
        ON c.CustomerID = i.CustomerID
    WHERE YEAR(i.InvoiceDate) >= 2015
    GROUP BY i.InvoiceID, i.InvoiceDate, c.CustomerName
)
SELECT 
    inv.id_продажи,
    inv.название_клиента,
    inv.дата_продажи,
    inv.сумма_продажи,
    SUM(inv2.сумма_продажи) AS нарастающий_итог
FROM InvoiceData inv
INNER JOIN InvoiceData inv2
    ON YEAR(inv2.дата_продажи) < YEAR(inv.дата_продажи) 
       OR (YEAR(inv2.дата_продажи) = YEAR(inv.дата_продажи) 
           AND MONTH(inv2.дата_продажи) <= MONTH(inv.дата_продажи))
GROUP BY 
    YEAR(inv.дата_продажи), 
    MONTH(inv.дата_продажи), 
    inv.id_продажи, 
    inv.название_клиента, 
    inv.дата_продажи, 
    inv.сумма_продажи
ORDER BY inv.дата_продажи, inv.id_продажи;


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/
;WITH InvoiceData AS
(
    SELECT
        i.InvoiceID AS id_продажи,
        i.InvoiceDate AS дата_продажи,
        c.CustomerName AS название_клиента,
        SUM(il.Quantity * il.UnitPrice) AS сумма_продажи
    FROM Sales.Invoices i
    LEFT JOIN Sales.InvoiceLines il
        ON i.InvoiceID = il.InvoiceID
    JOIN Sales.Customers c
        ON c.CustomerID = i.CustomerID
    WHERE YEAR(i.InvoiceDate) >= 2015
    GROUP BY i.InvoiceID, i.InvoiceDate, c.CustomerName
)
SELECT 
    inv.id_продажи,
    inv.название_клиента,
    inv.дата_продажи,
    inv.сумма_продажи,
    SUM(inv.сумма_продажи) OVER (
        PARTITION BY YEAR(inv.дата_продажи), MONTH(inv.дата_продажи) 
        ORDER BY inv.дата_продажи
    ) AS нарастающий_итог
FROM InvoiceData inv
ORDER BY inv.дата_продажи, inv.id_продажи;

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

	--Анализ потребления ресурсов
-- Сравнение производительности запросов нарастающего итога
-- =====================================================================
-- Запрос без оконной функции:
-- ---------------------------------------------------------------------
-- 1. Количество строк: 31440
-- 2. CPU time: 3171 ms
-- 3. Elapsed time: 9694 ms
-- 4. Logical reads (таблицы):
--    - InvoiceLines: Scan count 4, lob logical reads 322
--    - Worktable: Logical reads 70850
--    - Workfile: Logical reads 144
--    - Invoices: Logical reads 22800
--    - Customers: Logical reads 45
-- Итог: запрос использует большое количество ресурсов ввода-вывода и требует значительного времени выполнения.

-- ---------------------------------------------------------------------
-- Запрос с оконной функцией:
-- ---------------------------------------------------------------------
-- 1. Количество строк: 31440
-- 2. CPU time: 313 ms
-- 3. Elapsed time: 5113 ms
-- 4. Logical reads (таблицы):
--    - InvoiceLines: Scan count 2, lob logical reads 161
--    - Worktable: Logical reads 0
--    - Invoices: Logical reads 11400
--    - Customers: Logical reads 41
-- Итог: запрос с оконной функцией значительно оптимальнее, так как использует меньше операций чтения 
--       и занимает меньше времени выполнения.

-- =====================================================================
-- Вывод:
-- Запрос с оконной функцией имеет явное преимущество:
-- 1. Сокращено количество логических чтений.
-- 2. Уменьшено потребление CPU (в 10 раз).
-- 3. Время выполнения сокращено почти в 2 раза.
-- Рекомендуется использовать оконную функцию для расчёта нарастающего итога.
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

WITH MonthlyProductSales AS (
    SELECT
        YEAR(SI.InvoiceDate) AS [Год],
        MONTH(SI.InvoiceDate) AS [Месяц],
        SIL.StockItemID AS [ID продукта],
        SI.CustomerID AS [ID клиента],
        SUM(SIL.Quantity) AS [Количество проданных],
        ROW_NUMBER() OVER (
            PARTITION BY YEAR(SI.InvoiceDate), MONTH(SI.InvoiceDate) 
            ORDER BY SUM(SIL.Quantity) DESC
        ) AS [Ранг]
    FROM
        Sales.Invoices SI
        INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
    WHERE
        YEAR(SI.InvoiceDate) = 2016
    GROUP BY
        YEAR(SI.InvoiceDate),
        MONTH(SI.InvoiceDate),
        SIL.StockItemID,
        SI.CustomerID
)
SELECT
    [Год],
    [Месяц],
    [ID продукта],
    [Количество проданных]
FROM
    MonthlyProductSales
WHERE
    [Ранг] <= 2
ORDER BY
    [Год],
    [Месяц],
    [Ранг];

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT
    StockItemID AS ItemID,
    StockItemName AS ItemName,
    Brand AS Brand,
    UnitPrice AS Price,
    DENSE_RANK() OVER (ORDER BY LEFT(StockItemName, 1)) AS NameRank,
    SUM(QuantityPerOuter) OVER (PARTITION BY StockItemID) AS TotalQuantity,
    SUM(QuantityPerOuter) OVER (PARTITION BY LEFT(StockItemName, 1)) AS QuantityByLetter,
    LEAD(StockItemID) OVER (ORDER BY StockItemName) AS NextItemID,
    LAG(StockItemID) OVER (ORDER BY StockItemName) AS PrevItemID,
    LAG(StockItemName, 2, 'No items') OVER (ORDER BY StockItemName) AS NameTwoRowsAgo,
    NTILE(30) OVER (ORDER BY TypicalWeightPerUnit) AS WeightGroup
FROM Warehouse.StockItems;




/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/



WITH ПоследниеПродажи AS (
    SELECT
        SI.SalespersonPersonID AS [ID сотрудника],
        P.FullName AS [Фамилия сотрудника],
        C.CustomerID AS [ID клиента],
        C.CustomerName AS [Название клиента],
        SI.InvoiceDate AS [Дата продажи],
        SI.TotalDryItems AS [Сумма сделки],  
        ROW_NUMBER() OVER (PARTITION BY SI.SalespersonPersonID ORDER BY SI.InvoiceDate DESC) AS [Номер строки]
    FROM
        Sales.Invoices SI
        INNER JOIN Application.People P ON SI.SalespersonPersonID = P.PersonID
        INNER JOIN Sales.Customers C ON SI.CustomerID = C.CustomerID
)
SELECT
    [ID сотрудника],
    [Фамилия сотрудника],
    [ID клиента],
    [Название клиента],
    [Дата продажи],
    [Сумма сделки]
FROM
    ПоследниеПродажи
WHERE
    [Номер строки] = 1
ORDER BY
    [ID сотрудника];
/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT
    CustomerID AS Customer_ID,
    CustomerName AS Customer_Name,
    StockItemID AS Item_ID,
    StockItemDescription AS Item_Description,
    UnitPrice AS Price,
    InvoiceDate AS Purchase_Date
FROM (
    SELECT
        i.CustomerID,
        c.CustomerName,
        il.StockItemID,
        il.Description AS StockItemDescription,
        il.UnitPrice,
        MAX(i.InvoiceDate) AS InvoiceDate,
        DENSE_RANK() OVER (PARTITION BY i.CustomerID ORDER BY il.UnitPrice DESC, il.StockItemID) AS Rank
    FROM Sales.Invoices AS i
    JOIN Sales.InvoiceLines AS il ON i.InvoiceID = il.InvoiceID
    JOIN Warehouse.StockItems AS si ON si.StockItemID = il.StockItemID
    JOIN Sales.Customers AS c ON c.CustomerID = i.CustomerID
    GROUP BY
        i.CustomerID,
        c.CustomerName,
        il.StockItemID,
        il.Description,
        il.UnitPrice
) AS TopSalesProducts
WHERE Rank <= 2
ORDER BY Customer_ID, Price DESC;

