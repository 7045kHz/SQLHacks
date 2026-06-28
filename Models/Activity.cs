using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace SQLHacks.Models
{
    public class ActivitiesRoot
    {
        [JsonPropertyName("activities")]
        public List<Activity> Activities { get; set; } = new List<Activity>();
    }

    public class Activity
    {
        [JsonPropertyName("activityName")]
        public string? ActivityName { get; set; }

        [JsonPropertyName("productVersion")]
        public string? ProductVersion { get; set; }

        [JsonPropertyName("runType")]
        public string? RunType { get; set; }

        [JsonPropertyName("activityDescription")]
        public string? ActivityDescription { get; set; }

        [JsonPropertyName("duration")]
        public int? Duration { get; set; }

        [JsonPropertyName("hash")]
        public string? Hash { get; set; }

        [JsonPropertyName("runParameters")]
        public Dictionary<string, string>? RunParameters { get; set; }

        [JsonPropertyName("runDependencies")]
        public RunDependencies? RunDependencies { get; set; }
    }

    public class RunDependencies
    {
        [JsonPropertyName("OnComplete")]
        public string? OnComplete { get; set; }

        [JsonPropertyName("OnFail")]
        public string? OnFail { get; set; }

        [JsonPropertyName("OnTimeout")]
        public string? OnTimeout { get; set; }

        [JsonPropertyName("OnInaccessible")]
        public string? OnInaccessible { get; set; }
    }
}
