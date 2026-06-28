### JSON to Table

Reference: https://www.codeproject.com/Articles/1087995/Inserting-JSON-Text-into-SQL-Server-Table

#### Table for examples
```sql
create table [dbo].[Juser]  (
	[Id] [int] IDENTITY(1,1) NOT NULL,
	FirstName nvarchar(50), 
	LastName nvarchar(50),
	Age int, 
	DateOfBirth datetime2
);
```

#### Json to rows
```sql

declare  @json nvarchar(max) = '[
{ "id" : 2,"firstName": "John", "lastName": "Smith","age": 25, "dateOfBirth": "2007-03-25T12:00:00" },
{ "id" : 5,"firstName": "John", "lastName": "Smith","age": 35, "dateOfBirth": "2005-11-04T12:00:00" },
{ "id" : 7,"firstName": "John", "lastName": "Smith","age": 15, "dateOfBirth": "1983-10-28T12:00:00" },
{ "id" : 8,"firstName": "John", "lastName": "Smith","age": 12, "dateOfBirth": "1995-07-05T12:00:00" },
{ "id" : 9,"firstName": "John", "lastName": "Smith","age": 37, "dateOfBirth": "2015-03-25T12:00:00" }
]';

SELECT *

FROM OPENJSON(@json)

     WITH (id int, firstName nvarchar(50), lastName nvarchar(50),
           age int, dateOfBirth datetime2);


```

#### Insert Json into table

Note - depending on Id settings you may need to exclude that field
```sql
INSERT INTO Juser (Id, FirstName, LastName, Age, DateOfBirth)
 SELECT Id, firstNAme, lastName, age, dateOfBirth 
 FROM OPENJSON(@json)
 WITH (id int,
       firstName nvarchar(50), lastName nvarchar(50), 
       age int, dateOfBirth datetime2)
```

#### With Stored Procedure

```sql
DROP PROCEDURE IF EXISTS dbo.PersonInsertJson
GO
CREATE PROCEDURE dbo.PersonInsertJson(@json NVARCHAR(MAX))
AS BEGIN
  INSERT INTO Juser (Id, FirstName, LastName, Age, DateOfBirth)
  SELECT id, firstNAme, lastName, age, dateOfBirth
  FROM OPENJSON(@json)
       WITH (id int, firstName nvarchar(50), lastName nvarchar(50), _
             age int, dateOfBirth datetime2)
END
```