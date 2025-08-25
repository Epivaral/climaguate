CREATE FUNCTION agriculture.CalculateSuitabilityScore(
    @ObservedTempC FLOAT,
    @ObservedHumidityPct INT,
    @OptimalTempMin FLOAT,
    @OptimalTempMax FLOAT,
    @OptimalHumidityMin INT,
    @OptimalHumidityMax INT,
    @StressTempMin FLOAT,
    @StressTempMax FLOAT,
    @LocalTempAdjustment FLOAT,
    @LocalHumidityAdjustment INT
)
RETURNS TINYINT
AS
BEGIN
    DECLARE @AdjustedTemp FLOAT;
    DECLARE @AdjustedHumidity INT;
    DECLARE @TempScore FLOAT;
    DECLARE @HumidityScore FLOAT;
    DECLARE @FinalScore TINYINT;
    
    -- Step 1: Apply local adjustments
    SET @AdjustedTemp = @ObservedTempC + @LocalTempAdjustment;
    SET @AdjustedHumidity = @ObservedHumidityPct + @LocalHumidityAdjustment;
    
    -- Step 2: Calculate temperature subscore (0-100)
    IF @AdjustedTemp >= @OptimalTempMin AND @AdjustedTemp <= @OptimalTempMax
    BEGIN
        -- Within optimal range = 100
        SET @TempScore = 100.0;
    END
    ELSE IF @AdjustedTemp < @OptimalTempMin
    BEGIN
        -- Below optimal - linear decrease to 0 at stress threshold
        IF @AdjustedTemp <= @StressTempMin
            SET @TempScore = 0.0;
        ELSE
            SET @TempScore = 100.0 * (@AdjustedTemp - @StressTempMin) / (@OptimalTempMin - @StressTempMin);
    END
    ELSE -- @AdjustedTemp > @OptimalTempMax
    BEGIN
        -- Above optimal - linear decrease to 0 at stress threshold
        IF @AdjustedTemp >= @StressTempMax
            SET @TempScore = 0.0;
        ELSE
            SET @TempScore = 100.0 * (@StressTempMax - @AdjustedTemp) / (@StressTempMax - @OptimalTempMax);
    END
    
    -- Step 3: Calculate humidity subscore (0-100)
    IF @AdjustedHumidity >= @OptimalHumidityMin AND @AdjustedHumidity <= @OptimalHumidityMax
    BEGIN
        -- Within optimal range = 100
        SET @HumidityScore = 100.0;
    END
    ELSE IF @AdjustedHumidity < @OptimalHumidityMin
    BEGIN
        -- Below optimal - linear decrease (assuming stress at 0% humidity)
        SET @HumidityScore = 100.0 * @AdjustedHumidity / @OptimalHumidityMin;
    END
    ELSE -- @AdjustedHumidity > @OptimalHumidityMax
    BEGIN
        -- Above optimal - linear decrease (assuming stress at 100% humidity)
        SET @HumidityScore = 100.0 * (100 - @AdjustedHumidity) / (100 - @OptimalHumidityMax);
    END
    
    -- Step 4: Combine as weighted average (60% temp, 40% humidity)
    SET @FinalScore = ROUND(0.6 * @TempScore + 0.4 * @HumidityScore, 0);
    
    -- Step 5: Clamp to 0-100 range
    IF @FinalScore < 0 SET @FinalScore = 0;
    IF @FinalScore > 100 SET @FinalScore = 100;
    
    RETURN @FinalScore;
END;
GO
