## SSIS Logging with CTEs
```sql
DECLARE  @PackageRunsTable TABLE  ( PackageRunId   INT IDENTITY(1,1) PRIMARY KEY
                                    , rn             INT NOT NULL
                                    , run_seconds   INT NULL
                                    , job_status     VARCHAR(50) NOT NULL
                                    , package_name   VARCHAR(1024) NOT NULL
                                    , package_id     UNIQUEIDENTIFIER NOT NULL
                                    , runtime_id     UNIQUEIDENTIFIER NOT NULL
                                    , starttime      DATETIME2(3) NOT NULL
                                    , endtime        DATETIME2(3) NULL
                                    , start_id       INT NOT NULL
                                    , end_id         INT NULL
                                    , run_as         VARCHAR(128) NULL
                                    , start_message  VARCHAR(2048) NULL
                                    , end_message    VARCHAR(2048) NULL
                                    , captured_at    DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME() ); 
DECLARE  @ExecutionRunsTable TABLE  ( ExecutionRunId   INT IDENTITY(1,1) PRIMARY KEY
                                    , Execution_Order            INT NOT NULL
                                    , duration_seconds   INT NULL
                                    , package_name   VARCHAR(1024) NOT NULL
                                    , source   VARCHAR(1024) NOT NULL
                                    , package_id     UNIQUEIDENTIFIER NOT NULL
                                    , runtime_id     UNIQUEIDENTIFIER NOT NULL
                                    , min_starttime      DATETIME2(3) NOT NULL
                                    , max_endtime        DATETIME2(3) NULL
                                    , ssis_id      INT NOT NULL
                                    , captured_at    DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME() ); 
DECLARE  @DurationMap TABLE  (      exclude_runs_over_longest_count   INT NULL
                                    , est_runtime_in_min INT
                                    , package_name   VARCHAR(1024) NOT NULL);

 DECLARE @Details INT = 0;
 DECLARE @PackageName VARCHAR(1024) = NULL;
 DECLARE @JobRN INT = NULL;
 DECLARE @RunTimeAlertLimitInMinutes INT = 1;
 DECLARE @GetAverages INT = NULL;
 DECLARE @ExcludeLongest INT = NULL;

 INSERT INTO @DurationMap (package_name,exclude_runs_over_longest_count,est_runtime_in_min)
 VALUES ('Scanner',1,1),('RunMulti',2,1),('MSMQSender',2,1),('MSMQRec',2,1),('DupeAlertFail',1,1)

SET @Details=1;
--SET @PackageName='Scanner';
SET @GetAverages=1
SET @JobRN=1
SET @ExcludeLongest=0

IF @GetAverages = 1
BEGIN
   SET @JobRN=NULL;
   SET @Details=0;
   IF @ExcludeLongest IS NULL
      SET @ExcludeLongest=0
END

IF @Details = 1
BEGIN
    IF @JobRN IS NULL
        SET @JobRN=1;
END

IF @PackageName IS NOT NULL AND @JobRN IS NULL
   SET @JobRN=1;
-- SET @JobRN=1;
  -- refactored 

  ;WITH PackageStart_CTE AS (
  SELECT
    ROW_NUMBER() OVER (PARTITION BY s.[source] ORDER BY s.starttime DESC) AS rn,
    s.[id]           AS start_id,
    s.[event]        AS start_event,
    s.[computer],
    s.[operator],
    s.[source]       AS package_name,
    s.[sourceid]     AS package_id,
    s.[executionid]  AS runtime_id,
    s.starttime,
    s.datacode,
    s.databytes,
    s.message        AS start_message
  FROM SSIS.dbo.sysssislog s WITH (NOLOCK)
  WHERE s.source IS NOT NULL and (s.source = @PackageName OR @PackageName IS NULL) 
  AND s.event = 'PackageStart'
  
),
PackageEnd_CTE AS (
  SELECT
    ROW_NUMBER() OVER (PARTITION BY e.executionid ORDER BY e.endtime DESC) AS rn,
    e.[id]           AS end_id,
    e.[event]        AS end_event,
    e.executionid    AS runtime_id,
    e.sourceid as package_id,
    e.endtime,
    e.message        AS end_message
  FROM SSIS.dbo.sysssislog e WITH (NOLOCK)
  WHERE  e.source IS NOT NULL and (e.source = @PackageName OR @PackageName IS NULL) 
  AND  e.event = 'PackageEnd'
) , Packages_CTE AS (
SELECT
 
  [job_status] = CASE  
                    WHEN pe.endtime IS NULL  AND GETDATE() < DATEADD(MINUTE, @RunTimeAlertLimitInMinutes, TRY_CAST(ps.starttime AS datetime)) THEN 'IN_PROGRESS'
                     WHEN pe.endtime IS NULL  AND GETDATE() >  DATEADD(MINUTE, @RunTimeAlertLimitInMinutes, TRY_CAST(ps.starttime AS datetime)) THEN 'RUNNING_OVER_RECOMMENDED_LIMIT'
                    WHEN pe.endtime IS NULL  THEN 'LONG_RUNNING'
                    WHEN pe.endtime IS NOT NULL AND TRY_CAST(pe.endtime AS datetime) >   DATEADD(MINUTE, @RunTimeAlertLimitInMinutes, TRY_CAST(ps.starttime AS datetime)) THEN 'COMPLETED_LONG'
                    ELSE 'COMPLETED' 
                END,
  ps.package_name,
  ps.package_id,
  ps.runtime_id,
  ps.starttime,
  pe.endtime,
  ps.start_id,
  pe.end_id,
  ps.computer as server,
  ps.[operator] as run_as,
  --ps.datacode,
 -- ps.databytes,
  ps.start_message,
  pe.end_message
FROM PackageStart_CTE ps
LEFT JOIN PackageEnd_CTE pe
  ON pe.runtime_id = ps.runtime_id --AND pe.rn = ps.rn and pe.package_id=ps.package_id
--WHERE ps.rn > 1
), PackageRun_CTE AS ( SELECT 
ROW_NUMBER() OVER (PARTITION BY Packages_CTE.package_name ORDER BY Packages_CTE.starttime DESC) AS rn,
Packages_CTE.job_status,
Packages_CTE.package_name,
Packages_CTE.package_id,
Packages_CTE.runtime_id,
Packages_CTE.starttime,
Packages_CTE.endtime,
Packages_CTE.start_id,
Packages_CTE.end_id,
Packages_CTE.run_as,
Packages_CTE.start_message,
Packages_CTE.end_message


 FROM Packages_CTE  
 )INSERT INTO @PackageRunsTable (rn, run_seconds,job_status, package_name, package_id, runtime_id, starttime, endtime, start_id, end_id, run_as, start_message, end_message )

 SELECT  PackageRun_CTE.rn,
 [run_seconds] =  DATEDIFF(SECOND, starttime, endtime),
PackageRun_CTE.job_status,
PackageRun_CTE.package_name,
PackageRun_CTE.package_id,
PackageRun_CTE.runtime_id,
PackageRun_CTE.starttime,
PackageRun_CTE.endtime,
PackageRun_CTE.start_id,
PackageRun_CTE.end_id,
PackageRun_CTE.run_as,
PackageRun_CTE.start_message,
PackageRun_CTE.end_message FROM PackageRun_CTE
 order by PackageRun_CTE.rn ;
 
 IF @GetAverages = 1
 BEGIN
  ;WITH RankedRuns AS (
    SELECT
      package_name,
      package_id,
      run_seconds,
      ROW_NUMBER() OVER (PARTITION BY package_name ORDER BY run_seconds DESC) AS rank_desc
    FROM @PackageRunsTable
  ),
  PackageStats AS (
    SELECT DISTINCT
      RankedRuns.package_name,
      RankedRuns.package_id,
      AVG(RankedRuns.run_seconds) OVER (PARTITION BY RankedRuns.package_name) AS average_run_seconds,
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY RankedRuns.run_seconds) OVER (PARTITION BY RankedRuns.package_name) AS median_run_seconds,
      MIN(RankedRuns.run_seconds) OVER (PARTITION BY RankedRuns.package_name) AS min_run_seconds,
      MAX(RankedRuns.run_seconds) OVER (PARTITION BY RankedRuns.package_name) AS max_run_seconds,
      AVG(CASE WHEN rank_desc > dm.exclude_runs_over_longest_count THEN CAST(RankedRuns.run_seconds AS FLOAT) END) OVER (PARTITION BY RankedRuns.package_name) AS average_run_seconds_excluding_longest,
      dm.exclude_runs_over_longest_count as ignore_top,
      dm.est_runtime_in_min * 60 as est_runtime_in_seconds,
      dm.est_runtime_in_min 

    FROM RankedRuns
    left join @DurationMap dm on RankedRuns.package_name=dm.package_name
  )
  SELECT *,[status]=case WHEN average_run_seconds_excluding_longest > est_runtime_in_seconds THEN 'WARNING' ELSE 'PASSED' END 
  ,[needs_review]=case WHEN max_run_seconds > est_runtime_in_seconds THEN 'WARNING' ELSE 'PASSED' END 
  FROM PackageStats
  ORDER BY package_name DESC;
 END
 ELSE
 BEGIN
 IF @Details = 1  
 BEGIN
  
   ;WITH Details_CTE   AS ( SELECT  
      ROW_NUMBER() OVER (PARTITION BY prt.package_name ORDER BY e.starttime ASC) AS Execution_Order,
      DATEDIFF(SECOND, 
      MIN(e.starttime) OVER (PARTITION BY  e.[source]),
      MAX(e.endtime) OVER (PARTITION BY   e.[source])
        ) AS duration_seconds,

      MIN(e.starttime) OVER (PARTITION BY  e.[source]) as min_starttime,
      MAX(e.endtime) OVER (PARTITION BY   e.[source]) as max_endtime,
      prt.package_name,
      prt.package_id,
      e.executionid,
      e.sourceid,
      e.source,
      prt.start_id

 
 
  FROM SSIS.dbo.sysssislog e WITH (NOLOCK)
  INNER JOIN @PackageRunsTable prt ON e.executionid = prt.runtime_id
  WHERE prt.package_name IS NOT NULL
    AND (prt.package_name = @PackageName OR @PackageName IS NULL)
    AND (@JobRN IS NULL OR prt.rn = @JobRN )
    AND e.message not in ('Validating','Cleanup') and e.event not in ('PackageStart','PackageEnd') and e.source <> prt.package_name
    ) INSERT INTO @ExecutionRunsTable (Execution_Order, duration_seconds,package_name, package_id, source, runtime_id, min_starttime, max_endtime,ssis_id) 
    SELECT Details_CTE.Execution_Order,Details_CTE.duration_seconds,Details_CTE.package_name,Details_CTE.package_id,Details_CTE.source,Details_CTE.sourceid,Details_CTE.min_starttime,Details_CTE.max_endtime,Details_CTE.start_id from Details_CTE order by Execution_Order


    SELECT ROW_NUMBER() OVER (PARTITION BY package_name ORDER BY min_starttime ASC) AS Execution_Order, 
        duration_seconds,
        package_name, 
        package_id, 
        source, 
        runtime_id, 
        min_starttime, 
        max_endtime,
        ssis_id FROM @ExecutionRunsTable
    group by duration_seconds,package_name, package_id, source, runtime_id, min_starttime, max_endtime,ssis_id
    order by min_starttime,ssis_id desc;
END
ELSE
 SELECT  rn, run_seconds,job_status, package_name, package_id, runtime_id, starttime, endtime, start_id, end_id, run_as, start_message, end_message FROM @PackageRunsTable  
 WHERE   (@JobRN IS NULL OR rn = @JobRN )
 order by start_id desc;
END
-- select * from dbo.sysssislog where sourceid='6B66E70F-DFC3-4EE7-8D27-59F61C99054A'
```