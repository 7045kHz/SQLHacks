### Example 1 - Function to get columns from table
```sql
/* 
EXAMPLE: SELECT dbo.GetAPIColumns(N'osquery.acpi_tables') ;
NOTE: more data types should be added to this. Example Only
*/
CREATE FUNCTION [dbo].[GetColumns] (@TNAME NVARCHAR(max))
RETURNS NVARCHAR(max)

WITH EXECUTE AS CALLER
AS
BEGIN
 DECLARE @JSON_CTRL_STR NVARCHAR(max);
 DECLARE @OID INT;

 SET QUOTED_IDENTIFIER OFF;
 SET @OID = (SELECT OBJECT_ID(@TNAME));
 SET QUOTED_IDENTIFIER ON;

 SET QUOTED_IDENTIFIER OFF;
 SET @OID = (SELECT OBJECT_ID(@TNAME));
 SET QUOTED_IDENTIFIER ON;

 SET @JSON_CTRL_STR = (SELECT STUFF (
   (SELECT  
	',[' + c.name + ']'  + CHAR(10) ,

	CASE  
		WHEN t.Name = 'bigint' THEN  '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + ','
		WHEN t.Name = 'ntext' THEN '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + ')'
		WHEN t.Name = 'nvarchar' THEN '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + ')'
		WHEN t.Name = 'int' THEN '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + ')'
		WHEN t.Name = 'datetime' THEN '[' + t.Name + ']' 
	END
	FROM    
		sys.columns c
		INNER JOIN 
			sys.types t ON c.user_type_id = t.user_type_id
		LEFT OUTER JOIN 
			sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
	WHERE
		c.object_id = @OID   FOR XML PATH('')
	),
	1,1,''));

 RETURN  @JSON_CTRL_STR;
END;
GO 
```
### Example 2 - Function to get columns from a table
Returns a comma separated string with field name,  type and size
```sql
/* 
EXAMPLE: SELECT dbo.GetAPIColumns(N'osquery.acpi_tables') ;
NOTE: more data types should be added to this. Example Only
*/
CREATE FUNCTION [dbo].[GetColumns] (@TNAME NVARCHAR(max))
RETURNS NVARCHAR(max)

WITH EXECUTE AS CALLER
AS
BEGIN
 DECLARE @JSON_CTRL_STR NVARCHAR(max);
 DECLARE @OID INT;

 SET QUOTED_IDENTIFIER OFF;
 SET @OID = (SELECT OBJECT_ID(@TNAME));
 SET QUOTED_IDENTIFIER ON;

 SET @JSON_CTRL_STR =  (   
	 SELECT  
		'[' + c.name + ']'  + CHAR(10) ,

		CASE  
			WHEN t.Name = 'bigint' THEN  '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + '),'
			WHEN t.Name = 'ntext' THEN '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + '),'
			WHEN t.Name = 'nvarchar' THEN '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + '),'
			WHEN t.Name = 'int' THEN '[' + t.Name + '](' + CAST(c.max_length AS NVARCHAR ) + '),'
			WHEN t.Name = 'datetime' THEN '[' + t.Name + '],' 
		END
		FROM    
			sys.columns c
			INNER JOIN 
				sys.types t ON c.user_type_id = t.user_type_id
			LEFT OUTER JOIN 
				sys.index_columns ic ON ic.object_id = c.object_id AND ic.column_id = c.column_id
		WHERE
			c.object_id = @OID   FOR XML PATH(''))   ;

 SET @JSON_CTRL_STR = (SELECT LEFT(@JSON_CTRL_STR, LEN(@JSON_CTRL_STR) -1));
 RETURN  @JSON_CTRL_STR;
END;
GO
```
### Example
```sql
SELECT dbo.GetColumns(N'osquery.acpi_tables') ;
[name] [ntext](16),[size] [int](4),[md5] [ntext](16),[CI_NAME] [nvarchar](512),[CI_ID] [nvarchar](512),[IDX] [int](4),[LAST_UPDATE] [datetime]
```