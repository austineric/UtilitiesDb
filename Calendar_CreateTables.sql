
/*
DROP TABLE dbo.CalendarDay
DROP TABLE dbo.CalendarMonth
DROP TABLE dbo.CalendarQuarter
DROP TABLE dbo.CalendarYear
DROP TABLE dbo.CalendarMonthReference
DROP TABLE dbo.CalendarQuarterReference
*/


CREATE TABLE CalendarYear
    (
    Year SMALLINT NOT NULL
    ,FirstDay DATETIME NOT NULL
    ,LastDay DATETIME NOT NULL
    )
ALTER TABLE dbo.CalendarYear ADD CONSTRAINT PK_CalendarYear_Year PRIMARY KEY CLUSTERED (Year)

CREATE TABLE CalendarQuarterReference
    (
    Quarter TINYINT NOT NULL
    ,QuarterName CHAR(9) NOT NULL
    ,QuarterNameShort CHAR(2) NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,FirstDay CHAR(4) NOT NULL
    ,LastDay CHAR(4) NOT NULL
    )
ALTER TABLE dbo.CalendarQuarterReference ADD CONSTRAINT PK_CalendarQuarterReference_Quarter PRIMARY KEY CLUSTERED (Quarter)

CREATE TABLE CalendarQuarter
    (
    Quarter TINYINT NOT NULL
    ,Year SMALLINT NOT NULL
    ,QuarterName CHAR(9) NOT NULL
    ,QuarterNameShort CHAR(2) NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,FirstDay DATETIME NOT NULL
    ,LastDay DATETIME NOT NULL
    )
ALTER TABLE dbo.CalendarQuarter ADD CONSTRAINT PK_CalendarQuarter_Multi PRIMARY KEY CLUSTERED (Quarter,Year)
ALTER TABLE dbo.CalendarQuarter ADD CONSTRAINT FK_CalendarQuarter_Year FOREIGN KEY (Year) REFERENCES dbo.CalendarYear(Year) ON DELETE CASCADE
ALTER TABLE dbo.CalendarQuarter ADD CONSTRAINT FK_CalendarQuarter_Quarter FOREIGN KEY (Quarter) REFERENCES dbo.CalendarQuarterReference (Quarter)

CREATE TABLE CalendarMonthReference
    (
    Month VARCHAR(9) NOT NULL
    ,MonthNumber TINYINT NOT NULL
    ,Quarter TINYINT NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,FirstDay CHAR(4) NOT NULL
    )
ALTER TABLE dbo.CalendarMonthReference ADD CONSTRAINT PK_CalendarMonthReference_Month PRIMARY KEY CLUSTERED (Month)

CREATE TABLE CalendarMonth
    (
    Month VARCHAR(9) NOT NULL
    ,Year SMALLINT NOT NULL
    ,MonthNumber TINYINT NOT NULL
    ,Quarter TINYINT NOT NULL
    ,YearHalf TINYINT NOT NULL
    ,FirstDay DATETIME NOT NULL
    ,LastDay DATETIME NOT NULL
    )
ALTER TABLE dbo.CalendarMonth ADD CONSTRAINT PK_CalendarMonth_Multi PRIMARY KEY CLUSTERED (Month, Year)
ALTER TABLE dbo.CalendarMonth ADD CONSTRAINT FK_CalendarMonth_Multi FOREIGN KEY (Quarter, Year) REFERENCES dbo.CalendarQuarter(Quarter, Year) ON DELETE CASCADE
ALTER TABLE dbo.CalendarMonth ADD CONSTRAINT FK_CalendarMonth_Month FOREIGN KEY (Month) REFERENCES dbo.CalendarMonthReference (Month)

CREATE TABLE CalendarDay
    (
    Day TINYINT NOT NULL
    ,DayName VARCHAR(9) NOT NULL
    ,Month VARCHAR(9) NOT NULL
    ,MonthNumber TINYINT NOT NULL
    ,Year SMALLINT NOT NULL
    ,DayNumberOfWeek TINYINT NOT NULL
    ,DayNumberOfYear SMALLINT NOT NULL
    )
ALTER TABLE dbo.CalendarDay ADD CONSTRAINT PK_CalendarDay_Multi PRIMARY KEY CLUSTERED (Day, Month, Year)
ALTER TABLE dbo.CalendarDay ADD CONSTRAINT FK_CalendarDay_Multi FOREIGN KEY (Month, Year) REFERENCES dbo.CalendarMonth(Month,Year) ON DELETE CASCADE



