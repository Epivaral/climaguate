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
}
