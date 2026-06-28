# JOIN (aka INNER JOIN)
## Basic join between two tables with a relationship

Only data that match the ON condition and exists in both tables will be displayed. JOIN is interchangeable with INNER JOIN

```sql

SELECT 
       B.FirstName
      ,B.LastName
      ,B.PersonType
      ,A.[TerritoryID]
      ,A.[SalesQuota]
      ,A.[Bonus]
      ,A.[CommissionPct]
      ,A.[SalesYTD]
      ,A.[SalesLastYear]

  FROM [AdventureWorks2019].[Sales].[SalesPerson] A
  JOIN [AdventureWorks2019].[Person].[Person] B
  ON A.BusinessEntityID = B.BusinessEntityID

```
## Basic join between multiple tables with a relationship

Only data that match the ON condition will be displayed. JOIN is interchangeable with INNER JOIN

```sql

SELECT
	A.[BusinessEntityID],
	A.[FirstName],
	A.[LastName],
	B.[JobTitle],
	B.VacationHours,
	B.SickLeaveHours,
	C.[EmailAddress]

FROM [Person].[Person] A
INNER JOIN [HumanResources].[Employee] B
ON A.BusinessEntityID = B.BusinessEntityID
INNER JOIN [Person].[EmailAddress] C
ON A.BusinessEntityID = C.BusinessEntityID

WHERE A.[FirstName] = 'John'

```

# LEFT OUTER JOIN (aka OUTER JOIN)

LEFT refers to the left most table. In other words, the table left of it will be treated as the primary table to show all records from. When there's no match in the second table, NULLs will be displayed in their respective columns.

## Basic join between tables with a relationship

Data that match the ON even if NULL condition displayed. 

```sql

SELECT
A.[BusinessEntityID],
A.[FirstName],
A.[LastName],
B.[JobTitle],
B.VacationHours,
B.SickLeaveHours,
C.[EmailAddress]

FROM [Person].[Person] A
LEFT OUTER JOIN [HumanResources].[Employee] B
ON A.BusinessEntityID = B.BusinessEntityID
LEFT OUTER JOIN  [Person].[EmailAddress] C
ON A.BusinessEntityID = C.BusinessEntityID

WHERE A.[FirstName] = 'John'

```
## Basic join between multiple tables with a relationship

```sql

SELECT
A.[BusinessEntityID],
A.[FirstName],
A.[LastName],
B.[JobTitle],
B.VacationHours,
B.SickLeaveHours,
C.[EmailAddress]

FROM [Person].[Person] A
LEFT OUTER JOIN [HumanResources].[Employee] B
ON A.BusinessEntityID = B.BusinessEntityID
LEFT OUTER JOIN  [Person].[EmailAddress] C
ON A.BusinessEntityID = C.BusinessEntityID

WHERE A.[FirstName] = 'John'

```