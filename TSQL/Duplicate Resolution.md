#### Duplicate records, select one with latest date 
```sql
select 
	A.Id
	, A.[hostname]
 	, A.[last_update]
	,A.rownum
	,A.max_date
 	,A.total_count
	, [rownum] = COUNT(*) OVER (PARTITION BY hostname order by hostname)
from (
	SELECT 
	  Id
	  ,[hostname]
	  ,[last_update]
	  , max_date = max(last_update) over(PARTITION BY hostname)
	  , [total_count] = COUNT(*) OVER (PARTITION BY hostname order by hostname)
	  , [rownum] = ROW_NUMBER() OVER (PARTITION BY hostname order by last_update DESC)
	 FROM [AdventureWorks2019].[dbo].[dups]  
) A
where A.rownum=1;
```