## Stored Proc
Depends on [[Cross DB Object Mapping]]

```sql
CREATE PROCEDURE [dbo].[get_crossdatabase_dependencies] AS

SET NOCOUNT ON;

CREATE TABLE #databases(
    database_id int, 
    database_name sysname
);

INSERT INTO #databases(database_id, database_name)
SELECT database_id, [database_name]
FROM cross_db_databases
WHERE 1 = 1
    AND [state] <> 6 /* ignore offline DBs */
    AND database_id > 4
	AND IsActive='YES'; /* ignore system DBs */

DECLARE 
	@Date varchar(500),
    @database_id int, 
    @database_name sysname, 
    @sql varchar(max);

CREATE TABLE #dependencies(
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

CREATE TABLE #objects(
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

 
SET @Date=convert(varchar(500),GETDATE()); 

WHILE (SELECT COUNT(*) FROM #databases) > 0 BEGIN
    SELECT TOP 1 @database_id = database_id, 
                 @database_name = database_name 
    FROM #databases;

	SELECT * FROM #databases;
    SET @sql = 'INSERT INTO #dependencies  (  referencing_servername,referencing_servicename,  referencing_database ,	referencing_id ,    referencing_schema ,    referencing_object_name ,	referencing_object_type ,
	referencing_object_desc ,    referenced_server ,    referenced_database ,	referenced_id ,    referenced_schema ,    referenced_object_name ,
		ambiguous_entity_name  ,	ambiguous_schema_name  ,	ambiguous_database_name , referenced_object_type ,	referenced_object_desc ,	is_ambiguous, LoadDate 
	) select 
	@@SERVERNAME, @@SERVICENAME,
        DB_NAME(' + convert(varchar,@database_id) + '), 
		e.referencing_id,
        OBJECT_SCHEMA_NAME(e.referencing_id,' 
            + convert(varchar,@database_id) +'), 
        OBJECT_NAME(e.referencing_id,' + convert(varchar,@database_id) + '), 
		referencing_object.type as referencing_object_type,
		referencing_object.type_desc as referencing_object_type_desc,
        e.referenced_server_name,
	    ''referenced_database_name'' =CASE WHEN (e.referenced_database_name is not null and e.referenced_database_name  in (select database_name from cross_db_databases))
		  THEN e.referenced_database_name
		  ELSE DB_NAME(' + convert(varchar,@database_id) + ') 
        END,
 		e.referenced_id,
	    ''referenced_schema'' =CASE WHEN e.referenced_schema_name is not null and e.referenced_schema_name  in (	SELECT name FROM ' + quotename(@database_name) + '.sys.schemas )
		  THEN e.referenced_schema_name
		  ELSE NULL
        END,
		''referenced_object_name'' =CASE WHEN e.referenced_entity_name is not null and e.referenced_schema_name    in (	SELECT name FROM ' + quotename(@database_name) + '.sys.schemas )
		  THEN e.referenced_entity_name
		  ELSE NULL
        END,
	''ambiguous_entity_name'' =CASE WHEN e.referenced_entity_name is not null and e.referenced_schema_name not   in (	SELECT name FROM ' + quotename(@database_name) + '.sys.schemas )
		  THEN e.referenced_entity_name
		  ELSE NULL
        END,

	''ambiguous_schema_name'' =CASE WHEN e.referenced_schema_name is not null and e.referenced_schema_name  not in (	SELECT name FROM ' + quotename(@database_name) + '.sys.schemas )
		  THEN e.referenced_schema_name
		  ELSE NULL
        END,

	''ambiguous_database_name'' =CASE WHEN e.referenced_database_name is not null and e.referenced_database_name not in (select database_name from cross_db_databases)
		  THEN e.referenced_database_name
		  ELSE NULL
        END,
		referenced_object.type as referencing_object_type,
		referenced_object.type_desc as referencing_object_type_desc,
		e.is_ambiguous,
		'''+@Date+''' as LoadDate
    FROM ' + quotename(@database_name) + '.sys.sql_expression_dependencies e
	left join '+quotename(@database_name) + '.sys.objects referencing_object on referencing_object.object_id = e.referencing_id
	left join '+quotename(@database_name) + '.sys.objects referenced_object on referenced_object.object_id = e.referenced_id

	';
	-- SELECT @sql;

     EXEC(@sql);
 
	 SET @sql = N' INSERT INTO #objects (    [object_servername],[object_servicename], [object_database],	[object_id] ,    [object_schema] ,    [object_name] ,	[object_type] ,	[object_desc] ,	LoadDate ) SELECT 
	 @@SERVERNAME, @@SERVICENAME,
	 DB_NAME(' + convert(varchar,@database_id) + ') as [object_database], 
 obj.object_id as [object_id],
 schema_name(obj.schema_id) as [object_schema],
 obj.name as [object_name],
		obj.type as [object_type],
		obj.type_desc as [object_desc],
	   '''+@Date+''' as LoadDate
from   '+ quotename(@database_name) +'.sys.objects obj';

		  EXEC(@sql);
    DELETE FROM #databases WHERE database_id = @database_id;
END;

SET NOCOUNT OFF;

  insert into cross_db_reference  SELECT *  FROM #dependencies;
  insert into cross_db_objects  SELECT *  FROM #objects;


```