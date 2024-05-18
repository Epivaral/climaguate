private WeatherData weatherData;

  protected override async Task OnInitializedAsync()
  {
    var response = await HttpClient.GetAsync("https://api.openweathermap.org/data/2.5/weather?q=Guatemala%20City&appid=7bd66a9b3ab059dc7a3ea686a2bbf2c0&units=metric");
    if (response.IsSuccessStatusCode)
    {
      weatherData = await response.Content.ReadFromJsonAsync<WeatherData>();
    }
  }

  public class WeatherData
  {
    public MainData Main { get; set; }
    public Weather[] Weather { get; set; }
  }

  public class MainData
  {
    public float Temp { get; set; }
  }

  public class Weather
  {
    public string Description { get; set; }
  }