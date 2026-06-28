#### Where Exists
##### Example
```sql
SELECT
       A.PurchaseOrderID
      ,A.OrderDate
      ,A.SubTotal
      ,A.TaxAmt

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

WHERE EXISTS (
    SELECT
    1
    FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail B
    WHERE A.PurchaseOrderID = B.PurchaseOrderID
        AND B.OrderQty > 500
)

ORDER BY 1
```