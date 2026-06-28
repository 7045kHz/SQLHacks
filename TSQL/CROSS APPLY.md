## Cross Apply with Tables

Run a generic query that will show up in the `dm_exec_cached_plans` table.

```sql 

select * from sys.objects as O
inner join sys.columns as C
on O.object_id=C.object_id;

```

The following will fail because `[plan_handle]`  changes
```sql

select * from sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) t

```

To dynamically replace the `[plan_handle]` value use `CROSS APPLY` or `OUTER APPLY`

```sql
select * from sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) t
where t.text like 'SELECT%'
```
## Cross Apply with JSON

```sql

DECLARE @myjson VARCHAR(4000)
SET @myjson = '{"name":"Marsha","interests":["Star Trek","Golf","NFS"]}'

SELECT * FROM OPENJSON(@myjson)

```
 