------------------------------------------------------------------------------------
-- SimpleSQL code to create a table that contains columns of numerous data types
-- and then fills them with random data
-- Michael Howard (mikehow@microsoft.com)
-- Azure Data Platform Security Team
-- Sep 22nd, 2023 - v1.0
------------------------------------------------------------------------------------

DROP TABLE IF EXISTS DataTypesExample;
DROP FUNCTION IF EXISTS  fn_GetRandomString
DROP VIEW IF EXISTS v_RandomNumber
GO 

CREATE VIEW v_RandomNumber
AS
    SELECT ABS(CAST(CAST(NEWID() AS VARBINARY) AS INT)) AS RandomNumber;
GO

CREATE FUNCTION dbo.fn_GetRandomString(@length INT)
RETURNS NVARCHAR(MAX)
AS
    BEGIN
        DECLARE @characters NVARCHAR(80) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_-+={}/?';
        DECLARE @result NVARCHAR(MAX) = '';
        DECLARE @i INT = 0;
        DECLARE @randomIndex INT;

        WHILE @i < @length
        BEGIN
            SET @randomIndex = (SELECT TOP 1 RandomNumber FROM v_RandomNumber) % LEN(@characters) + 1;
            SET @result = @result + SUBSTRING(@characters, @randomIndex, 1);
            SET @i = @i + 1;
        END;

        RETURN @result;
    END;
GO

CREATE TABLE DataTypesExample (
    -- Numeric data types
    BigIntColumn BIGINT,
    BitColumn BIT,
    DecimalColumn DECIMAL(18, 6),
    IntColumn INT,
    MoneyColumn MONEY,
    NumericColumn NUMERIC(18, 2),
    SmallIntColumn SMALLINT,
    SmallMoneyColumn SMALLMONEY,
    TinyIntColumn TINYINT,
    FloatColumn FLOAT,
    RealColumn REAL,

    -- Date and Time data types
    DateColumn DATE,
    DateTimeColumn DATETIME,
    DateTime2Column DATETIME2(7),
    DateTimeOffsetColumn DATETIMEOFFSET(7),
    SmallDateTimeColumn SMALLDATETIME,
    TimeColumn TIME(7),
    
    -- Character strings data types
    CharColumn CHAR(10),
    VarcharColumn VARCHAR(128),
    TextColumn TEXT,

    -- Unicode character strings
    NCharColumn NCHAR(10),
    NVarcharColumn NVARCHAR(128),
    NTextColumn NTEXT,
    
    -- Binary data types
    BinaryColumn BINARY(50),
    VarbinaryColumn VARBINARY(50),
    ImageColumn IMAGE,

    -- Other data types
    UniqueIdentifierColumn UNIQUEIDENTIFIER,
    Sql_VariantColumn SQL_VARIANT,
    XmlColumn XML,
    
    -- Spatial data types
    GeometryColumn GEOMETRY,
    GeographyColumn GEOGRAPHY,
    
    -- Hierarchical ID
    HierarchyIdColumn HIERARCHYID,

    PRIMARY KEY (BigIntColumn)
);
GO

DECLARE @NumRows INT = 1000;
DECLARE @counter INT = 0;

SET NOCOUNT ON;

PRINT 'Inserting random rows'

WHILE @counter < @NumRows
BEGIN
    INSERT INTO DataTypesExample (
        BigIntColumn, BitColumn, DecimalColumn, IntColumn, MoneyColumn, NumericColumn, 
        SmallIntColumn, SmallMoneyColumn, TinyIntColumn, FloatColumn, RealColumn, 
        DateColumn, DateTimeColumn, DateTime2Column, DateTimeOffsetColumn, 
        SmallDateTimeColumn, TimeColumn, CharColumn, VarcharColumn, TextColumn, 
        NCharColumn, NVarcharColumn, NTextColumn, BinaryColumn, VarbinaryColumn, 
        ImageColumn, UniqueIdentifierColumn, Sql_VariantColumn, XmlColumn, 
        GeometryColumn, GeographyColumn, HierarchyIdColumn
    )
    VALUES (
        CAST(RAND()*1000000000000 AS BIGINT),
        CAST(FLOOR(2 * RAND()) AS BIT),
        CAST((RAND()*1000 - RAND()*1000) AS DECIMAL(18,6)),
        CAST((RAND()*10000 - RAND()*10000) AS INT),
        CAST((RAND()*1000000 - RAND()*1000000) AS MONEY),
        CAST((RAND()*100000 - RAND()*100000) AS NUMERIC(18,2)),
        CAST((RAND()*256 -RAND()*256) AS SMALLINT),
        CAST((RAND()*1000 - RAND()*1000) AS SMALLMONEY),
        CAST(RAND()*255 AS TINYINT),
        RAND()*100000 - RAND()*100000,
        RAND()*100000 - RAND()*100000,
        DATEADD(DAY, CAST((RAND()*10000 - RAND()*10000) AS INT), '2000-01-01'),
        DATEADD(SECOND, CAST(RAND()*10000 AS INT), '2000-01-01T12:00:00'),
        DATEADD(SECOND, CAST(RAND()*10000 AS INT), '2000-01-01T12:00:00'),
        SYSDATETIMEOFFSET(),
        DATEADD(MINUTE, CAST(RAND()*10000 AS INT), '2000-01-01T12:00:00'),
        CAST(DATEADD(SECOND, CAST(RAND()*86400 AS INT), '00:00:00') AS TIME),
        dbo.fn_GetRandomString(10),
        dbo.fn_GetRandomString(128),
        dbo.fn_GetRandomString(256),
        dbo.fn_GetRandomString(10),
        dbo.fn_GetRandomString(128),
        dbo.fn_GetRandomString(256),
        CAST(NEWID() AS BINARY(50)),
        CAST(NEWID() AS VARBINARY(50)),
        CAST(NEWID() AS VARBINARY(MAX)),
        NEWID(),
        'RandomVariantValue',
        '<root><data>RandomXMLData</data></root>', -- TODO: Make this more complete
        NULL, -- Geometry column, left NULL for simplicity
        NULL, -- Geography column, left NULL for simplicity
        '/' + CAST(CAST(RAND()*100 AS INT) AS VARCHAR) + '/'
    );

    SET @counter = @counter + 1;

    IF @counter % 100 = 0
    BEGIN   
        PRINT 'Inserted ' + CAST(@Counter AS NVARCHAR(10)) + ' rows.';
    END

END;
GO

select * from DataTypesExample
GO
