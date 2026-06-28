
## Basic UNION

Needs to have same number of columns and needs to have like data types for columns. 
No duplicates.

```sql
SELECT 
	  [Order Type] = 'Customer Order',
	  [Order ID] = [SalesOrderID],
      [OrderDate],
	TotalDue

FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]

WHERE YEAR([OrderDate]) = 2013

UNION

SELECT
	   [Order Type] = 'Vendor Order',
	   [Order ID] = [PurchaseOrderID],
       [OrderDate],
	TotalDue

FROM [AdventureWorks2019].[Purchasing].[PurchaseOrderHeader]

WHERE YEAR([OrderDate]) = 2013
```
## UNION ALL

Needs to have same number of columns and needs to have like data types for columns. 
Allows for duplicates

```sql
SELECT 
      [OrderDate]

FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]

WHERE YEAR([OrderDate]) = 2013

UNION ALL

SELECT
       [OrderDate]
	TotalDue

FROM [AdventureWorks2019].[Purchasing].[PurchaseOrderHeader]

WHERE YEAR([OrderDate]) = 2013

```