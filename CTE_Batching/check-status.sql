

DECLARE @MaxBatchCount INT = 8;

;WITH TimeWindowAssets AS (
        -- Step 1: Get distinct assets for each time window and assign a rank to each time window
        -- Only consider pending deployments that are enabled and do not have a corresponding deployment record with status 'Disabled' or 'Sent'
        SELECT DISTINCT
            ReleaseId,
            Asset_Name,
            StartTime,
            EndTime,
            DENSE_RANK() OVER (ORDER BY StartTime, EndTime) AS TimeWindowRank
        FROM dbo.pending_deployments 
        WHERE [Enabled] = 1
        AND NOT EXISTS (
            SELECT 1 
            FROM dbo.deployments d
            WHERE d.ReleaseId = pending_deployments.ReleaseId
            AND d.Asset_Name = pending_deployments.Asset_Name
            AND d.StartTime = pending_deployments.StartTime
            AND d.EndTime = pending_deployments.EndTime
            AND d.Status  IN ('Disabled','Sent')
        )
    ),
    TimeWindowBatchCounts AS (
        -- Step 2: Calculate the number of batches needed for each time window based on the count of distinct assets
        -- The CEILING function is used to round up to the nearest whole number, ensuring that any remaining assets that don't fill a complete batch still get assigned a batch
        SELECT 
            TimeWindowRank,
            StartTime,
            EndTime,
            CEILING(COUNT(DISTINCT Asset_Name) * 1.0 / @MaxBatchCount) AS BatchCount
        FROM TimeWindowAssets
        GROUP BY TimeWindowRank, StartTime, EndTime
    ),
    CumulativeBatches AS (
        -- Step 3: Calculate the cumulative batch offset for each time window to ensure globally unique batch IDs across all windows
        -- The batch offset is the total number of batches from all previous time windows, which allows us to assign unique batch IDs when we add the batch number within the current window
        SELECT 
            TimeWindowRank,
            StartTime,
            EndTime,
            BatchCount,
            ISNULL(SUM(BatchCount) OVER (ORDER BY TimeWindowRank ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS BatchOffset
        FROM TimeWindowBatchCounts
    ),
    AssetBatches AS (
        -- Step 4: Assign batch IDs to each asset by adding the cumulative batch offset to the batch number calculated within each time window
        -- The batch number within the time window is determined by the row number of the asset ordered by Asset_Name, divided by the maximum batch count, and then adding 1 to start batch IDs from 1 instead of 0
        SELECT DISTINCT
            twa.ReleaseId,
            twa.Asset_Name,
            twa.StartTime,
            twa.EndTime,
            cb.BatchOffset + ((ROW_NUMBER() OVER (PARTITION BY twa.StartTime, twa.EndTime ORDER BY twa.Asset_Name) - 1) / @MaxBatchCount) + 1 AS BatchId
        FROM TimeWindowAssets twa
        INNER JOIN CumulativeBatches cb ON twa.TimeWindowRank = cb.TimeWindowRank
    ),
    SourceData AS (
        -- Step 5: Prepare the source data for the MERGE operation by joining the pending_deployments with the AssetBatches to get the BatchId for each asset
        -- Only include pending deployments that are enabled to ensure we are only processing active deployments
        SELECT 
            pd.ReleaseId,
            pd.Asset_Name,
            pd.Job_Name,
            ab.BatchId,
            pd.[Order],
            pd.StartTime,
            pd.EndTime
        FROM dbo.pending_deployments pd
        INNER JOIN AssetBatches ab 
            ON pd.ReleaseId = ab.ReleaseId 
            AND pd.Asset_Name = ab.Asset_Name
            AND pd.StartTime = ab.StartTime
            AND pd.EndTime = ab.EndTime
        WHERE pd.[Enabled] = 1
    ) SELECT * FROM SourceData order by StartTime, BatchId,Asset_Name, [Order];

-- Create a new run in run_history for the current batch of deployments being processed, and insert details for each asset in run_history_details. This allows us to track the execution of each batch and analyze the results later.

DECLARE @CurrentRun INT = (SELECT ISNULL(MAX(Run), 0) FROM dbo.run_history) + 1;
insert into dbo.run_history (Run, BatchId, AssetCount, StartTime, EndTime, UniqueTimeWindows)
SELECT 
    [Run] = @CurrentRun,
    BatchId, 
    COUNT(DISTINCT Asset_Name) AS AssetCount, 
    MIN(StartTime) AS StartTime, 
    MIN(EndTime) AS EndTime,
    COUNT(DISTINCT CAST(StartTime AS VARCHAR) + '|' + CAST(EndTime AS VARCHAR)) AS UniqueTimeWindows
 
FROM dbo.deployments
WHERE Status = 'initialized'
GROUP BY BatchId
ORDER BY BatchId;


INSERT INTO dbo.run_history_details (Run, BatchId, Asset_Name, RowsPerAsset, StartTime, EndTime, UniqueTimeWindows)
SELECT 
    [Run] = @CurrentRun,
    BatchId, 
    Asset_Name,
    COUNT(*) AS RowsPerAsset,
    MIN(StartTime) AS StartTime, 
    MIN(EndTime) AS EndTime,
    COUNT(DISTINCT CONVERT(VARCHAR(50), StartTime, 121) + '|' + CONVERT(VARCHAR(50), EndTime, 121)) AS UniqueTimeWindows
FROM dbo.deployments
WHERE Status = 'initialized'
GROUP BY BatchId, Asset_Name
ORDER BY BatchId, Asset_Name;


select * from dbo.run_history;
select * from dbo.run_history_details where Asset_Name='Asset60';
select * from dbo.pending_deployments;

select * from dbo.deployments where StartTime >= DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()), 0)
  AND StartTime < DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()) + 1, 0)

select * from dbo.deployments
