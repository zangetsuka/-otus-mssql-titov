USE WideWorldImporters

SET STATISTICS TIME ON;
--Исходный запрос
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

--Статистика
--SQL Server parse and compile time: 
--   CPU time = 250 ms, elapsed time = 604 ms.

--(3619 rows affected)

-- SQL Server Execution Times:
 --  CPU time = 2672 ms,  elapsed time = 21841 ms.

--Completion time: 2024-12-24T19:16:20.0573750+03:00


--Изменённый запрос
SELECT 
    ord.CustomerID, 
    det.StockItemID, 
    SUM(det.UnitPrice), 
    SUM(det.Quantity), 
    COUNT(ord.OrderID)
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det
    ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv
    ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans
    ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans
    ON ItemTrans.StockItemID = det.StockItemID
JOIN Warehouse.StockItems AS It
    ON It.StockItemID = det.StockItemID
JOIN Sales.OrderLines AS Total
    ON Total.OrderID = ord.OrderID
JOIN Sales.Orders AS ordTotal
    ON ordTotal.CustomerID = Inv.CustomerID
WHERE 
    Inv.BillToCustomerID != ord.CustomerID
    AND It.SupplierId = 12
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
HAVING SUM(Total.UnitPrice * Total.Quantity) > 250000
ORDER BY ord.CustomerID, det.StockItemID;


--SQL Server parse and compile time: 
--   CPU time = 422 ms, elapsed time = 714 ms.

--(4849 rows affected)

 --SQL Server Execution Times:
   --CPU time = 2094 ms,  elapsed time = 19628 ms.

--Completion time: 2024-12-24T19:19:15.0542606+03:00

-- Оригинальный запрос использовал подзапросы, что приводило к увеличению количества вычислений 
-- и замедляло выполнение из-за необходимости выполнения подзапросов для каждой строки.

-- Оптимизированный запрос заменяет подзапросы на соединения (JOIN), что улучшает производительность,
--а также переносит условие с агрегатной функцией в HAVING, что позволяет фильтровать агрегированные данные после выполнения группировки (GROUP BY).

-- Итог: Прямые соединения и использование HAVING вместо подзапросов в WHERE снижают нагрузку на систему и ускоряют выполнение запроса.