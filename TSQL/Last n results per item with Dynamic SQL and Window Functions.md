## Dynamic SQL code
```sql
DECLARE @C int, @I int
DECLARE @SQL NVARCHAR(MAX)
DECLARE @REPORT_TYPE  NVARCHAR(4) = 'LAST'
DECLARE @ORDER  NVARCHAR(20)
-- DECLARE  @P TABLE([JOB_Name] varchar(20), r1 int , r2 int, r3 int )

SET @C = 4;

SET @ORDER = (SELECT DISTINCT  CASE  
	WHEN  UPPER(@REPORT_TYPE) = 'LAST' THEN 'DESC'
	WHEN  UPPER(@REPORT_TYPE) = 'NEXT'  THEN	 'ASC'
	ELSE 'DESC'
END);

SET @I = 1

SET @SQL = N'	SELECT F.* FROM (
		SELECT row_number() OVER( PARTITION BY JOB_Name order by LastUpdated '+@ORDER+' ) as rn
		, S.[JOB_Name]
		, S.[LastUpdated] as ''CURRENT_DATE'' 
		, S.[Status] as ''CURRENT_STATUS''';

WHILE @I < @C 
BEGIN
	SET @SQL = CONCAT(@SQL,CHAR(10)+'		, [STATUS_' + CONVERT(NVARCHAR(10),@I) +  '] = LEAD(S.[Status],'+CONVERT(NVARCHAR(10),@I) +') OVER(PARTITION BY JOB_Name order by S.[JOB_Name])'+CHAR(10))
	SET @SQL = CONCAT(@SQL,'		, [DATE_' + CONVERT(NVARCHAR(10),@I) +  '] = LEAD(S.[LastUpdated],'+CONVERT(NVARCHAR(10),@I) +') OVER(PARTITION BY JOB_Name order by S.[JOB_Name])'+CHAR(10))
	SET @I = @I + 1
END

SET @SQL=CONCAT(@SQL,'
		FROM (
			SELECT  row_number() OVER( PARTITION BY JOB_Name order by LastUpdated desc) as rn
					,[JOB_Name]
					,[Status]
					,[LastUpdated]
					,[StartMins]
					,[StartTime]
		  
			  FROM [PROTO].[ETL].[JOB_SCHEDULE]
		) S
		WHERE S.rn <= '+CONVERT(NVARCHAR(10),@C)+ '
	) F 
	WHERE F.rn=1')

PRINT @SQL

EXEC sp_executesql @SQL ;
-- PRINT @SQL
/*
 	SELECT F.* FROM (
		SELECT row_number() OVER( PARTITION BY JOB_Name order by LastUpdated DESC ) as rn
		, S.[JOB_Name]
		, S.[LastUpdated] as 'CURRENT_DATE' 
		, S.[Status] as 'CURRENT_STATUS'
		, [STATUS_1] = LEAD(S.[Status],1) OVER(PARTITION BY JOB_Name order by S.[JOB_Name])
		, [DATE_1] = LEAD(S.[LastUpdated],1) OVER(PARTITION BY JOB_Name order by S.[JOB_Name])

		, [STATUS_2] = LEAD(S.[Status],2) OVER(PARTITION BY JOB_Name order by S.[JOB_Name])
		, [DATE_2] = LEAD(S.[LastUpdated],2) OVER(PARTITION BY JOB_Name order by S.[JOB_Name])

		, [STATUS_3] = LEAD(S.[Status],3) OVER(PARTITION BY JOB_Name order by S.[JOB_Name])
		, [DATE_3] = LEAD(S.[LastUpdated],3) OVER(PARTITION BY JOB_Name order by S.[JOB_Name])

		FROM (
			SELECT  row_number() OVER( PARTITION BY JOB_Name order by LastUpdated desc) as rn
					,[JOB_Name]
					,[Status]
					,[LastUpdated]
					,[StartMins]
					,[StartTime]
		  
			  FROM [PROTO].[ETL].[JOB_SCHEDULE]
		) S
		WHERE S.rn <= 4
	) F 
	WHERE F.rn=1

 */
```