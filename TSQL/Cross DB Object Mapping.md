## Core code

```sql
DROP TABLE cross_db_databases;
CREATE TABLE cross_db_databases(
    database_id int, 
    database_name sysname,
	state int,
	IsActive nvarchar(3)
);
 INSERT INTO cross_db_databases([database_id], [database_name],[state],[IsActive])
SELECT [database_id], [name],[state],'YES'
FROM sys.databases
WHERE 1 = 1
    AND [state] <> 6 /* ignore offline DBs */
    AND database_id > 4; /* ignore system DBs */
 
-- prune cross_db_databases to remove any db that you don't want scanned
DROP TABLE cross_db_reference;
CREATE TABLE cross_db_reference (
	referencing_servername varchar(max),
	referencing_servicename varchar(max),
    referencing_database varchar(max),
	referencing_id int,
    referencing_schema varchar(max),
    referencing_object_name varchar(max),
	referencing_object_type varchar(max),
	referencing_object_desc varchar(max),
    referenced_server varchar(max),
    referenced_database varchar(max),
	referenced_id int,
    referenced_schema varchar(max),
    referenced_object_name varchar(max),
	referenced_object_type varchar(max),
	referenced_object_desc varchar(max),
	ambiguous_entity_name varchar(max),
	ambiguous_schema_name varchar(max),
	ambiguous_database_name varchar(max),
	is_ambiguous int,
	LoadDate datetime
);
drop   TABLE cross_db_objects
	 CREATE TABLE cross_db_objects(
	 	[object_servername] varchar(max),
	[object_servicename] varchar(max),
    [object_database] varchar(max),
	[object_id] int,
    [object_schema] varchar(max),
    [object_name] varchar(max),
	[object_type] varchar(max),
	[object_desc] varchar(max),
	LoadDate datetime
);
go
DROP view cross_db_view
 
create view cross_db_view
as
select     c.referencing_servername,c.referencing_servicename,c.referencing_database,
	c.referencing_id ,
    c.referencing_schema ,
    c.referencing_object_name ,
	c.referencing_object_type ,
	c.referencing_object_desc ,
    c.referenced_server ,
    c.referenced_database ,
	'referenced_object_id' = 
	CASE 
		WHEN o.[object_id]  is   null and c.referenced_id  is  null  and o_cross.[object_id]  is not null THEN o_cross.[object_id]  
		WHEN c.referenced_id  is  not null and o.object_id is  null THEN c.referenced_id
		WHEN  c.referenced_id  is   null and o.object_id is not null THEN  o.object_id 
		ELSE c.referenced_id   
	END,

	'referenced_schema' = 
		CASE 
		WHEN c.referenced_schema  is   null and o.[object_schema]  is  null and o_cross.[object_schema]  is not null THEN o_cross.[object_schema]  
		WHEN  c.referenced_schema  is   null and o.[object_schema] is not null THEN  o.[object_schema] 
		WHEN c.referenced_schema  is  not null  THEN c.referenced_schema
		ELSE NULL   
	END,

		'referenced_object_name' =  
	CASE 
		WHEN c.referenced_object_name  is   null and o.[object_name]  is  null and o_cross.[object_name]  is not null THEN o_cross.[object_name]  
		WHEN  c.referenced_object_name  is   null and o.[object_name] is not null THEN  o.[object_name] 
		WHEN c.referenced_object_name  is  not null  THEN c.referenced_object_name
		ELSE NULL   
	END,
	'referenced_object_type' = 
	CASE 
		WHEN c.referenced_object_type  is   null and o.[object_type]  is  null and o_cross.[object_type]  is not null THEN o_cross.[object_type]  
		WHEN  c.referenced_object_type  is   null and o.[object_type] is not null THEN  o.[object_type] 
		WHEN c.referenced_object_type  is  not null  THEN c.referenced_object_type
		ELSE NULL   
	END,
	'referenced_object_desc' =  
	CASE 
		WHEN c.referenced_object_desc  is   null and o.[object_desc]  is  null and o_cross.[object_desc]  is not null THEN o_cross.[object_desc]  
		WHEN  c.referenced_object_desc  is   null and o.[object_desc] is not null THEN  o.[object_desc] 
		WHEN c.referenced_object_desc  is  not null  THEN c.referenced_object_desc
		ELSE NULL   
	END,
	c.ambiguous_database_name,
	c.ambiguous_schema_name,
	c.ambiguous_entity_name,
	c.is_ambiguous,
	c.LoadDate  FROM cross_db_reference c   
left join cross_db_objects o on o.object_database=c.referenced_database and o.object_id=c.referenced_id  
left join cross_db_objects o_cross on o_cross.object_database=c.referenced_database and c.referenced_id  is null and    c.referenced_schema  = o_cross.object_schema and o_cross.object_name = c.referenced_object_name
;


SELECT * FROM  cross_db_view   where referencing_object_name='CVIEW_HumanResources_Department'
select * from cross_db_objects where object_id=1381579960
```