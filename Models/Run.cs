using System.Data.SqlClient;
using System.Text.Json;
using Dapper;

// 1. compute hashes
foreach (var a in activities)
{
    a.Hash = ActivityHash.ComputeHash(a);
    a.RunParametersJson = a.RunParameters != null ? JsonSerializer.Serialize(a.RunParameters) : null;
}

// 2. find existing rows by ActivityName and compare hashes
var names = activities.Select(x => x.ActivityName).Where(n => !string.IsNullOrEmpty(n)).Distinct().ToList();
var existingByName = connection.Query<(string ActivityName, string? Hash)>(
    "SELECT ActivityName, Hash FROM dbo.Activities WHERE ActivityName IN @Names", new { Names = names })
    .ToDictionary(x => x.ActivityName, x => x.Hash);

// 3. Decide per-activity: skip if name exists and hash matches, update if name exists and hash differs, insert if name not found
var toInsert = new List<Activity>();
var toUpdate = new List<Activity>();

foreach (var a in activities)
{
    if (string.IsNullOrEmpty(a.ActivityName) || string.IsNullOrEmpty(a.Hash))
    {
        // If missing name or hash, treat as insert
        toInsert.Add(a);
        continue;
    }

    if (existingByName.TryGetValue(a.ActivityName!, out var existingHash))
    {
        if (string.Equals(existingHash, a.Hash, StringComparison.OrdinalIgnoreCase))
        {
            // same content, skip
            continue;
        }
        else
        {
            // name exists but different content -> update
            toUpdate.Add(a);
            continue;
        }
    }

    // name not found -> insert
    toInsert.Add(a);
}

using var tx = connection.BeginTransaction();

const string insertSql = @"
INSERT INTO dbo.Activities
(ActivityName, ProductVersion, RunType, ActivityDescription, Duration, RunParametersJson, OnComplete, OnFail, OnTimeout, OnInaccessible, Hash)
VALUES
(@ActivityName, @ProductVersion, @RunType, @ActivityDescription, @Duration, @RunParametersJson, @OnComplete, @OnFail, @OnTimeout, @OnInaccessible, @Hash);";

const string updateSql = @"
UPDATE dbo.Activities SET
    ProductVersion = @ProductVersion,
    RunType = @RunType,
    ActivityDescription = @ActivityDescription,
    Duration = @Duration,
    RunParametersJson = @RunParametersJson,
    OnComplete = @OnComplete,
    OnFail = @OnFail,
    OnTimeout = @OnTimeout,
    OnInaccessible = @OnInaccessible,
    Hash = @Hash
WHERE ActivityName = @ActivityName;";

foreach (var a in toInsert)
{
    connection.Execute(insertSql, new
    {
        a.ActivityName,
        a.ProductVersion,
        a.RunType,
        a.ActivityDescription,
        a.Duration,
        RunParametersJson = a.RunParameters != null ? JsonSerializer.Serialize(a.RunParameters) : null,
        OnComplete = a.RunDependencies?.OnComplete,
        OnFail = a.RunDependencies?.OnFail,
        OnTimeout = a.RunDependencies?.OnTimeout,
        OnInaccessible = a.RunDependencies?.OnInaccessible,
        a.Hash
    }, tx);
}

foreach (var a in toUpdate)
{
    connection.Execute(updateSql, new
    {
        a.ActivityName,
        a.ProductVersion,
        a.RunType,
        a.ActivityDescription,
        a.Duration,
        RunParametersJson = a.RunParameters != null ? JsonSerializer.Serialize(a.RunParameters) : null,
        OnComplete = a.RunDependencies?.OnComplete,
        OnFail = a.RunDependencies?.OnFail,
        OnTimeout = a.RunDependencies?.OnTimeout,
        OnInaccessible = a.RunDependencies?.OnInaccessible,
        a.Hash
    }, tx);
}

tx.Commit();