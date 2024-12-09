SELECT 
    s.ФИО, 
    s.должность, 
    n.название AS Отдел, 
    org.название AS Организация
FROM 
    Сотрудник s
JOIN 
    Отдел o ON s.отдел_id = o.id
JOIN 
    Названия_Отделов n ON o.название_id = n.id
JOIN 
    Организация org ON o.организация_id = org.id;
