use PrinterTrack

-- Вставляем данные о принтерах в таблицу Принтер с учетом IP-адреса
INSERT INTO Принтер (название, модель, отдел_id, IP_адрес)
VALUES
 -- Принтер 1
    ('BRN3C2AF4E5EB2D', 'HL-L2360D series', 
     (SELECT id FROM Отдел WHERE название = 'Отдел маркетинга' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '192.168.77.175'),
    
    -- Принтер 2
    ('BRN3C2AF4EA25CD', 'DCP-L2540DN series', 
     (SELECT id FROM Отдел WHERE название = 'Финансовый отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.55'),

    -- Принтер 3
    ('BRN3C2AF4ED7D0B', 'HL-L5100DN series', 
     (SELECT id FROM Отдел WHERE название = 'Отдел продаж автомобилей с пробегом' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '10.3.21.82'),

    -- Принтер 4
    ('BRNB422000835A0', 'MFC-L2700DN series', 
     (SELECT id FROM Отдел WHERE название = 'Финансовый отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'И-авто')), '172.16.252.170'),

    -- Принтер 5
    ('BRNB422003CE783', 'DCP-L2540DN series', 
     (SELECT id FROM Отдел WHERE название = 'Отдел сервиса автомобилей Exeed' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '10.3.21.12'),

    -- Принтер 6
    ('BRNB4220041D794', 'MFC-L2700DN series', 
     (SELECT id FROM Отдел WHERE название = 'Отдел запасных частей' AND организация_id = (SELECT id FROM Организация WHERE название = 'И-авто')), '172.16.252.182'),

    -- Принтер 7
    ('BRNB42200479593', 'HL-L5100DN series', 
     (SELECT id FROM Отдел WHERE название = 'Ресепш' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.40'),

    -- Принтер 8
    ('BRNB4220050FDF9', 'MFC-L5750DW series', 
     (SELECT id FROM Отдел WHERE название = 'Отдел продаж автомобилей Geely' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '172.16.252.196'),

    -- Принтер 9
    ('BRNB42200C42DD0', 'MFC-L5700DN series', 
     (SELECT id FROM Отдел WHERE название = 'Ресепш' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.60'),

    -- Принтер 10
    ('BRNB42200CCFE20', 'MFC-L5700DN series', 
     (SELECT id FROM Отдел WHERE название = 'Отдел сервиса автомобилей Geely' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '172.16.252.101'),

    -- Принтер 11
    ('DEV2490FF', 'HP LaserJet Pro MFP M127fn', 
     (SELECT id FROM Отдел WHERE название = 'Руководство' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '10.3.21.86'),

    -- Принтер 12
    ('DEVCBDBB6', 'HP LaserJet Pro MFP M127fw', 
     (SELECT id FROM Отдел WHERE название = 'Руководство' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '10.3.21.54'),

    -- Принтер 13
    ('EPSON121A08', 'M105 Series', 
     (SELECT id FROM Отдел WHERE название = 'Отдел сервиса автомобилей Geely' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '192.168.77.149'),

    -- Принтер 14
    ('EPSONB5924A', 'L4160', 
     (SELECT id FROM Отдел WHERE название = 'Руководство' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.6'),

    -- Принтер 15
    ('KM743267', 'ECOSYS M2235dn', 
     (SELECT id FROM Отдел WHERE название = 'Трейдин' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '192.168.77.128'),

    -- Принтер 16
    ('KM800F9E', 'ECOSYS M5521cdn', 
     (SELECT id FROM Отдел WHERE название = 'Корпаративный отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.219'),

    -- Принтер 17
    ('KMB75229', 'ECOSYS P2335dn', 
     (SELECT id FROM Отдел WHERE название = 'Отдел запасных частей' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '172.16.252.172'),

    -- Принтер 18
    ('MF230 Series', 'Canon MF230 Series', 
     (SELECT id FROM Отдел WHERE название = 'Ресепш' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '192.168.77.176'),

    -- Принтер 19
    ('NPI215821', 'HP LaserJet MFP M132fn', 
     (SELECT id FROM Отдел WHERE название = 'Финансовый отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '192.168.77.186'),

    -- Принтер 20
    ('NPI55744', 'HP LaserJet M203dn', 
     (SELECT id FROM Отдел WHERE название = 'Отдел сервиса автомобилей Geely' AND организация_id = (SELECT id FROM Организация WHERE название = 'С-авто')), '192.168.77.30'),

    -- Принтер 21
    ('NPI83D09A', 'HP LaserJet P2035n', 
     (SELECT id FROM Отдел WHERE название = 'Линейный отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.207');

	   -- Принтер 22
    ('NPIC089D7', 'HP LaserJet M1536dnf MFP', 
     (SELECT id FROM Отдел WHERE название = 'Линейный отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.5'),

    -- Принтер 23
    ('NPIC9A0D4', 'HP LaserJet MFP M236sdw', 
     (SELECT id FROM Отдел WHERE название = 'Финансовый отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.13'),

    -- Принтер 24
    ('RU178PRN-1VW', 'ECOSYS M3040dn', 
     (SELECT id FROM Отдел WHERE название = 'Отдел продаж автомобилей Geely' AND организация_id = (SELECT id FROM Организация WHERE название = 'И-авто')), '172.16.252.237'),

    -- Принтер 25
    ('RU178PRN-ADM', 'FS-1035MFP', 
     (SELECT id FROM Отдел WHERE название = 'Отдел маркетинга' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '172.16.252.50'),

    -- Принтер 26
    ('RU178PRN-BUH', 'HP LaserJet M2727nf MFP', 
     (SELECT id FROM Отдел WHERE название = 'Отдел сервиса автомобилей Geely' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '10.3.21.2'),

    -- Принтер 27
    ('RU178PRN-FIN', 'ECOSYS M2540dn', 
     (SELECT id FROM Отдел WHERE название = 'Кредитный отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'И-авто')), '172.16.252.220'),

    -- Принтер 28
    ('RU178PRN-IT2', 'ECOSYS M2040dn', 
     (SELECT id FROM Отдел WHERE название = 'Финансовый отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '172.16.252.150'),

    -- Принтер 29
    ('RU178PRN-MARK', 'HP Color LaserJet CP2025dn', 
     (SELECT id FROM Отдел WHERE название = 'Отдел маркетинга' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '172.16.252.242'),

    -- Принтер 30
    ('RU178PRN-SK3040', 'ECOSYS M3040dn', 
     (SELECT id FROM Отдел WHERE название = 'Юридический отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Д-авто')), '172.16.252.239'),

    -- Принтер 31
    ('RU178PRN-STO2', 'ECOSYS M2040dn', 
     (SELECT id FROM Отдел WHERE название = 'Отдел сервиса автомобилей Exeed' AND организация_id = (SELECT id FROM Организация WHERE название = 'И-авто')), '172.16.252.238'),

    -- Принтер 32
    ('XRX9C934EF950B2', 'Xerox WorkCentre 3025', 
     (SELECT id FROM Отдел WHERE название = 'Юридический отдел' AND организация_id = (SELECT id FROM Организация WHERE название = 'Маннет')), '10.3.21.174');
