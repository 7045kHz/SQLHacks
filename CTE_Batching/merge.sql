
/*
This script performs an UPSERT operation to synchronize deployment records from pending_deployments 
to the deployments table. Assets are grouped into batches based on their time windows (StartTime/EndTime), 
with each batch containing a maximum number of assets defined by @MaxBatchCount.

The script consists of the following steps:
1. Update existing deployment records to 'Disabled' if their corresponding pending_deployments record is disabled and the deployment status is 'initialized'.
2. Use Common Table Expressions (CTEs) to calculate batch assignments for assets based on their time windows, ensuring that batch IDs are globally unique across all time windows.
3. Perform a MERGE operation to insert new deployment records or update existing ones with the calculated BatchId, Order, StartTime, and EndTime from the pending_deployments.
  
Every time it is run, it ensures that the deployments table is up-to-date with the latest enabled pending deployments, while also maintaining the integrity of batch assignments based on time windows.
*/

-- Maximum number of assets allowed per batch
DECLARE @MaxBatchCount INT = 8;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Step 1: Update deployments to 'Disabled' when dbo.pending_deployments job has been disabled 'initialized'
    -- This ensures that any pending_deployments now marked as disabled, but previously added into dbo.deployments as initialized is now marked as 'Disabled' in deployments.
    UPDATE d
        SET d.[Status] = 'Disabled'
    FROM dbo.deployments d
    INNER JOIN dbo.pending_deployments pd
        ON d.ReleaseId = pd.ReleaseId
        AND d.Asset_Name = pd.Asset_Name
        AND d.Job_Name = pd.Job_Name
    WHERE pd.[Enabled] <> 1
        AND d.[Status] = 'initialized';

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
    )
    -- Step 6: Use a MERGE statement to perform an UPSERT operation on the deployments table
    -- When a match is found based on ReleaseId, Asset_Name, and Job_Name, update the existing record with the new BatchId, Order, StartTime, and EndTime
    MERGE dbo.deployments AS target
    USING SourceData AS source
    ON (
        target.ReleaseId = source.ReleaseId
        AND target.Asset_Name = source.Asset_Name
        AND target.Job_Name = source.Job_Name
    )
    WHEN MATCHED THEN
        UPDATE SET
            target.BatchId = source.BatchId,
            target.[Order] = source.[Order],
            target.StartTime = source.StartTime,
            target.EndTime = source.EndTime
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ReleaseId, Asset_Name, Job_Name, BatchId, [Order], StartTime, EndTime)
        VALUES (source.ReleaseId, source.Asset_Name, source.Job_Name, source.BatchId, source.[Order], source.StartTime, source.EndTime);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Rollback on any error to maintain data integrity
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;