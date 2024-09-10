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

SET STATISTICS TIME, IO ON;
WITH MonthlySales AS (
    SELECT
        YEAR(SI.InvoiceDate) AS [Год],
        MONTH(SI.InvoiceDate) AS [Месяц],
        SUM(SIL.UnitPrice * SIL.Quantity) AS [Сумма продаж]
    FROM
        Sales.Invoices SI
        INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
    WHERE
        YEAR(SI.InvoiceDate) >= 2015
    GROUP BY
        YEAR(SI.InvoiceDate),
        MONTH(SI.InvoiceDate)
),
CumulativeSales AS (
    SELECT
        MS.[Год],
        MS.[Месяц],
        SUM(MS2.[Сумма продаж]) AS [Нарастающий итог]
    FROM
        MonthlySales MS
        INNER JOIN MonthlySales MS2
            ON MS2.[Год] = MS.[Год] AND MS2.[Месяц] <= MS.[Месяц]
    GROUP BY
        MS.[Год],
        MS.[Месяц]
)
SELECT
    SI.InvoiceID AS [ID продажи],
    C.CustomerName AS [Название клиента],
    SI.InvoiceDate AS [Дата продажи],
    SUM(SIL.UnitPrice * SIL.Quantity) AS [Сумма продажи],
    CS.[Нарастающий итог]
FROM
    Sales.Invoices SI
    INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
    INNER JOIN Sales.Customers C ON SI.CustomerID = C.CustomerID
    INNER JOIN CumulativeSales CS
        ON YEAR(SI.InvoiceDate) = CS.[Год] AND MONTH(SI.InvoiceDate) = CS.[Месяц]
WHERE
    YEAR(SI.InvoiceDate) >= 2015
GROUP BY
    SI.InvoiceID, 
    C.CustomerName, 
    SI.InvoiceDate,
    CS.[Нарастающий итог]
ORDER BY
    SI.InvoiceDate;


/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/


SELECT
    SI.InvoiceID AS [ID продажи],
    C.CustomerName AS [Название клиента],
    SI.InvoiceDate AS [Дата продажи],
    SUM(SIL.UnitPrice * SIL.Quantity) AS [Сумма продажи],
    SUM(SUM(SIL.UnitPrice * SIL.Quantity)) 
        OVER (ORDER BY YEAR(SI.InvoiceDate), MONTH(SI.InvoiceDate) ROWS UNBOUNDED PRECEDING) AS [Нарастающий итог]
FROM
    Sales.Invoices SI
    INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
    INNER JOIN Sales.Customers C ON SI.CustomerID = C.CustomerID
WHERE
    YEAR(SI.InvoiceDate) >= 2015
GROUP BY
    SI.InvoiceID, 
    C.CustomerName, 
    SI.InvoiceDate
ORDER BY
    SI.InvoiceDate;


	--Анализ потребления ресурсов
	-- 1 запрос:  SQL Server Execution Times:CPU time = 187 ms,  elapsed time = 966 ms.
	-- 2 запрос:  SQL Server Execution Times:CPU time = 188 ms,  elapsed time = 969 ms.
	--Исходя из этих данных, производительность обоих запросов практически идентична. Однако, оконная функция обладает преимуществом, поскольку jна более читабельна и упрощает код и оконные функции часто лучше масштабируются на больших объемах данных.
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

WITH ИнформацияОТоварах AS (
    SELECT 
        SI.StockItemID AS [ID товара],
        SI.StockItemName AS [Название],
        SI.Brand AS [Брэнд],
        SI.UnitPrice AS [Цена],
        SI.TypicalWeightPerUnit AS [Вес товара],
        ROW_NUMBER() OVER (PARTITION BY SI.StockItemName ORDER BY SI.StockItemName) AS [Номер],
        COUNT(*) OVER () AS [Общее количество товаров],
        COUNT(*) OVER (PARTITION BY LEFT(SI.StockItemName, 1)) AS [Количество по первой букве],
        LEAD(SI.StockItemID) OVER (ORDER BY SI.StockItemName) AS [Следующий ID],
        LAG(SI.StockItemID) OVER (ORDER BY SI.StockItemName) AS [Предыдущий ID],
        LAG(SI.StockItemName, 2, 'Нет товаров') OVER (ORDER BY SI.StockItemName) AS [Название 2 строки назад],
        NTILE(30) OVER (ORDER BY SI.TypicalWeightPerUnit) AS [Группа по весу]
    FROM 
        Warehouse.StockItems SI
)
SELECT 
    [ID товара],
    [Название],
    [Брэнд],
    [Цена],
    [Номер],
    [Общее количество товаров],
    [Количество по первой букве],
    [Следующий ID],
    [Предыдущий ID],
    [Название 2 строки назад],
    [Группа по весу]
FROM 
    ИнформацияОТоварах
ORDER BY 
    [Название];
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

WITH ТоварыПоКлиентам AS (
    SELECT
        SI.CustomerID AS [ID клиента],
        C.CustomerName AS [Название клиента],
        SIL.StockItemID AS [ID товара],
        SIL.UnitPrice AS [Цена],
        SI.InvoiceDate AS [Дата покупки],
        ROW_NUMBER() OVER (
            PARTITION BY SI.CustomerID
            ORDER BY SIL.UnitPrice DESC
        ) AS [Номер товара]
    FROM
        Sales.Invoices SI
        INNER JOIN Sales.InvoiceLines SIL ON SI.InvoiceID = SIL.InvoiceID
        INNER JOIN Sales.Customers C ON SI.CustomerID = C.CustomerID
)
SELECT
    [ID клиента],
    [Название клиента],
    [ID товара],
    [Цена],
    [Дата покупки]
FROM
    ТоварыПоКлиентам
WHERE
    [Номер товара] <= 2
ORDER BY
    [ID клиента],
    [Номер товара];

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 