-   **Table variables** (`DECLARE @t TABLE`) are visible only to the connection that creates it, and are deleted when the batch or stored procedure ends.
    
-   **Local temporary tables** (`CREATE TABLE #t`) are visible only to the connection that creates it, and are deleted when the connection is closed.
    
-   **Global temporary tables** (`CREATE TABLE ##t`) are visible to everyone, and are deleted when all connections that have referenced them have closed.
    
-   **Tempdb permanent tables** (`USE tempdb CREATE TABLE t`) are visible to everyone, and are deleted when the server is restarted.

**Table Variable :**  
```sql
 DECLARE @tmp TABLE
```


  
Table variables are only visible to the the connection that creates it, are stored in RAM,  
and are deleted after the batch or stored procedure ends.  
  
**Local temporary tables :**  
```sql
 CREATE TABLE #tmp
```
          

  
Local temporary tables are only visible to the connection that creates it,  
and are deleted after the connection is closed.  
  
**Global temporary tables :**  

```sql
 CREATE TABLE ##tmp
```
          

  
Global temporary tables are visible to everyone, and are deleted after the connection that created it is closed.  
  
**Tempdb permanent tables :**  

```sql
 USE tempdb CREATE TABLE tmp
```
         
  
Tempdb permanent tables are visible to everyone, and are deleted when the server is restarted.  
  
**Local** Table can not be shared between multiple users.  
**Global** Table can be shared between multiple users.