You can put `set xact_abort on` before your transaction to make sure SQL rolls back automatically in case of error.

### TRY CATCH Example with Rollback

```sql
BEGIN TRY
    BEGIN TRANSACTION

        INSERT INTO myTable (myColumns ...) VALUES (myValues ...);
        INSERT INTO myTable (myColumns ...) VALUES (myValues ...);
        INSERT INTO myTable (myColumns ...) VALUES (myValues ...);

    COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN --RollBack in case of Error

    -- <EDIT>: From SQL2008 on, you must raise error messages as follows:
    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  

    SELECT   
       @ErrorMessage = ERROR_MESSAGE(),  
       @ErrorSeverity = ERROR_SEVERITY(),  
       @ErrorState = ERROR_STATE();  

    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
    -- </EDIT>
END CATCH
```

### About @@TRANCOUNT
The BEGIN TRANSACTION statement increments @@TRANCOUNT by 1. ROLLBACK TRANSACTION decrements @@TRANCOUNT to 0, except for ROLLBACK TRANSACTION _savepoint_name_, which does not affect @@TRANCOUNT. COMMIT TRANSACTION or COMMIT WORK decrement @@TRANCOUNT by 1.
#### Example
```sql
PRINT @@TRANCOUNT  
--  The BEGIN TRAN statement will increment the  
--  transaction count by 1.  
BEGIN TRAN  
    PRINT @@TRANCOUNT  
    BEGIN TRAN  
        PRINT @@TRANCOUNT  
--  The COMMIT statement will decrement the transaction count by 1.  
    COMMIT  
    PRINT @@TRANCOUNT  
COMMIT  
PRINT @@TRANCOUNT  
--Results  
--0  
--1  
--2  
--1  
--0
```