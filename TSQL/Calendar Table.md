### Create Calendar Table
```sql
 CREATE TABLE  dbo.Calendar
(
	DateValue DATE,
	WeekOfYear INT,
	DayOfWeekNumber INT,
	DayOfWeekName VARCHAR(32),
	DayOfMonthNumber INT,
	MonthNumber INT,
	YearNumber INT,
	WeekendFlag TINYINT,
	Category TINYINT
);

WITH Dates AS
(
	SELECT
		CAST('01-01-2022' AS DATE) AS MyDate
	
	UNION ALL
	
	SELECT
		DATEADD(DAY, 1, MyDate)
		FROM Dates
		WHERE MyDate < CAST('12-31-2030' AS DATE)
)
	
INSERT INTO dbo.Calendar
(
	DateValue
)
SELECT
	MyDate
FROM Dates
	
OPTION (MAXRECURSION 10000) ;

UPDATE dbo.Calendar
SET
DayOfWeekNumber = DATEPART(WEEKDAY,DateValue),
WeekOfYear = DATEPART(ISO_WEEK,DateValue),
DayOfWeekName = FORMAT(DateValue,'dddd'),
DayOfMonthNumber = DAY(DateValue),
MonthNumber = MONTH(DateValue),
YearNumber = YEAR(DateValue) ;

UPDATE dbo.Calendar
SET
WeekendFlag = 
	CASE
		WHEN DayOfWeekNumber IN(1,7) THEN 1
		ELSE 0
	END

UPDATE dbo.Calendar
SET
Category = 
	CASE
		WHEN DayOfWeekNumber IN(1,7) THEN 1
		ELSE 0
	END

SELECT * FROM dbo.Calendar

```
### Business Days
```sql
ElapsedBusinessDays = (

	SELECT
		COUNT(*)
	FROM dbo.Calendar B
	WHERE B.DateValue BETWEEN A.OrderDate AND A.ShipDate
	AND B.WeekendFlag = 0
	AND B.HolidayFlag = 0

) - 1
```