
## First and Last days example

```sql
SELECT 
      [Current Date] = GETDATE(),
	  [First Of Month] = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1),
	  [Last Day of Month]= EOMONTH(GETDATE()) ,
	  [Last Day Previous Month] = DATEADD(DAY, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)),
	  [First Day Previous Month] = DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
```

### Dates in WHERE clause

```sql
SELECT 
       [Order Year] = YEAR([OrderDate])
      ,[SalesOrderID]
      ,[RevisionNumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
      ,[Status]
      ,[OnlineOrderFlag]
      ,[SalesOrderNumber]
      ,[PurchaseOrderNumber]
      ,[AccountNumber]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[TerritoryID]
      ,[BillToAddressID]
      ,[ShipToAddressID]
      ,[ShipMethodID]
      ,[CreditCardID]
      ,[CreditCardApprovalCode]
      ,[CurrencyRateID]
      ,[SubTotal]
      ,[TaxAmt]
      ,[Freight]
      ,[TotalDue]
      ,[Comment]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]

  WHERE [OrderDate] < DATEFROMPARTS(2014, 1,1)
  --WHERE [OrderDate] >= DATEFROMPARTS(2014, 1,1)
  --WHERE [OrderDate] BETWEEN DATEFROMPARTS(2013, 1,1) AND DATEFROMPARTS(2013, 12, 31)
  --WHERE YEAR([OrderDate]) = 2013
```

## Elapsed time

```sql
SELECT 
       [Order Year] = YEAR([OrderDate])
      ,[SalesOrderID]
      ,[RevisionNumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
	  ,[Elapsed Days] = DATEDIFF(DAY,[OrderDate],[ShipDate])
      ,[ModifiedDate]
  FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
```