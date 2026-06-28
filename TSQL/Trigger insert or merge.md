```sql
CREATE TRIGGER trg_InsertOrMerge
ON TargetTable
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Merge operation to handle insert or update
    MERGE INTO TargetTable AS Target
    USING (SELECT Id, Name, Value FROM Inserted) AS Source
    ON Target.Id = Source.Id
    WHEN MATCHED THEN
        UPDATE SET 
            Target.Name = Source.Name,
            Target.Value = Source.Value
    WHEN NOT MATCHED THEN
        INSERT (Id, Name, Value)
        VALUES (Source.Id, Source.Name, Source.Value);
END;
GO
```