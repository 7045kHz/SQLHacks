## String Aggregation

```sql
SELECT
	Category = A.Name,
	SubCategory = STRING_AGG(B.Name, ', ')

FROM AdventureWorks2019.Production.ProductCategory A
	INNER JOIN AdventureWorks2019.Production.ProductSubcategory B
		ON A.ProductCategoryID = B.ProductCategoryID

GROUP BY
	A.Name
```