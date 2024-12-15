/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


DECLARE @cols AS NVARCHAR(MAX), @query AS NVARCHAR(MAX);

-- Получаем список клиентов для динамического PIVOT с использованием XML PATH, чтобы обойти ограничение по длине строки
SELECT @cols = STUFF((
    SELECT ', ' + QUOTENAME(CustomerName)
    FROM Sales.Customers
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

-- Формируем динамический SQL-запрос
SET @query = '
SELECT 
    FORMAT(InvoiceMonth, ''dd.MM.yyyy'') AS InvoiceMonth, ' + @cols + '
FROM 
(
    SELECT 
        CAST(DATEFROMPARTS(YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), 1) AS DATE) AS InvoiceMonth, 
        C.CustomerName, 
        COUNT(*) AS PurchaseCount
    FROM 
        Sales.Invoices I
    INNER JOIN 
        Sales.Customers C ON I.CustomerID = C.CustomerID
    GROUP BY 
        CAST(DATEFROMPARTS(YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), 1) AS DATE), 
        C.CustomerName
) AS SourceTable
PIVOT
(
    MAX(PurchaseCount) 
    FOR CustomerName IN (' + @cols + ')
) AS PivotTable
ORDER BY 
    InvoiceMonth;';

-- Выполняем динамический SQL-запрос
EXEC sp_executesql @query;




