DECLARE @DELETE_LAYER_VIEWS AS BIT = 1

IF @DELETE_LAYER_VIEWS = 1
BEGIN
	DROP VIEW IF EXISTS [layer1];
	DROP VIEW IF EXISTS [layer2];
	DROP VIEW IF EXISTS [layer3];
	DROP VIEW IF EXISTS [layer3_subsidiary];
	DROP VIEW IF EXISTS [layer4];
END

GO

/* BEGIN CREATE LAYER VIEWS */

-- create view layer 1
GO
DECLARE @COLUMN_NAMES_LAYER1 NVARCHAR(MAX);
DECLARE @SQL_VIEW_LAYER1 NVARCHAR(MAX);

-- Step 1. Generate list of unique variables
SELECT @COLUMN_NAMES_LAYER1 = STRING_AGG(QUOTENAME([value]), ', ')  -- The order of variables from the #source_denominator table is preserved. If alphabetical order is preferred, add: WITHIN GROUP (ORDER BY variable)
FROM (SELECT [value] FROM [variable]) AS column_names;

-- Step 2. Build dynamical PIVOT-query
-- Currently the maxscore is used, but sumscore is also an option
SET @SQL_VIEW_LAYER1 = '
CREATE VIEW [layer1]
	WITH SCHEMABINDING
AS
SELECT
	  period
	, group_type
	, group_id
	, ' + @COLUMN_NAMES_LAYER1 + '
FROM ( SELECT
		  p.[value] AS period
		, gt.[value] AS group_type
		, l1.group_id AS group_id
		, v.[value] AS variable
		, l1.[value] AS value
		FROM [layer1_data] l1
		JOIN [period] p ON l1.period_id = p.id
		JOIN [group_type] gt ON l1.group_type_id = gt.id
		JOIN [variable] v ON l1.variable_id = v.id
) AS tbl
PIVOT(SUM([value]) FOR variable IN (' + @COLUMN_NAMES_LAYER1 + ')) AS pvt;
';

-- Step 3. Execute
EXEC sp_executesql @SQL_VIEW_LAYER1;

-- create view layer 2
GO
CREATE VIEW [layer2]
	WITH SCHEMABINDING
AS
SELECT 
	l2.id,
	p.[value] AS [period],
	gt.[value] AS [group_type],
	l2.group_id,
	v.[value] AS [variable],
	s1.[value] AS [stat1],
	s2.[value] AS [stat2],
	l2.[count],
	l2.overlap,
	l2.sum_score AS [score],
	l2.max_score,
	l2.value_stat1_overlap_weight1,
	l2.value_stat2_overlap_weight1,
	l2.[value],
	l2.[timestamp]
FROM [layer2_data] l2
JOIN [period] p ON l2.period_id = p.id
JOIN [group_type] gt ON l2.group_type_id = gt.id
JOIN [variable] v ON l2.variable_id = v.id
JOIN [statistic] s1 ON l2.stat1_id = s1.id
JOIN [statistic] s2 ON l2.stat2_id = s2.id

-- create view layer 3
GO
CREATE VIEW [layer3]
	WITH SCHEMABINDING
AS
SELECT 
	l3.id,
	p.[value] AS [period],
	gt.[value] AS [group_type],
	l3.group_id,
	v.[value] AS [variable],
	ut.[value] AS [unit_type],
	l3.unit_id,
	s1.[value] AS [stat1],
	s2.[value] AS [stat2],
	l3.score,
	l3.is_excluded,
	l3.legal_name,
	l3.NACE,
	l3.value1,
	l3.value2,
	l3.status1,
	l3.status2,
	l3.weight1,
	l3.weight2,
	l3.[timestamp]
FROM [layer3_data] l3
JOIN [period] p ON l3.period_id = p.id
JOIN [group_type] gt ON l3.group_type_id = gt.id
JOIN [variable] v ON l3.variable_id = v.id
JOIN [unit_type] ut ON l3.unit_type_id = ut.id
JOIN [statistic] s1 ON l3.stat1_id = s1.id
JOIN [statistic] s2 ON l3.stat2_id = s2.id

-- create view layer 3 subsidiary
GO
CREATE VIEW [layer3_subsidiary]
	WITH SCHEMABINDING
AS
SELECT 
	sd.id,
	p.[value] AS [period],
	pt.[value] AS [parent_type],
	sd.parent_id,
	v.[value] AS [variable],
	ut.[value] AS [unit_type],
	sd.unit_id,
	s.[value] AS [stat],
	sd.legal_name,
	sd.NACE,
	sd.[value],
	sd.[status],
	sd.[timestamp]
FROM [layer3_subsidiary_data] sd
JOIN [period] p ON sd.period_id = p.id
JOIN [unit_type] pt ON sd.parent_type_id = pt.id
JOIN [variable] v ON sd.variable_id = v.id
JOIN [unit_type] ut ON sd.unit_type_id = ut.id
JOIN [statistic] s ON sd.stat_id = s.id

-- create view layer 4
GO
DECLARE @COLUMN_NAMES_LAYER4 NVARCHAR(MAX);
DECLARE @SQL_VIEW_LAYER4 NVARCHAR(MAX);

-- Step 1. Generate list of unique variables
SELECT @COLUMN_NAMES_LAYER4 = STRING_AGG(QUOTENAME([value]), ', ')  -- The order of variables from the #source_denominator table is preserved. If alphabetical order is preferred, add: WITHIN GROUP (ORDER BY variable)
FROM (SELECT [value] FROM [statistic]) AS column_names;

-- Step 2. Build dynamical PIVOT-query
-- Currently the maxscore is used, but sumscore is also an option
SET @SQL_VIEW_LAYER4 = '
CREATE VIEW [layer4]
	WITH SCHEMABINDING
AS
SELECT
      period
	, unit_type
	, unit_id
	, variable
	, ' + @COLUMN_NAMES_LAYER4 + '
FROM ( SELECT
		  p.[value] AS period
		, ut.[value] AS unit_type
		, l4.unit_id AS unit_id
		, v.[value] AS variable
		, s.[value] AS stat
		, l4.[value] AS value
		FROM [layer4_data] l4
		JOIN [period] p ON l4.period_id = p.id
		JOIN [unit_type] ut ON l4.unit_type_id = ut.id
		JOIN [variable] v ON l4.variable_id = v.id
		JOIN [statistic] s ON l4.stat_id = s.id
) AS tbl
PIVOT(SUM([value]) FOR stat IN (' + @COLUMN_NAMES_LAYER4 + ')) AS pvt;
';

-- Step 3. Execute
EXEC sp_executesql @SQL_VIEW_LAYER4;

/* END CREATE LAYER VIEWS */
