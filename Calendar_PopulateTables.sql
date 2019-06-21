

/*
DELETE FROM dbo.CalendarYear
DELETE FROM dbo.CalendarMonthReference
DELETE FROM dbo.CalendarQuarterReference
*/

--add in year blocks (12 months at a time), don't add in partial years
--this is being built without functions such as EOM (end of month) which is only available on SQL2012+
--in the same vein it isn't using DATE formats anywhere

--calendaryear
DECLARE @year INT
DECLARE @firstday DATETIME

SET @year=2010
SET @firstday=CAST(CAST(@year AS CHAR(4)) + '0101' AS DATETIME)

WHILE @year<=2030
BEGIN
    INSERT INTO dbo.CalendarYear (Year, FirstDay, LastDay)
    SELECT 
        @year
        ,@firstday
        ,DATEADD(MILLISECOND,-3,DATEADD(YEAR,1,@firstday))
        SET @firstday=DATEADD(YEAR,1,@firstday)
        SET @year=@year+1
END;
GO

SELECT * FROM dbo.CalendarYear ORDER BY Year ASC;

--calendarquarterreference
INSERT INTO dbo.CalendarQuarterReference (Quarter, QuarterName, QuarterNameShort, YearHalf, FirstDay, LastDay)
VALUES
    (1,'Quarter 1','Q1',1,'0101','0331')
    ,(2,'Quarter 2','Q2',1,'0401','0630')
    ,(3,'Quarter 3','Q3',2,'0701','0930')
    ,(4,'Quarter 4','Q4',2,'1001','1231')

SELECT * FROM dbo.CalendarQuarterReference ORDER BY Quarter ASC;

--calendarquarter
INSERT INTO dbo.CalendarQuarter (Quarter, Year, QuarterName, QuarterNameShort, YearHalf, FirstDay, LastDay)
SELECT
    qr.Quarter
    ,y.Year
    ,qr.QuarterName
    ,qr.QuarterNameShort
    ,qr.YearHalf
    ,CAST(CAST(y.Year AS CHAR(4)) + qr.FirstDay AS DATETIME)
    ,CAST(CAST(y.Year AS CHAR(4)) + qr.LastDay AS DATETIME)
FROM dbo.CalendarYear y
CROSS JOIN dbo.CalendarQuarterReference qr
WHERE
    NOT
        EXISTS
            (
            SELECT *
            FROM dbo.CalendarQuarter q
            WHERE y.Year=q.Quarter
            )

SELECT * FROM dbo.CalendarQuarter ORDER BY Year ASC, Quarter ASC;

--calendarmonthreference
INSERT INTO dbo.CalendarMonthReference (Month, MonthNumber, Quarter, YearHalf, FirstDay)
VALUES
    ('January',1,1,1,'0101')
    ,('February',2,1,1,'0201')
    ,('March',3,1,1,'0301')
    ,('April',4,2,1,'0401')
    ,('May',5,2,1,'0501')
    ,('June',6,2,1,'0601')
    ,('July',7,3,2,'0701')
    ,('August',8,3,2,'0801')
    ,('September',9,3,2,'0901')
    ,('October',10,4,2,'1001')
    ,('November',11,4,2,'1101')
    ,('December',12,4,2,'1201')

SELECT * FROM dbo.CalendarMonthReference ORDER BY MonthNumber ASC;

--calendarmonth
INSERT INTO dbo.CalendarMonth (Month, Year, MonthNumber, Quarter, YearHalf, FirstDay, LastDay)
SELECT
    mr.Month
    ,y.Year
    ,mr.MonthNumber
    ,mr.Quarter
    ,mr.YearHalf
    ,CAST(CAST(y.Year AS CHAR(4)) + mr.FirstDay AS DATETIME)
    ,DATEADD(MILLISECOND,-3,DATEADD(MONTH,1,CAST(CAST(y.Year AS CHAR(4)) + mr.FirstDay AS DATETIME)))
FROM dbo.CalendarYear y
CROSS JOIN dbo.CalendarMonthReference mr
WHERE
    NOT
        EXISTS
            (
            SELECT *
            FROM dbo.CalendarMonth m
            WHERE y.Year=m.Year
            )

SELECT * FROM dbo.CalendarMonth ORDER BY Year ASC, MonthNumber ASC;

--calendarday
DECLARE @yearbegin INT
DECLARE @yearend INT
DECLARE @day DATETIME

SET @yearbegin=(SELECT MIN(y.Year) AS 'Year' FROM dbo.CalendarYear y WHERE NOT EXISTS (SELECT * FROM dbo.CalendarDay d WHERE y.Year=d.Year))
SET @yearend=(SELECT MAX(y.Year) AS 'Year' FROM dbo.CalendarYear y WHERE NOT EXISTS (SELECT * FROM dbo.CalendarDay d WHERE y.Year=d.Year))
SET @day=CAST(CAST(@yearbegin AS CHAR(4)) + '0101' AS DATETIME)

WHILE DATEPART(YEAR,@day)<=@yearend
BEGIN
    INSERT INTO dbo.CalendarDay (Day, DayName, Month, MonthNumber, Year, DayNumberOfWeek, DayNumberOfYear)
    SELECT
        DATEPART(DAY,@day)
        ,DATENAME(WEEKDAY,@day)
        ,DATENAME(MONTH,@day)
        ,DATEPART(MONTH,@day)
        ,DATEPART(YEAR,@day)
        ,DATEPART(WEEKDAY,@day)
        ,DATEPART(DAYOFYEAR,@day)
    
    SET @day=DATEADD(DAY,1,@day)
END

SELECT * FROM dbo.CalendarDay ORDER BY Year ASC, MonthNumber ASC, Day ASC;
