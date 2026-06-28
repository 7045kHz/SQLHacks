## Notes
(https://learn.microsoft.com/en-us/sql/t-sql/queries/table-value-constructor-transact-sql?view=sql-server-ver15)

## Getting the MAX Column of multiple MAX Columns
(https://stackoverflow.com/questions/71022/sql-max-of-multiple-columns)

 
```sql
SELECT [Other Fields],
  (SELECT Max(v) 
   FROM (VALUES (date1), (date2), (date3),...) AS value(v)) as [MaxDate]
FROM [YourTableName]
```
### Example

```sql

  SELECT (
  SELECT Max(v) 
   FROM (VALUES (MAX([BirthDate] )), ( MAX([HireDate])), ( MAX([ModifiedDate])) ) AS value(v)) as [MaxDate]
FROM [AdventureWorks2019].[HumanResources].[Employee]

```
 