## ISNULL replacing null data

```sql
SELECT  
       [Title]
	  ,[Modified Title] = ISNULL([Title], 'No Title')
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]

FROM [AdventureWorks2019].[Person].[Person]
```
## ISNULL in WHERE clause

```sql

SELECT 
       [SalesQuota]
      ,[Bonus]
      ,[CommissionPct]
      ,[SalesYTD]
      ,[SalesLastYear]

FROM [AdventureWorks2019].[Sales].[SalesPerson]

WHERE ISNULL([SalesQuota], 0) != 250000
```