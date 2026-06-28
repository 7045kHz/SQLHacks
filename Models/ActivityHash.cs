using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace SQLHacks.Models
{
    public static class ActivityHash
    {
        // Compute SHA256 hex hash of the canonical JSON representation of an activity.
        // The canonicalization orders object properties alphabetically and excludes the 'hash' property.
        public static string ComputeHash(Activity activity)
        {
            if (activity is null) throw new ArgumentNullException(nameof(activity));

            // Serialize to JSON then parse to JsonDocument for canonicalization
            var json = JsonSerializer.Serialize(activity, new JsonSerializerOptions { IgnoreNullValues = true });
            using var doc = JsonDocument.Parse(json);
            var canonical = CanonicalizeElement(doc.RootElement);

            using var sha = SHA256.Create();
            var bytes = Encoding.UTF8.GetBytes(canonical);
            var hash = sha.ComputeHash(bytes);
            return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
        }

        private static string CanonicalizeElement(JsonElement element)
        {
            switch (element.ValueKind)
            {
                case JsonValueKind.Object:
                    var props = element.EnumerateObject()
                        .Where(p => !string.Equals(p.Name, "hash", StringComparison.OrdinalIgnoreCase))
                        .OrderBy(p => p.Name, StringComparer.Ordinal);

                    var sb = new StringBuilder();
                    sb.Append('{');
                    var first = true;
                    foreach (var prop in props)
                    {
                        if (!first) sb.Append(',');
                        first = false;
                        sb.Append('"').Append(prop.Name).Append('"').Append(':');
                        sb.Append(CanonicalizeElement(prop.Value));
                    }
                    sb.Append('}');
                    return sb.ToString();

                case JsonValueKind.Array:
                    var sbA = new StringBuilder();
                    sbA.Append('[');
                    var f = true;
                    foreach (var item in element.EnumerateArray())
                    {
                        if (!f) sbA.Append(',');
                        f = false;
                        sbA.Append(CanonicalizeElement(item));
                    }
                    sbA.Append(']');
                    return sbA.ToString();

                case JsonValueKind.String:
                    return '"' + EscapeString(element.GetString() ?? string.Empty) + '"';

                case JsonValueKind.Number:
                    return element.GetRawText();

                case JsonValueKind.True:
                    return "true";

                case JsonValueKind.False:
                    return "false";

                case JsonValueKind.Null:
                default:
                    return "null";
            }
        }

        private static string EscapeString(string s)
        {
            return s
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\b", "\\b")
                .Replace("\f", "\\f")
                .Replace("\n", "\\n")
                .Replace("\r", "\\r")
                .Replace("\t", "\\t");
        }
    }
}
