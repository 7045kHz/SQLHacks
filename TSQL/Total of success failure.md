
### SQL get total of success failure group by item
```sql

Select Name
    , count(case when status like 'successful' then 1 end) as success
    , count(case when status like 'failed' then 1 end) as failure
From [PROTO].[dbo].[ansible_workflow_job]

Group by Name

```
### Results

|Name|	success|failure|
|----------------------------------|------------------|--------|
|Windows_Patching_Workflow|541|451
|Unix_Patching_Workflow|123|871
