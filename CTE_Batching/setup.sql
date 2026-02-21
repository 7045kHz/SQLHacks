DROP TABLE IF EXISTS dbo.pending_deployments;
DROP TABLE IF EXISTS dbo.deployments;
create table dbo.pending_deployments
(
	ReleaseId int,
	Asset_Name varchar(60),
	Job_Name varchar(60),
	[Order] int,
    [Status] varchar(20) default 'Pending',
	[StartTime] datetime default getutcdate(),
	[EndTime] datetime default getutcdate()
);
create table dbo.deployments
(
	ReleaseId int,
	Asset_Name varchar(60),
	Job_Name varchar(60),
	BatchId int,
	[Order] int,
    [Status] varchar(20),
	[StartTime] datetime default getutcdate(),
	[EndTime] datetime default getutcdate()
);
DECLARE @MaxBatchCount INT = 8;
DECLARE @StartTime1 datetime = DATEADD(HOUR, DATEDIFF(HOUR, 0, GETUTCDATE()), 0);
DECLARE @EndTime1 datetime = dateadd(hour, 6, @StartTime1);
DECLARE @StartTime2 datetime = dateadd(day, 1, @StartTime1);
DECLARE @EndTime2 datetime = dateadd(hour, 6, @StartTime2);
DECLARE @EndTime2alt datetime = dateadd(hour, 8, @StartTime2);
DECLARE @StartTime3 datetime =  dateadd(day, 1, @StartTime2);;
DECLARE @EndTime3 datetime = dateadd(hour, 6, @StartTime3);
DECLARE @EndTime3alt datetime = dateadd(hour, 5, @StartTime3);
DECLARE @StartTime4 datetime =  dateadd(day, 1, @StartTime3);
DECLARE @EndTime4 datetime = dateadd(hour, 6, @StartTime4);
DECLARE @EndTime4alt datetime = dateadd(hour, 8, @StartTime4);

insert into dbo.pending_deployments(ReleaseId, Asset_Name, Job_Name, [Order],[StartTime],[EndTime]) values
(1, 'Asset1', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset1', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset1', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset2', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset2', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset2', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset3', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset3', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset3', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset4', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset4', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset4', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset5', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset5', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset5', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset6', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset6', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset6', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset7', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset7', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset7', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset8', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset8', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset8', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset9', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset9', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset9', 'PostJob', 3, @StartTime1,@EndTime1),
(1, 'Asset10', 'PreJob', 1, @StartTime1,@EndTime1),
(1, 'Asset10', 'MainJob', 2, @StartTime1,@EndTime1),
(1, 'Asset10', 'PostJob', 3, @StartTime1,@EndTime1),

(2, 'Asset11', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset11', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset11', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset12', 'PreJob', 1, @StartTime2,@EndTime2alt),
(2, 'Asset12', 'MainJob', 2, @StartTime2,@EndTime2alt),
(2, 'Asset12', 'PostJob', 3, @StartTime2,@EndTime2alt),
(2, 'Asset13', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset13', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset13', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset14', 'PreJob', 1, @StartTime2,@EndTime2alt),
(2, 'Asset14', 'MainJob', 2, @StartTime2,@EndTime2alt),
(2, 'Asset14', 'PostJob', 3, @StartTime2,@EndTime2alt),
(2, 'Asset15', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset15', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset15', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset16', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset16', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset16', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset17', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset17', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset17', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset18', 'PreJob', 1, @StartTime2,@EndTime2alt),
(2, 'Asset18', 'MainJob', 2, @StartTime2,@EndTime2alt),
(2, 'Asset18', 'PostJob', 3, @StartTime2,@EndTime2alt),
(2, 'Asset19', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset19', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset19', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset20', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset20', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset20', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset21', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset21', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset21', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset22', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset22', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset22', 'PostJob', 3, @StartTime2,@EndTime2),
(2, 'Asset23', 'PreJob', 1, @StartTime2,@EndTime2),
(2, 'Asset23', 'MainJob', 2, @StartTime2,@EndTime2),
(2, 'Asset23', 'PostJob', 3, @StartTime2,@EndTime2),
(3, 'Asset24', 'PreJob', 1, @StartTime3,@EndTime3),
(3, 'Asset24', 'MainJob', 2, @StartTime3,@EndTime3),
(3, 'Asset24', 'PostJob', 3, @StartTime3,@EndTime3),
(3, 'Asset25', 'PreJob', 1, @StartTime3,@EndTime3),
(3, 'Asset25', 'MainJob', 2, @StartTime3,@EndTime3),
(3, 'Asset25', 'PostJob', 3, @StartTime3,@EndTime3),
(3, 'Asset26', 'PreJob', 1, @StartTime3,@EndTime3),
(3, 'Asset26', 'MainJob', 2, @StartTime3,@EndTime3),
(3, 'Asset26', 'PostJob', 3, @StartTime3,@EndTime3),

(4, 'Asset27', 'PreJob', 1, @StartTime4,@EndTime4),
(4, 'Asset27', 'MainJob', 2, @StartTime4,@EndTime4),
(4, 'Asset27', 'PostJob', 3, @StartTime4,@EndTime4),
(4, 'Asset28', 'PreJob', 1, @StartTime4,@EndTime4),
(4, 'Asset28', 'MainJob', 2, @StartTime4,@EndTime4),
(4, 'Asset28', 'PostJob', 3, @StartTime4,@EndTime4),
(4, 'Asset29', 'PreJob', 1, @StartTime4,@EndTime4),
(4, 'Asset29', 'MainJob', 2, @StartTime4,@EndTime4),
(4, 'Asset29', 'PostJob', 3, @StartTime4,@EndTime4),
(4, 'Asset30', 'PreJob', 1, @StartTime4,@EndTime4),
(4, 'Asset30', 'MainJob', 2, @StartTime4,@EndTime4),
(4, 'Asset30', 'PostJob', 3, @StartTime4,@EndTime4),
(4, 'Asset31', 'PreJob', 1, @StartTime4,@EndTime4),
(4, 'Asset31', 'MainJob', 2, @StartTime4,@EndTime4),
(4, 'Asset31', 'PostJob', 3, @StartTime4,@EndTime4),
(4, 'Asset32', 'PreJob', 1, @StartTime4,@EndTime4),
(4, 'Asset32', 'MainJob', 2, @StartTime4,@EndTime4),
(4, 'Asset32', 'PostJob', 3, @StartTime4,@EndTime4),
(4, 'Asset33', 'PreJob', 1, @StartTime1,@EndTime1),
(4, 'Asset33', 'MainJob', 2, @StartTime1,@EndTime1),
(4, 'Asset33', 'PostJob', 3, @StartTime1,@EndTime1),
(4, 'Asset34', 'PreJob', 1, @StartTime2,@EndTime2),
(4, 'Asset34', 'MainJob', 2, @StartTime2,@EndTime2),
(4, 'Asset34', 'PostJob', 3, @StartTime2,@EndTime2),
(4, 'Asset35', 'PreJob', 1, @StartTime2,@EndTime2),
(4, 'Asset35', 'MainJob', 2, @StartTime2,@EndTime2),
(4, 'Asset35', 'PostJob', 3, @StartTime2,@EndTime2),
(4, 'Asset36', 'PreJob', 1, @StartTime2,@EndTime2),
(4, 'Asset36', 'MainJob', 2, @StartTime2,@EndTime2),
(4, 'Asset36', 'PostJob', 3, @StartTime2,@EndTime2),
(4, 'Asset37', 'PreJob', 1, @StartTime2,@EndTime2),
(4, 'Asset37', 'MainJob', 2, @StartTime2,@EndTime2),
(4, 'Asset37', 'PostJob', 3, @StartTime2,@EndTime2),
(4, 'Asset38', 'PreJob', 1, @StartTime2,@EndTime2),
(4, 'Asset38', 'MainJob', 2, @StartTime2,@EndTime2),
(4, 'Asset38', 'PostJob', 3, @StartTime2,@EndTime2),
(4, 'Asset39', 'PreJob', 1, @StartTime2,@EndTime2),
(4, 'Asset39', 'MainJob', 2, @StartTime2,@EndTime2),
(4, 'Asset39', 'PostJob', 3, @StartTime2,@EndTime2),
(4, 'Asset40', 'PreJob', 1, @StartTime3,@EndTime3),
(4, 'Asset40', 'MainJob', 2, @StartTime3,@EndTime3),
(4, 'Asset40', 'PostJob', 3,@StartTime3,@EndTime3),

(5, 'Asset41', 'PreJob', 1, @StartTime3,@EndTime3alt),
(5, 'Asset41', 'MainJob', 2, @StartTime3,@EndTime3alt),
(5, 'Asset41', 'PostJob', 3, @StartTime3,@EndTime3alt),
(5, 'Asset42', 'PreJob', 1, @StartTime3,@EndTime3alt),
(5, 'Asset42', 'MainJob', 2, @StartTime3,@EndTime3alt),
(5, 'Asset42', 'PostJob', 3, @StartTime3,@EndTime3alt),
(5, 'Asset43', 'PreJob', 1, @StartTime2,@EndTime2alt),
(5, 'Asset43', 'MainJob', 2,@StartTime2,@EndTime2alt),
(5, 'Asset43', 'PostJob', 3,@StartTime2,@EndTime2alt),
(5, 'Asset44', 'PreJob', 1, @StartTime4,@EndTime4alt),
(5, 'Asset44', 'MainJob', 2, @StartTime4,@EndTime4alt),
(5, 'Asset44', 'PostJob', 3, @StartTime4,@EndTime4alt),
(5, 'Asset45', 'PreJob', 1, @StartTime4,@EndTime4alt),
(5, 'Asset45', 'MainJob', 2, @StartTime4,@EndTime4alt),
(5, 'Asset45', 'PostJob', 3, @StartTime4,@EndTime4alt),
(5, 'Asset46', 'PreJob', 1, @StartTime4,@EndTime4alt),
(5, 'Asset46', 'MainJob', 2, @StartTime4,@EndTime4alt),
(5, 'Asset46', 'PostJob', 3, @StartTime4,@EndTime4alt),

(6, 'Asset47', 'PreJob', 1,@StartTime3,@EndTime4alt),
(6, 'Asset47', 'MainJob', 2, @StartTime3,@EndTime4alt),
(6, 'Asset47', 'PostJob', 3,@StartTime3,@EndTime4alt),
(6, 'Asset48', 'PreJob', 1, @StartTime2,@EndTime3alt),
(6, 'Asset48', 'MainJob', 2, @StartTime2,@EndTime3alt),
(6, 'Asset48', 'PostJob', 3, @StartTime2,@EndTime3alt),
(6, 'Asset49', 'PreJob', 1, @StartTime1,@EndTime2alt),
(6, 'Asset49', 'MainJob', 2, @StartTime1,@EndTime2alt),
(6, 'Asset49', 'PostJob', 3, @StartTime1,@EndTime2alt),
(6, 'Asset50', 'PreJob', 1, @StartTime1,@EndTime2alt),
(6, 'Asset50', 'MainJob', 2, @StartTime1,@EndTime2alt),
(6, 'Asset50', 'PostJob', 3, @StartTime1,@EndTime2alt),
(6, 'Asset51', 'PreJob', 1, @StartTime1,@EndTime2alt),
(6, 'Asset51', 'MainJob', 2, @StartTime1,@EndTime2alt),
(6, 'Asset51', 'PostJob', 3, @StartTime1,@EndTime2alt),
(6, 'Asset52', 'PreJob', 1, @StartTime1,@EndTime2alt),
(6, 'Asset52', 'MainJob', 2, @StartTime1,@EndTime2alt),
(6, 'Asset52', 'PostJob', 3, @StartTime1,@EndTime2alt)
;


-- Created by GitHub Copilot in SSMS - review carefully before executing
-- Created by GitHub Copilot in SSMS - review carefully before executing

 -- Created by GitHub Copilot in SSMS - review carefully before executing

TRUNCATE TABLE dbo.deployments;


;WITH TimeWindowAssets AS (
    -- Get distinct assets per time window with ranking
    SELECT DISTINCT
        ReleaseId,
        Asset_Name,
        StartTime,
        EndTime,
        DENSE_RANK() OVER (ORDER BY StartTime, EndTime) AS TimeWindowRank
    FROM dbo.pending_deployments where [Status] = 'Pending'
),
TimeWindowBatchCounts AS (
    -- Calculate number of batches needed per time window
    SELECT 
        TimeWindowRank,
        StartTime,
        EndTime,
        CEILING(COUNT(DISTINCT Asset_Name) * 1.0 / @MaxBatchCount) AS BatchCount
    FROM TimeWindowAssets
    GROUP BY TimeWindowRank, StartTime, EndTime
),
CumulativeBatches AS (
    -- Calculate cumulative batch offset for each time window
    SELECT 
        TimeWindowRank,
        StartTime,
        EndTime,
        BatchCount,
        ISNULL(SUM(BatchCount) OVER (ORDER BY TimeWindowRank ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS BatchOffset
    FROM TimeWindowBatchCounts
),
AssetBatches AS (
    SELECT DISTINCT
        twa.ReleaseId,
        twa.Asset_Name,
        twa.StartTime,
        twa.EndTime,
        -- Add cumulative offset to batch number within time window
        cb.BatchOffset 
        + ((ROW_NUMBER() OVER (PARTITION BY twa.StartTime, twa.EndTime ORDER BY twa.Asset_Name) - 1) / @MaxBatchCount) + 1 AS BatchId
    FROM TimeWindowAssets twa
    INNER JOIN CumulativeBatches cb ON twa.TimeWindowRank = cb.TimeWindowRank
)
INSERT INTO dbo.deployments (ReleaseId, Asset_Name, Job_Name, BatchId, [Order], StartTime, EndTime)
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
ORDER BY ab.BatchId, pd.Asset_Name, pd.[Order];

-- Validation query
SELECT 
    BatchId, 
    COUNT(DISTINCT Asset_Name) AS AssetCount, 
    MIN(StartTime) AS StartTime, 
    MIN(EndTime) AS EndTime,
    COUNT(DISTINCT CAST(StartTime AS VARCHAR) + '|' + CAST(EndTime AS VARCHAR)) AS UniqueTimeWindows
FROM dbo.deployments
GROUP BY BatchId
ORDER BY BatchId;

select * FROM dbo.deployments order by BatchId, StartTime, EndTime, Asset_Name, [Order];
select * FROM dbo.pending_deployments where [Status] = 'Pending' order by StartTime, EndTime, Asset_Name, [Order];
