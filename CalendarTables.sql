

--create tables

/*
DROP TABLE IF EXISTS dbo.CalendarDay
DROP TABLE IF EXISTS dbo.CalendarMonth
DROP TABLE IF EXISTS dbo.CalendarQuarter
DROP TABLE IF EXISTS dbo.CalendarYear
DROP TABLE IF EXISTS dbo.CalendarMonthReference
DROP TABLE IF EXISTS dbo.CalendarQuarterReference
*/

CREATE TABLE CalendarYear
    (
    Year SMALLINT NOT NULL
    ,YearBegin DATETIME2 NOT NULL
    ,YearEnd DATETIME2 NOT NULL
    ,CONSTRAINT PK_CalendarYear_Year PRIMARY KEY CLUSTERED (Year)
    )

CREATE TABLE CalendarQuarterReference
    (
    Quarter TINYINT NOT NULL
    ,QuarterName CHAR(9) NOT NULL
    ,QuarterNameShort CHAR(2) NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,FirstDay CHAR(4) NOT NULL
    ,LastDay CHAR(4) NOT NULL
    ,CONSTRAINT PK_CalendarQuarterReference_Quarter PRIMARY KEY CLUSTERED (Quarter)
    )

CREATE TABLE CalendarQuarter
    (
    Quarter TINYINT NOT NULL
    ,Year SMALLINT NOT NULL
    ,QuarterName CHAR(9) NOT NULL
    ,QuarterNameShort CHAR(2) NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,QuarterBegin DATETIME2 NOT NULL
    ,QuarterEnd DATETIME2 NOT NULL
    ,CONSTRAINT PK_CalendarQuarter_Multi PRIMARY KEY CLUSTERED (Quarter,Year)
    ,CONSTRAINT FK_CalendarQuarter_Year FOREIGN KEY (Year) REFERENCES dbo.CalendarYear(Year) ON DELETE CASCADE
    ,CONSTRAINT FK_CalendarQuarter_Quarter FOREIGN KEY (Quarter) REFERENCES dbo.CalendarQuarterReference (Quarter)
    )

CREATE TABLE CalendarMonthReference
    (
    Month VARCHAR(9) NOT NULL
    ,MonthNumber TINYINT NOT NULL
    ,Quarter TINYINT NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,FirstDay CHAR(4) NOT NULL
    ,CONSTRAINT PK_CalendarMonthReference_Month PRIMARY KEY CLUSTERED (Month)
    )

CREATE TABLE CalendarMonth
    (
    Month VARCHAR(9) NOT NULL
    ,Year SMALLINT NOT NULL
    ,MonthNumber TINYINT NOT NULL
    ,Quarter TINYINT NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,MonthBegin DATETIME2 NOT NULL
    ,MonthEnd DATETIME2 NOT NULL
    ,CONSTRAINT PK_CalendarMonth_Multi PRIMARY KEY CLUSTERED (Month, Year)
    ,CONSTRAINT FK_CalendarMonth_Multi FOREIGN KEY (Quarter, Year) REFERENCES dbo.CalendarQuarter(Quarter, Year) ON DELETE CASCADE
    ,CONSTRAINT FK_CalendarMonth_Month FOREIGN KEY (Month) REFERENCES dbo.CalendarMonthReference (Month)
    )

CREATE TABLE CalendarDay
    (
    Day TINYINT NOT NULL
    ,DayName VARCHAR(9) NOT NULL
    ,Month VARCHAR(9) NOT NULL
    ,MonthNumber TINYINT NOT NULL
    ,Year SMALLINT NOT NULL
    ,DayNumberOfWeek TINYINT NOT NULL
    ,DayNumberOfYear SMALLINT NOT NULL
    ,DayBegin DATETIME2 NOT NULL
    ,DayEnd DATETIME2 NOT NULL
    ,CONSTRAINT PK_CalendarDay_Multi PRIMARY KEY CLUSTERED (Day, Month, Year)
    ,CONSTRAINT FK_CalendarDay_Multi FOREIGN KEY (Month, Year) REFERENCES dbo.CalendarMonth(Month,Year) ON DELETE CASCADE
    );
GO



--populate tables
--full years get added at a time, no partial years

/*
DELETE FROM dbo.CalendarDay
DELETE FROM dbo.CalendarMonth
DELETE FROM dbo.CalendarMonthReference
DELETE FROM dbo.CalendarQuarter
DELETE FROM dbo.CalendarQuarterReference
DELETE FROM dbo.CalendarYear
*/

--calendaryear
DECLARE @Year INT
DECLARE @YearBegin DATETIME2

SET @Year=2010
SET @YearBegin=CAST(CAST(@year AS CHAR(4)) + '0101' AS DATETIME2)

WHILE @Year<=2030
BEGIN
    INSERT INTO dbo.CalendarYear (Year, YearBegin, YearEnd)
    SELECT 
        @Year
        ,@YearBegin
        ,DATEADD(NANOSECOND,-100, DATEADD(YEAR,1,@YearBegin))

        SET @Year=@Year+1
        SET @YearBegin=DATEADD(YEAR,1,@YearBegin)
END;
GO
SELECT * FROM dbo.CalendarYear ORDER BY Year ASC;

--calendarquarterreference
INSERT INTO dbo.CalendarQuarterReference (Quarter, QuarterName, QuarterNameShort, YearHalf, FirstDay, LastDay)
VALUES
    (1,'Quarter 1','Q1',1,'0101','0331')
    ,(2,'Quarter 2','Q2',1,'0401','0630')
    ,(3,'Quarter 3','Q3',2,'0701','0930')
    ,(4,'Quarter 4','Q4',2,'1001','1231');
GO
SELECT * FROM dbo.CalendarQuarterReference ORDER BY Quarter ASC;

--calendarquarter
INSERT INTO dbo.CalendarQuarter (Quarter, Year, QuarterName, QuarterNameShort, YearHalf, QuarterBegin, QuarterEnd)
SELECT
    qr.Quarter
    ,y.Year
    ,qr.QuarterName
    ,qr.QuarterNameShort
    ,qr.YearHalf
    ,CAST(CAST(y.Year AS CHAR(4)) + qr.FirstDay AS DATETIME2)
    ,DATEADD(NANOSECOND,-100,(DATEADD(QUARTER,1,(CAST(CAST(y.Year AS CHAR(4)) + qr.FirstDay AS DATETIME2)))))
FROM dbo.CalendarYear y
CROSS JOIN dbo.CalendarQuarterReference qr
WHERE
    NOT
        EXISTS
            (
            SELECT *
            FROM dbo.CalendarQuarter q
            WHERE y.Year=q.Quarter
            );
GO
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
    ,('December',12,4,2,'1201');
GO
SELECT * FROM dbo.CalendarMonthReference ORDER BY MonthNumber ASC;

--calendarmonth
INSERT INTO dbo.CalendarMonth (Month, Year, MonthNumber, Quarter, YearHalf, MonthBegin, MonthEnd)
SELECT
    mr.Month
    ,y.Year
    ,mr.MonthNumber
    ,mr.Quarter
    ,mr.YearHalf
    ,CAST(CAST(y.Year AS CHAR(4)) + mr.FirstDay AS DATETIME2)
    ,DATEADD(NANOSECOND,-100,DATEADD(MONTH,1,CAST(CAST(y.Year AS CHAR(4)) + mr.FirstDay AS DATETIME2)))
FROM dbo.CalendarYear y
CROSS JOIN dbo.CalendarMonthReference mr
WHERE
    NOT
        EXISTS
            (
            SELECT *
            FROM dbo.CalendarMonth m
            WHERE y.Year=m.Year
            );
GO
SELECT * FROM dbo.CalendarMonth ORDER BY Year ASC, MonthNumber ASC;

--calendarday
DECLARE @StartingYear INT
DECLARE @EndingYear INT
DECLARE @Day DATETIME2

SET @StartingYear=(SELECT MIN(y.Year) AS 'Year' FROM dbo.CalendarYear y WHERE NOT EXISTS (SELECT * FROM dbo.CalendarDay d WHERE y.Year=d.Year))
SET @EndingYear=(SELECT MAX(y.Year) AS 'Year' FROM dbo.CalendarYear y WHERE NOT EXISTS (SELECT * FROM dbo.CalendarDay d WHERE y.Year=d.Year))
SET @Day=CAST(CAST(@StartingYear AS CHAR(4)) + '0101' AS DATETIME2)

WHILE DATEPART(YEAR,@Day)<=@EndingYear
BEGIN
    INSERT INTO dbo.CalendarDay (Day, DayName, Month, MonthNumber, Year, DayNumberOfWeek, DayNumberOfYear, DayBegin, DayEnd)
    SELECT
        DATEPART(DAY,@Day)
        ,DATENAME(WEEKDAY,@Day)
        ,DATENAME(MONTH,@Day)
        ,DATEPART(MONTH,@Day)
        ,DATEPART(YEAR,@Day)
        ,DATEPART(WEEKDAY,@Day)
        ,DATEPART(DAYOFYEAR,@Day)
        ,@Day
        ,DATEADD(NANOSECOND,-100,(DATEADD(DAY,1,@Day)))
    
    SET @Day=DATEADD(DAY,1,@Day)
END;
GO
SELECT * FROM dbo.CalendarDay ORDER BY Year ASC, MonthNumber ASC, Day ASC;
