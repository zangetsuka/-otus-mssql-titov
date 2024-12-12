/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/


---OPENXML

BEGIN TRY
    -- Объявляем переменную для XML
    DECLARE @xmlDoc xml;

    -- Загружаем XML-файл в переменную
    SELECT @xmlDoc = BulkColumn
    FROM OPENROWSET
    (
        BULK 'C:\SQL2022\StockItems.xml', SINGLE_CLOB
    ) AS data;

    -- Подготавливаем XML-документ
    DECLARE @docHandle int;
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDoc;

    -- Выполняем MERGE
    MERGE Warehouse.StockItems AS target
    USING 
    (
        SELECT *
        FROM OPENXML(@docHandle, N'/StockItems/Item')
        WITH 
        ( 
            [StockItemName] nvarchar(100)  '@Name',
            [SupplierID] int 'SupplierID',
            [UnitPackageID] int 'Package/UnitPackageID',
            [OuterPackageID] int 'Package/OuterPackageID',
            [QuantityPerOuter] int 'Package/QuantityPerOuter',
            [TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit',
            [LeadTimeDays] int 'LeadTimeDays',
            [IsChillerStock] bit 'IsChillerStock',
            [TaxRate] decimal(18,3) 'TaxRate',
            [UnitPrice] decimal(18,2) 'UnitPrice'
        )
    ) AS source 
    (
        StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
    )
    ON (target.StockItemName = source.StockItemName)
    WHEN MATCHED THEN
        UPDATE SET
            SupplierID = source.SupplierID,
            UnitPackageID = source.UnitPackageID,
            OuterPackageID = source.OuterPackageID,
            QuantityPerOuter = source.QuantityPerOuter,
            TypicalWeightPerUnit = source.TypicalWeightPerUnit,
            LeadTimeDays = source.LeadTimeDays,
            IsChillerStock = source.IsChillerStock,
            TaxRate = source.TaxRate,
            UnitPrice = source.UnitPrice,
            LastEditedBy = 1
    WHEN NOT MATCHED THEN
        INSERT 
        (
            StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy
        )
        VALUES 
        (
            source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1
        )
    OUTPUT deleted.*, $action, inserted.*;

    -- Завершаем работу с XML-документом
    EXEC sp_xml_removedocument @docHandle;

END TRY
BEGIN CATCH
    -- Обработка ошибок
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

---Вариант с XQuery

BEGIN TRY
    -- Объявляем переменную для XML
    DECLARE @xmlDoc xml;

    -- Загружаем XML-файл в переменную
    SELECT @xmlDoc = BulkColumn
    FROM OPENROWSET
    (
        BULK 'C:\SQL2022\StockItems.xml', SINGLE_CLOB
    ) AS data;

    -- Выполняем MERGE
    MERGE Warehouse.StockItems AS target
    USING 
    (
        SELECT  
            x.value('(@Name)[1]', 'nvarchar(100)') AS [StockItemName],
            x.value('(SupplierID)[1]', 'int') AS [SupplierID],
            x.value('(Package/UnitPackageID)[1]', 'int') AS [UnitPackageID],
            x.value('(Package/OuterPackageID)[1]', 'int') AS [OuterPackageID],
            x.value('(Package/QuantityPerOuter)[1]', 'int') AS [QuantityPerOuter],
            x.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18,3)') AS [TypicalWeightPerUnit],
            x.value('(LeadTimeDays)[1]', 'int') AS [LeadTimeDays],
            x.value('(IsChillerStock)[1]', 'bit') AS [IsChillerStock],
            x.value('(TaxRate)[1]', 'decimal(18,3)') AS [TaxRate],
            x.value('(UnitPrice)[1]', 'decimal(18,2)') AS [UnitPrice]
        FROM @xmlDoc.nodes('/StockItems/Item') AS t(x)
    ) AS source
    (
        StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice
    )
    ON (target.StockItemName = source.StockItemName)
    WHEN MATCHED THEN
        UPDATE SET
            SupplierID = source.SupplierID,
            UnitPackageID = source.UnitPackageID,
            OuterPackageID = source.OuterPackageID,
            QuantityPerOuter = source.QuantityPerOuter,
            TypicalWeightPerUnit = source.TypicalWeightPerUnit,
            LeadTimeDays = source.LeadTimeDays,
            IsChillerStock = source.IsChillerStock,
            TaxRate = source.TaxRate,
            UnitPrice = source.UnitPrice,
            LastEditedBy = 1
    WHEN NOT MATCHED THEN
        INSERT 
        (
            StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy
        )
        VALUES 
        (
            source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1
        )
    OUTPUT deleted.*, $action, inserted.*;

END TRY
BEGIN CATCH
    -- Обработка ошибок
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;



/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

BEGIN TRY
    -- Шаг 1: Генерация XML
    DECLARE @xmlResult NVARCHAR(MAX);

    SELECT @xmlResult = (
        SELECT 
            StockItemName AS [@Name],
            SupplierID AS [SupplierID],
            UnitPackageID AS [Package/UnitPackageID], 
            OuterPackageID AS [Package/OuterPackageID], 
            QuantityPerOuter AS [Package/QuantityPerOuter], 
            TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit],
            LeadTimeDays AS [LeadTimeDays],
            IsChillerStock AS [IsChillerStock],
            TaxRate AS [TaxRate],
            UnitPrice AS [UnitPrice]
        FROM Warehouse.StockItems
        FOR XML PATH('Item'), ROOT('StockItems')
    );

    -- Шаг 2: Проверка содержания XML
    PRINT @xmlResult;  -- Выводим XML в консоль, чтобы проверить его содержимое

    -- Шаг 3: Объявление переменных для работы с файлом
    DECLARE @FilePath NVARCHAR(MAX) = 'C:\SQL2022\GeneratedStockItems.xml';
    DECLARE @FileID INT, @TextFileID INT;

    -- Шаг 4: Включение OLE Automation (если не включено)
    EXEC sp_configure 'show advanced options', 1;
    RECONFIGURE;
    EXEC sp_configure 'Ole Automation Procedures', 1;
    RECONFIGURE;

    -- Шаг 5: Создание объекта для файловой системы
    EXEC sp_OACreate 'Scripting.FileSystemObject', @FileID OUTPUT;

    -- Шаг 6: Создание нового файла (с указанием кодировки)
    EXEC sp_OAMethod @FileID, 'CreateTextFile', @TextFileID OUTPUT, @FilePath, 1, 1;  -- 1 - Перезаписать файл, 1 - Использовать Unicode

    -- Шаг 7: Запись XML в файл
    EXEC sp_OAMethod @TextFileID, 'Write', NULL, @xmlResult;

    -- Шаг 8: Освобождение ресурсов
    EXEC sp_OADestroy @FileID;
    EXEC sp_OADestroy @TextFileID;

    PRINT 'Generated XML file: ' + @FilePath;

END TRY
BEGIN CATCH
    -- Обработка ошибок
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT 
    StockItemID,
    StockItemName,
    JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture,
    JSON_VALUE(JSON_QUERY(CustomFields, '$.Tags'), '$[0]') AS FirstTag
FROM 
    Warehouse.StockItems;

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/


SELECT 
    StockItemID,
	StockItemName,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	JSON_QUERY (CustomFields, '$.Tags') as Tags
FROM Warehouse.StockItems
where JSON_VALUE(CustomFields, '$.Tags[0]')  = 'Vintage'
GO


--- Не смог сделать выгрузку в корень своего гит потому что у меня у польщователя русское имя и ругается - "C:\Users\Администратор\Desktop\otus-mssql-titov\HW09_xml_json\StockItems.xml"
--- поэтому файлы перенес в другую директорию, а в гит скопировал что выгрузилось. 
