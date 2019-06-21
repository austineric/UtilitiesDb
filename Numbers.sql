

--adds one million numbers in a second or two
CREATE TABLE Numbers
    (
    Number INT NOT NULL
    CONSTRAINT PK_NumbersTable_Number PRIMARY KEY CLUSTERED (Number)
    )

;WITH cte AS
    (
    SELECT 1 AS 'Number'
    UNION ALL
    SELECT Number+1
    FROM cte
    WHERE Number<1000
    )
INSERT INTO dbo.Numbers (Number)
SELECT ROW_NUMBER() OVER (ORDER BY c1.Number)
FROM cte c1
CROSS JOIN cte c2
OPTION (MAXRECURSION 0)