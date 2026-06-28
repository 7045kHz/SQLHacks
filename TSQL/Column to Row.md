### Column to Row Example 1
```sql
DECLARE @LOCAL_TABLEVARIABLE TABLE
(CI_NAME VARCHAR(256), 
 [name] VARCHAR(256), 
 [current_value] VARCHAR(max)
)

insert into @LOCAL_TABLEVARIABLE ([CI_NAME],[name],[current_value]) select [CI_NAME], [name] ,[current_value] from OSQUERY.system_controls ;


Select CI_NAME,
     Min(Case name When 'vm.hugetlb_shm_group' Then current_value End) 'vm.hugetlb_shm_group',
     Min(Case name When 'vm.nr_hugepages' Then current_value End) 'vm.nr_hugepages',
     Min(Case name When 'vm.nr_hugepages_mempolicy' Then current_value End) 'vm.nr_hugepages_mempolicy' ,
     Min(Case name When 'vm.nr_overcommit_hugepages' Then current_value End) 'vm.nr_overcommit_hugepages' ,
	 Min(Case name When 'fs.file-max' Then current_value End) 'fs.file-max' ,
	 Min(Case name When 'fs.file-nr' Then current_value End) 'fs.file-nr' ,
	 Min(Case name When 'kernel.watchdog' Then current_value End) 'kernel.watchdog' 
From @LOCAL_TABLEVARIABLE
Group By CI_NAME
```
 


|CI_NAME|vm.hugetlb_shm_group         |vm.nr_hugepages|vm.nr_hugepages_mempolicy                    |vm.nr_overcommit_hugepages|fs.file-max        |fs.file-nr                |kernel.watchdog|
|-------|-----------------------------|---------------|---------------------------------------------|--------------------------|-------------------|--------------------------|---------------|
|developer.rsyslab.com|0                            |0              |0                                            |0                         |375484             |2040	0	375484             |1              |
|kcontrol.rsyslab.com|0                            |0              |0                                            |0                         |9223372036854775807|1696	0	9223372036854775807|1              |
|kworker1.rsyslab.com|0                            |0              |0                                            |0                         |9223372036854775807|2272	0	9223372036854775807|1              |
|kworker2.rsyslab.com|0                            |0              |0                                            |0                         |9223372036854775807|2304	0	9223372036854775807|1              |
|kworker3.rsyslab.com|0                            |0              |0                                            |0                         |9223372036854775807|1376	0	9223372036854775807|1              |
