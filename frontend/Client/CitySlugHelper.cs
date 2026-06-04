using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace BlazorApp.Client;

public static class CitySlugHelper
{
    public static string ToSlug(string cityName)
    {
        if (string.IsNullOrWhiteSpace(cityName)) return "";
        var normalized = cityName.Normalize(NormalizationForm.FormD);
        var stripped = new string(normalized.Where(c =>
            CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark).ToArray());
        return Regex.Replace(stripped.ToLowerInvariant(), @"[^a-z0-9]+", "-").Trim('-');
    }

    public record CityEntry(string CityCode, string CityName);

    public static string? SlugToCityCode(string slug, IEnumerable<CityEntry> cities) =>
        cities.FirstOrDefault(c => ToSlug(c.CityName) == slug)?.CityCode;

    public static string GetSoilTypeDescription(string soilType) => soilType switch
    {
        "Andosol" => "Andosol - Suelos volcánicos muy fértiles",
        "Fluvisol" => "Fluvisol - Suelos aluviales de valles",
        "Acrisol"  => "Acrisol - Suelos ácidos tropicales",
        "Regosol"  => "Regosol - Suelos jóvenes poco desarrollados",
        "Cambisol" => "Cambisol - Suelos de desarrollo moderado",
        "Leptosol" => "Leptosol - Suelos delgados sobre roca",
        "Luvisol"  => "Luvisol - Suelos con acumulación de arcilla",
        _          => $"{soilType} - Tipo de suelo especializado"
    };

    public static string GetClimateDescription(string climateZone) => climateZone switch
    {
        "Aw"  => "Aw - Sabana tropical (lluvias estacionales)",
        "Af"  => "Af - Ecuatorial lluvioso (lluvia constante)",
        "Am"  => "Am - Monzónico tropical (muy lluvioso)",
        "Cwa" => "Cwa - Subtropical húmedo (invierno seco)",
        "Cwb" => "Cwb - Oceánico subtropical de altura (templado de montaña)",
        _     => $"{climateZone} - Zona climática especializada"
    };
}
