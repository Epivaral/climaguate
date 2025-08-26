CREATE FUNCTION dbo.fn_MonthsJsonToSpanish(@MonthsJson NVARCHAR(100))
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @MonthsTable TABLE (MonthNum INT);
    DECLARE @Result NVARCHAR(200) = '';
    -- Remove brackets and quotes, split by comma
    SET @MonthsJson = REPLACE(REPLACE(REPLACE(REPLACE(@MonthsJson, '[', ''), ']', ''), '"', ''), ' ', '');
    DECLARE @pos INT = 0;
    DECLARE @nextpos INT;
    DECLARE @val NVARCHAR(10);
    WHILE LEN(@MonthsJson) > 0
    BEGIN
        SET @nextpos = CHARINDEX(',', @MonthsJson);
        IF @nextpos = 0
            SET @val = @MonthsJson;
        ELSE
            SET @val = LEFT(@MonthsJson, @nextpos - 1);
        INSERT INTO @MonthsTable VALUES (TRY_CAST(@val AS INT));
        IF @nextpos = 0 BREAK;
        SET @MonthsJson = SUBSTRING(@MonthsJson, @nextpos + 1, LEN(@MonthsJson));
    END
    -- Map numbers to Spanish month names
    SELECT @Result = @Result + CASE MonthNum
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
        WHEN 7 THEN 'Julio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Septiembre'
        WHEN 10 THEN 'Octubre'
        WHEN 11 THEN 'Noviembre'
        WHEN 12 THEN 'Diciembre'
        ELSE '' END + ', '
    FROM @MonthsTable WHERE MonthNum BETWEEN 1 AND 12;
    IF LEN(@Result) > 1 SET @Result = LEFT(@Result, LEN(@Result) - 1);
    IF RIGHT(@Result, 1) = ',' SET @Result = LEFT(@Result, LEN(@Result) - 1);
    RETURN LTRIM(RTRIM(@Result));
END;
GO
