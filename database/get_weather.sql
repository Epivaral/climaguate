CREATE PROCEDURE weather.GetWeather
    @CityCode CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT distinct  top(5)
		[Name],
        Weather_Description,
        [Image] AS Weather_Icon,
        Main_Temp,
        Main_Feels_Like,
        Main_Pressure,
        Main_Humidity,
        Main_Temp_Min,
        Main_Temp_Max,
        Main_Sea_Level,
        Main_Grnd_Level,
        isnull(str(Visibility),'n/a') as Visibility,
        Wind_Speed,
        Wind_Deg,
        Wind_Gust,
        Clouds_All,
        isnull(str(Rain_1h,12,2),'n/a') as Rain_1h,
        isnull(str(Rain_3h,12,2),'n/a') as Rain_3h,
        Date_gt AS CollectionDate, -- Convert Dt to Guatemala date
        date_sunrise  AS SunriseDate,
        date_sunset  AS SunsetDate,
        I.Start_Color,
        I.End_Color
    FROM weather.WeatherData D
	LEFT JOIN [weather].[icons] I
	ON D.Weather_Id = I.ID AND D.Weather_Icon = I.Icon
    WHERE CityCode = @CityCode
	order by CollectionDate desc;
END;
GO
