### Convert NTEXT to INT
First convert to NVARCHAR, then to INT. In this example CONTRACT_ID is originally an NTEXT field.

```sql

CONVERT(INT, CONVERT(NVARCHAR(100), CONTRACT_ID))

```