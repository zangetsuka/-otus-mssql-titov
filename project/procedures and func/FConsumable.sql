CREATE FUNCTION CheckConsumableExists
(
    @Принтер NVARCHAR(255),
    @Материал NVARCHAR(255)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT;

    SELECT @Exists = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM Расходные_Материалы rm
    JOIN Принтер p ON rm.принтер_id = p.id
    WHERE p.название = @Принтер AND rm.название = @Материал;

    RETURN @Exists;
END;
