-- Creates a table to store Activity records from Models/Activity.cs
-- Stores `runParameters` as JSON and flattens `runDependencies` into columns.
IF OBJECT_ID ('dbo.Activities', 'U') IS NOT NULL
DROP TABLE dbo.Activities;

CREATE TABLE
    dbo.Activities (
        Id INT IDENTITY (1, 1) PRIMARY KEY,
        ActivityName VARCHAR(200) NOT NULL,
        ProductVersion VARCHAR(100) NULL,
        RunType VARCHAR(50) NULL,
        ActivityDescription VARCHAR(MAX) NULL,
        Duration INT NULL,
        -- Store arbitrary runParameters as JSON (nullable)
        RunParametersJson VARCHAR(MAX) NULL,
        -- Flattened runDependencies
        OnComplete VARCHAR(50) NULL,
        OnFail VARCHAR(50) NULL,
        OnTimeout VARCHAR(50) NULL,
        OnInaccessible VARCHAR(50) NULL,
        -- Hash of the activity (e.g., SHA256 hex). Nullable.
        Hash VARCHAR(128) NULL,
        CreatedAt DATETIME2 (3) NOT NULL DEFAULT SYSUTCDATETIME ()
    );

-- Optional: ensure RunParametersJson is valid JSON when not NULL
ALTER TABLE dbo.Activities ADD CONSTRAINT CK_Activities_RunParametersJson_IsJson CHECK (
    RunParametersJson IS NULL
    OR ISJSON (RunParametersJson) = 1
);

-- Example: insert from JSON file (requires SQL Server 2016+ with OPENROWSET/BULK and appropriate permissions)
-- BULK import sample (uncomment and adjust path when running on the server):
-- DECLARE @json NVARCHAR(MAX);
-- SELECT @json = BulkColumn
-- FROM OPENROWSET (BULK 'C:\path\to\Data\activities.json', SINGLE_CLOB) AS j;
--
-- INSERT INTO dbo.Activities (ActivityName, ProductVersion, RunType, ActivityDescription, Duration, RunParametersJson, OnComplete, OnFail, OnTimeout, OnInaccessible)
-- SELECT
--     a.value('(/activityName)[1]', 'VARCHAR(200)'),
--     a.value('(/productVersion)[1]', 'VARCHAR(100)'),
--     a.value('(/runType)[1]', 'VARCHAR(50)'),
--     a.value('(/activityDescription)[1]', 'VARCHAR(MAX)'),
--     TRY_CAST(a.value('(/duration)[1]', 'VARCHAR(50)') AS INT),
--     -- convert the runParameters object to JSON string using JSON_QUERY
--     JSON_QUERY(@json, '$.activities[' + CONVERT( NVARCHAR(10), [ordinal]) + '].runParameters'),
--     JSON_VALUE(a.query('.'), '$.runDependencies.OnComplete'),
--     JSON_VALUE(a.query('.'), '$.runDependencies.OnFail'),
--     JSON_VALUE(a.query('.'), '$.runDependencies.OnTimeout'),
--     JSON_VALUE(a.query('.'), '$.runDependencies.OnInaccessible')
-- FROM OPENJSON(@json, '$.activities') WITH ( [ordinal] INT '$.ordinal' ) as idx
-- CROSS APPLY OPENJSON(@json, '$.activities[' + CONVERT(NVARCHAR(10), idx.[ordinal]) + ']') as a;

-- INSERT INTO dbo.Activities (ActivityName, ProductVersion, RunType, ActivityDescription, Duration, RunParametersJson, OnComplete, OnFail, OnTimeout, OnInaccessible, Hash)
-- SELECT
--     JSON_VALUE(a.[value], '$.activityName'),
--     JSON_VALUE(a.[value], '$.productVersion'),
--     JSON_VALUE(a.[value], '$.runType'),
--     JSON_VALUE(a.[value], '$.activityDescription'),
--     TRY_CAST(JSON_VALUE(a.[value], '$.duration') AS INT),
--     JSON_QUERY(a.[value], '$.runParameters'),
--     JSON_VALUE(a.[value], '$.runDependencies.OnComplete'),
--     JSON_VALUE(a.[value], '$.runDependencies.OnFail'),
--     JSON_VALUE(a.[value], '$.runDependencies.OnTimeout'),
--     JSON_VALUE(a.[value], '$.runDependencies.OnInaccessible'),
--     -- Compute SHA-256 hex string of the entire activity JSON object (excluding any pre-existing hash field if present client-side)
--     LOWER(SUBSTRING(sys.fn_varbintohexstr(HASHBYTES('SHA2_256', JSON_QUERY(a.[value]))), 3, 8000))
-- FROM OPENJSON(@json, '$.activities') AS a;