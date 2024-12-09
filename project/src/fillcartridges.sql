INSERT INTO Расходные_материалы (название, категория, количество, принтер_id)
SELECT 
    -- Фотобарабан
    'Фотобарабан ' + p.модель AS название,
    'Фотобарабан' AS категория,
    1 AS количество,
    p.id AS принтер_id
FROM Принтер p
UNION ALL
SELECT 
    -- Первый картридж
    c.картридж + ' (Картридж 1)' AS название,
    'Картридж' AS категория,
    2 AS количество,
    p.id AS принтер_id
FROM Принтер p
JOIN (
    VALUES
        ('HL-L2360D series', 'TN-2375'),
        ('DCP-L2540DN series', 'TN-2375'),
        ('HL-L5100DN series', 'Brother TN-3430 / TN-3480'),
        ('MFC-L2700DN series', 'Brother TN-3430 / TN-3480'),
        ('DCP-L2540DN series', 'Brother TN-3430 / TN-3480'),
        ('MFC-L2700DN series', 'Brother TN-3430 / TN-3480'),
        ('HL-L5100DN series', 'Brother TN-3480'),
        ('MFC-L5750DW series', 'Brother TN-3480'),
        ('MFC-L5700DN series', 'Brother TN-3480'),
        ('MFC-L5700DN series', 'Brother TN-3430 / TN-3480'),
        ('HP LaserJet Pro MFP M127fn', 'HP 83A (CF283A)'),
        ('HP LaserJet Pro MFP M127fw', 'HP 83A (CF283A)'),
        ('M105 Series', 'Epson M105 (T7741)'),
        ('L4160', 'Epson L4160 (T00V100/T00V200/T00V300)'),
        ('ECOSYS M2235dn', 'Kyocera TK-1150'),
        ('ECOSYS M5521cdn', 'Kyocera TK-5230'),
        ('ECOSYS P2335dn', 'Kyocera TK-1150'),
        ('Canon MF230 Series', 'Canon 137'),
        ('HP LaserJet MFP M132fn', 'HP 17A (CF217A)'),
        ('HP LaserJet M203dn', 'HP 30A (CF230A)'),
        ('HP LaserJet P2035n', 'HP 05A (CE505A)'),
        ('HP LaserJet M1536dnf MFP', 'HP 78A (CE278A)'),
        ('HP LaserJet MFP M236sdw', 'HP 136A'),
        ('ECOSYS M3040dn', 'Kyocera TK-3100'),
        ('FS-1035MFP', 'Kyocera TK-1140'),
        ('HP LaserJet M2727nf MFP', 'HP 53A (Q7553A)'),
        ('ECOSYS M2540dn', 'Kyocera TK-1170'),
        ('ECOSYS M2040dn', 'Kyocera TK-1160'),
        ('HP Color LaserJet CP2025dn', 'HP 304A (CC530A/CC531A/CC532A/CC533A)'),
        ('ECOSYS M3040dn', 'Kyocera TK-3100'),
        ('ECOSYS M2040dn', 'Kyocera TK-1140'),
        ('Xerox WorkCentre 3025', 'Xerox 106R02773')
    ) AS c(модель, картридж)
ON p.модель = c.модель
UNION ALL
SELECT 
    -- Второй картридж (повтор с дополнительной меткой)
    c.картридж + ' (Картридж 2)' AS название,
    'Картридж' AS категория,
    2 AS количество,
    p.id AS принтер_id
FROM Принтер p
JOIN (
    VALUES
        ('HL-L2360D series', 'TN-2375'),
        ('DCP-L2540DN series', 'TN-2375'),
        ('HL-L5100DN series', 'Brother TN-3430 / TN-3480'),
        ('MFC-L2700DN series', 'Brother TN-3430 / TN-3480'),
        ('DCP-L2540DN series', 'Brother TN-3430 / TN-3480'),
        ('MFC-L2700DN series', 'Brother TN-3430 / TN-3480'),
        ('HL-L5100DN series', 'Brother TN-3480'),
        ('MFC-L5750DW series', 'Brother TN-3480'),
        ('MFC-L5700DN series', 'Brother TN-3480'),
        ('MFC-L5700DN series', 'Brother TN-3430 / TN-3480'),
        ('HP LaserJet Pro MFP M127fn', 'HP 83A (CF283A)'),
        ('HP LaserJet Pro MFP M127fw', 'HP 83A (CF283A)'),
        ('M105 Series', 'Epson M105 (T7741)'),
        ('L4160', 'Epson L4160 (T00V100/T00V200/T00V300)'),
        ('ECOSYS M2235dn', 'Kyocera TK-1150'),
        ('ECOSYS M5521cdn', 'Kyocera TK-5230'),
        ('ECOSYS P2335dn', 'Kyocera TK-1150'),
        ('Canon MF230 Series', 'Canon 137'),
        ('HP LaserJet MFP M132fn', 'HP 17A (CF217A)'),
        ('HP LaserJet M203dn', 'HP 30A (CF230A)'),
        ('HP LaserJet P2035n', 'HP 05A (CE505A)'),
        ('HP LaserJet M1536dnf MFP', 'HP 78A (CE278A)'),
        ('HP LaserJet MFP M236sdw', 'HP 136A'),
        ('ECOSYS M3040dn', 'Kyocera TK-3100'),
        ('FS-1035MFP', 'Kyocera TK-1140'),
        ('HP LaserJet M2727nf MFP', 'HP 53A (Q7553A)'),
        ('ECOSYS M2540dn', 'Kyocera TK-1170'),
        ('ECOSYS M2040dn', 'Kyocera TK-1160'),
        ('HP Color LaserJet CP2025dn', 'HP 304A (CC530A/CC531A/CC532A/CC533A)'),
        ('ECOSYS M3040dn', 'Kyocera TK-3100'),
        ('ECOSYS M2040dn', 'Kyocera TK-1140'),
        ('Xerox WorkCentre 3025', 'Xerox 106R02773')
    ) AS c(модель, картридж)
ON p.модель = c.модель;
