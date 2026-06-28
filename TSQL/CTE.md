### Basic CTE
```sql
WITH Sales AS
(
	SELECT 
	       OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
	      ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
	FROM AdventureWorks2019.Sales.SalesOrderHeader
)

,Top10Sales AS
(
	SELECT
		OrderMonth,
		Top10Total = SUM(TotalDue)
	FROM Sales
	WHERE OrderRank <= 10
	GROUP BY OrderMonth
)


SELECT
	A.OrderMonth,
	A.Top10Total,
	PrevTop10Total = B.Top10Total

FROM Top10Sales A
	LEFT JOIN Top10Sales B
		ON A.OrderMonth = DATEADD(MONTH,1,B.OrderMonth)

ORDER BY 1
```
### Recursive CTE
#### Number Series Example
```sql
WITH NumberSeries AS
(
	SELECT
	 1 AS MyNumber
	
	UNION  ALL
	
	SELECT 
		MyNumber + 1
	FROM NumberSeries
	WHERE MyNumber < 100
)

SELECT
	MyNumber
FROM NumberSeries
```
#### Date Seriese Example
```sql
WITH Dates AS
(
	SELECT
	 CAST('01-01-2023' AS DATE) AS MyDate
	
	UNION ALL
	
	SELECT
	DATEADD(DAY, 1, MyDate)
	FROM Dates
	WHERE MyDate < CAST('12-31-2023' AS DATE)
)

SELECT
	MyDate

FROM Dates
	OPTION (MAXRECURSION 365)
```