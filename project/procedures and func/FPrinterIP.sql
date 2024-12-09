use PrinterTrack
GO
CREATE FUNCTION GetPrinterIP
(
    @Принтер NVARCHAR(255)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @IP NVARCHAR(50);

    SELECT @IP = ip_адрес
    FROM Принтер
    WHERE название = @Принтер;

    RETURN @IP;
END;
GO