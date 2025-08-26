CREATE FUNCTION dbo.fn_WaterRequirementSpanish(@Requirement NVARCHAR(20))
RETURNS NVARCHAR(20)
AS
BEGIN
    RETURN CASE LOWER(@Requirement)
        WHEN 'low' THEN 'Bajo'
        WHEN 'medium' THEN 'Medio'
        WHEN 'high' THEN 'Alto'
        WHEN 'very high' THEN 'Muy Alto'
        ELSE @Requirement
    END
END;
GO
