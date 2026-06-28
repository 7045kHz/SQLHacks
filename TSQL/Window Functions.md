### Window Function using OVER()

##### YTD Sales Via Aggregate Query:
```sql
SELECT BusinessEntityID
      ,TerritoryID
      ,SalesQuota
      ,Bonus
      ,CommissionPct
      ,SalesYTD
	  ,SalesLastYear
      ,[Total YTD Sales] = SUM(SalesYTD) OVER()
      ,[Max YTD Sales] = MAX(SalesYTD) OVER()
      ,[% of Best Performer] = SalesYTD/MAX(SalesYTD) OVER()

FROM AdventureWorks2019.Sales.SalesPerson
```
|BusinessEntityID|TerritoryID|SalesQuota|Bonus|CommissionPct|SalesYTD|SalesLastYear|Total YTD Sales|Max YTD Sales|% of Best Performer|
|----|----|----|----|----|----|----|----|----|----|
|274|NULL|NULL|0.00|0.00|559697.5639|0.00|36277591.9034|4251368.5497|0.1316|
|275|2|300000.00|4100.00|0.012|3763178.1787|1750406.4785|36277591.9034|4251368.5497|0.8851|
|276|4|250000.00|2000.00|0.015|4251368.5497|1439156.0291|36277591.9034|4251368.5497|1.00|
|277|3|250000.00|2500.00|0.015|3189418.3662|1997186.2037|36277591.9034|4251368.5497|0.7502|
 
##### YTD Sales With OVER
### Window Function using OVER() and PARTITION BY

```sql
SELECT
	ProductID,
	SalesOrderID,
	SalesOrderDetailID,
	OrderQty,
	UnitPrice,
	UnitPriceDiscount,
	LineTotal,
	ProductIDLineTotal = SUM(LineTotal) OVER(PARTITION BY ProductID, OrderQty)

FROM AdventureWorks2019.Sales.SalesOrderDetail
ORDER BY ProductID, OrderQty DESC;
```
### Window Function With ROW_NUMBER
##### Ranking all records within each group of sales order IDs
```sql
SELECT
	SalesOrderID,
	SalesOrderDetailID,
	LineTotal,
	ProductIDLineTotal = SUM(LineTotal) OVER(PARTITION BY SalesOrderID),
	Ranking = ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC)

FROM AdventureWorks2019.Sales.SalesOrderDetail
ORDER BY
SalesOrderID;
```

##### Ranking ALL records by line total - no groups
Note - ROW_NUMBER() always returns a sequential number. In this case the Ranking number will increase even when LineTotal number is the same.
```sql
SELECT
    SalesOrderID,
    SalesOrderDetailID,
    LineTotal,
    ProductIDLineTotal = SUM(LineTotal) OVER(PARTITION BY SalesOrderID),
    Ranking = ROW_NUMBER() OVER(ORDER BY LineTotal DESC)
    
FROM AdventureWorks2019.Sales.SalesOrderDetail
ORDER BY 5
```
##### ROW_NUMBER, RANK, AND DENSE_RANK, compared
```sql
SELECT
    SalesOrderID,
    SalesOrderDetailID,
    LineTotal,
    Ranking = ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC),
    RankingWithRank = RANK() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC),
    RankingWithDenseRank = DENSE_RANK() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC)
 
FROM AdventureWorks2019.Sales.SalesOrderDetail
ORDER BY SalesOrderID, LineTotal DESC;

 
```
| SalesOrderID | SalesOrderDetailID | LineTotal | Ranking | RankingWithRank | RankingWithDenseRank |
| ------------ | ------------------ | --------- | ------- | --------------- | -------------------- |
|    43659	|2|6074.982000|1|1|	1|
|43659|6|4079.988000|2|2|2|
|43659|7|2039.994000|3|3|3|
|43659|4|2039.994000|4|3|3|
|43659|5|2039.994000|5|3|3|
|43659|3|2024.994000|6|6|4|
|43659|1|2024.994000|7|6|4|
|43659|8|86.521200|8|8|5|
|43659|12|80.746000|9|9|6|
|43659|10|34.200000|10|10|7|
|43659|9|28.840400|11|11|8|

#### LEAD and LAG
##### Basic LEAD/LAG example
```sql
SELECT
       SalesOrderID
      ,OrderDate
      ,CustomerID
      ,TotalDue
      ,NextTotalDue = LEAD(TotalDue, 3) OVER(ORDER BY SalesOrderID)
      ,PrevTotalDue = LAG(TotalDue, 3) OVER(ORDER BY SalesOrderID)
 
FROM AdventureWorks2019.Sales.SalesOrderHeader 
ORDER BY SalesOrderID
```
##### Looking forward (or backward) more than one record
```sql
SELECT
       SalesOrderID
      ,OrderDate
      ,CustomerID
      ,TotalDue
      ,NextTotalDue = LEAD(TotalDue, 3) OVER(ORDER BY SalesOrderID)
      ,PrevTotalDue = LAG(TotalDue, 3) OVER(ORDER BY SalesOrderID)

FROM AdventureWorks2019.Sales.SalesOrderHeader
ORDER BY SalesOrderID
```
##### Using PARTITION with LEAD and LAG
```sql
SELECT
       SalesOrderID
      ,OrderDate
      ,CustomerID
      ,TotalDue
      ,NextTotalDue = LEAD(TotalDue, 1) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)
      ,PrevTotalDue = LAG(TotalDue, 1) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)

FROM AdventureWorks2019.Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID
```
#### Subqueries
##### Selecting the most expensive item per order in a single query
```sql
SELECT
*
FROM
(
	SELECT
	SalesOrderID,
	SalesOrderDetailID,
	LineTotal,
	LineTotalRanking = ROW_NUMBER() OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC)
	FROM AdventureWorks2019.Sales.SalesOrderDetail
) A
WHERE LineTotalRanking = 1
```
#### Using ROW_NUM() to filter out duplicates
```sql
SELECT 
	x.Id, x.Rn,x.Topic,x.Partition, 
	x.Offset,x.Timestamp, 
		x.[Key], x.FQDN, x.RAM, x.CPUCount, x.HardwareModel, x.SystemUUID, 
		x.OS, x.OSArchitecture, x.ProcessArchitecture, x.UTCRunTime, 
		x.LoadDate 
FROM (
	SELECT [Id]
		, Rn = ROW_NUMBER() OVER(PARTITION BY FQDN ORDER BY LoadDate DESC)
 
      ,[Topic]
      ,[Partition]
      ,[Offset]
      ,[Timestamp]
      ,[Key]
      ,[FQDN]
      ,[RAM]
      ,[CPUCount]
      ,[HardwareModel]
      ,[SystemUUID]
      ,[OS]
      ,[OSArchitecture]
      ,[ProcessArchitecture]
      ,[UTCRunTime]
      ,[LoadDate]
  FROM [PROTO].[ETL].[KafkaEventsRaw_vw] (NOLOCK)
  ) x
  where x.Rn=1

```