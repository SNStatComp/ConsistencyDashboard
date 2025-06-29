/********** START: USER INPUT IN SCRIPT NEEDED **********/

-- Score cutoff value: Applied to prevent disproportionately large and non-informative scores that may occur when the score's denominator approaches zero. 
DECLARE @MAXSCORE DECIMAL(10,4) = 2.0;


-- Create a helper table specifying, for each variable, which data source should be used in the denominator of the scores.
   -- If the denominator is empty, the totals from stat1 are used; otherwise, the totals from the specified alternative sources are applied.
   -- Users must fill in the variables and alternative denominators (in the first two columns) themselves in the table #source_denominator. The corresponding variable_id's and statistic_id's will be completed automatically.
DROP TABLE IF EXISTS #source_denominator;
CREATE TABLE #source_denominator (
	  variable VARCHAR(255)
	, source_denominator VARCHAR(10)
	, variable_id INT
	, statistic_id INT
	)
INSERT INTO #source_denominator
VALUES
        ('VAR_A', NULL, NULL, NULL)
      , ('VAR_B', 'ST_ABC', NULL, NULL)
      , ('VAR_C', NULL, NULL, NULL)
      , ('VAR_D', NULL, NULL, NULL)

-- Adding the corresponding variable_id's and statistic_id's
UPDATE #source_denominator
SET variable_id = v.id,
	statistic_id = s.id
FROM #source_denominator bn
LEFT OUTER JOIN [variable] v ON (bn.variable = v.[value])
LEFT OUTER JOIN [statistic] s ON (bn.source_denominator = s.[value])

/********** END: USER INPUT IN SCRIPT NEEDED **********/



/********** START: DATA PREPARATION  **********/

-- Create a helper table listing the underlying unit type for each source.
   -- Each source is allowed to have only one unit type.
   -- If a source has multiple unit types, they must be stored as separate sources in the data_input table.
   -- For score calculations, the #source_denominator table specifies which source to use as the denominator.
DROP TABLE IF EXISTS #stat_unit_type
SELECT DISTINCT stat_id
	, unit_type_id
INTO #stat_unit_type
FROM [data_input]

/*** START: Aggregate data from subsidiaries to the parent company level ***/

-- Append aggregated subsidiary data to the input data.
-- Write the combined dataset to the #data_tot table.
-- This is only performed when data from all subsidiaries within the parent company is available.

-- Transfer data from the #data_input table to the data_tot table. Additional data will be appended to #data_tot later in the process.
DROP TABLE IF EXISTS #data_tot
SELECT [period_id]
	, [unit_type_id]
	, [unit_id]
	, [stat_id]
	, [variable_id]
	, [value]
	, [weight]
	, [status]
	, CAST(NULL AS BIT) AS ParentIsSubsidiary -- Add flag to indicate whether the parent company is the same as the subsidiary (1:1 relationship)
INTO #data_tot
FROM [data_input]

-- Number of subsidiaries per parent company
DROP TABLE IF EXISTS #numb_subsidiaries
SELECT period_id
	, parent_type_id
	, parent_id
	, subsidiary_type_id
	, count(*) AS numb_subsidiaries
INTO #numb_subsidiaries
FROM [parent_subsidiary]
GROUP BY period_id
	, parent_type_id
	, parent_id
	, subsidiary_type_id

-- Subsidiary data, including parent_type and parent_id
DROP TABLE IF EXISTS #subsidiaries_data_base
SELECT ps.parent_type_id
	, ps.parent_id
	, dat.*
INTO #subsidiaries_data_base
FROM [data_input] dat
JOIN [parent_subsidiary] ps ON (
		dat.unit_type_id = ps.subsidiary_type_id
		AND dat.unit_id = ps.subsidiary_id
		AND dat.period_id = ps.period_id
		)

-- Number of subsidiaries with data
DROP TABLE IF EXISTS #numb_subsidiaries_data
SELECT period_id
	, parent_type_id
	, parent_id
	, unit_type_id
	, stat_id
	, variable_id
	, COUNT(*) AS numb_subsidiaries_data
INTO #numb_subsidiaries_data
FROM #subsidiaries_data_base
GROUP BY period_id
	, parent_type_id
	, parent_id
	, unit_type_id
	, stat_id
	, variable_id

-- Retain only data from subsidiaries for which all subsidiaries within the same parent company have available data (per statistic and variable)
DROP TABLE IF EXISTS #subsidiaries_data
SELECT sd.*
	, ns.numb_subsidiaries
	, nsd.numb_subsidiaries_data
INTO #subsidiaries_data
FROM #subsidiaries_data_base sd
JOIN #numb_subsidiaries ns ON (
		sd.period_id = ns.period_id
		AND sd.parent_type_id = ns.parent_type_id
		AND sd.parent_id = ns.parent_id
		AND sd.unit_type_id = ns.subsidiary_type_id
		)
JOIN #numb_subsidiaries_data nsd ON (
		sd.period_id = nsd.period_id
		AND sd.parent_type_id = nsd.parent_type_id
		AND sd.parent_id = nsd.parent_id
		AND sd.unit_type_id = nsd.unit_type_id
		AND sd.stat_id = nsd.stat_id
		AND sd.variable_id = nsd.variable_id
		)
WHERE ns.numb_subsidiaries = nsd.numb_subsidiaries_data

-- Extend the #data_tot table, initially pre-filled with only #input_data, by adding the aggregated data from subsidiaries at the parent company level
INSERT INTO #data_tot
SELECT dat.period_id
	, parent_type_id
	, parent_id
	, stat_id
	, dat.variable_id
	, SUM(dat.[value])
	, MAX(CASE
			WHEN numb_subsidiaries = 1
				THEN [weight]
			ELSE 1 -- At the parent company level when multiple subsidiaries exist, the value is effectively undefined. This field is in such case only used when calculating group totals and is then set to 1.
		  END) 
	, MAX(CONVERT(VARCHAR(50), numb_subsidiaries_data) + '/' + CONVERT(VARCHAR(50), numb_subsidiaries) + ' ' + ut.[value])  -- Status field: number of subsidiaries with available data relative to the total number of subsidiaries.
	, MAX(CASE
			WHEN numb_subsidiaries = 1
				THEN 1
			ELSE 0
		  END)
FROM #subsidiaries_data dat
JOIN [unit_type] ut ON (
		dat.unit_type_id = ut.id
		)
GROUP BY parent_type_id
	, parent_id
	, stat_id
	, dat.variable_id
	, dat.period_id

/*** END: Aggregate data from subsidiaries to the parent company level. ***/

-- create a helper table containing group totals
DROP TABLE IF EXISTS #group_totals
SELECT dat.period_id
	, pop.group_type_id
	, pop.group_id
	, dat.unit_type_id
	, stat_id
	, variable_id
	, SUM([weight] * [value]) AS group_total
	, COUNT(*) AS group_count
INTO #group_totals
FROM #data_tot dat
JOIN [population] pop ON (
		dat.unit_type_id = pop.unit_type_id
		AND dat.unit_id = pop.unit_id
		AND dat.period_id = pop.period_id
		)
GROUP BY pop.group_type_id
	, pop.group_id
	, dat.unit_type_id
	, stat_id
	, variable_id
	, dat.period_id

-- Create a helper table containing all possible combinations of parent company types and subsidiary types
DROP TABLE IF EXISTS #parent_subsidiary_types
SELECT DISTINCT parent_type_id
	, subsidiary_type_id
INTO #parent_subsidiary_types
FROM [parent_subsidiary]

-- Create a helper table with the population data, including the population details; For performance reasons, this is not done in the joins for layer 3.
DROP TABLE IF EXISTS #population
SELECT pop.*
	, legal_name
	, NACE
	, is_excluded
INTO #population
FROM [population] pop
JOIN [population_details] pop_det ON (
		pop_det.unit_type_id = pop.unit_type_id
		AND pop_det.unit_id = pop.unit_id
		AND pop_det.period_id = pop.period_id
		)

/********** END: DATA PREPARATION **********/



/********** START: DATA PROCESSING - CALCULATING ALL DATA TO BE DISPLAYED ON DASHBOARD **********/

/*** Create table containing data for LAYER 3 on the dashboard ***/
-- Layer 3 is calculated first as it forms the basis for Layers 1, 2, and is used in Layer 4.
-- It shows combinations of statistics at the unit level on the dashboard.
-- For each unit, it includes variable values and a score function, but also legal name, status values, ...
-- Data covers all units within a given aggregate (group) level and statistic combinations.
DELETE FROM [layer3_data];  -- First, empty layer3_data
INSERT INTO [layer3_data] (period_id, group_type_id, group_id, variable_id, unit_type_id, unit_id, stat1_id, stat2_id, score, is_excluded, legal_name, NACE, value1, value2, status1, status2, weight1, weight2, [timestamp])
SELECT dat1.period_id
	, pop.group_type_id
	, pop.group_id
	, dat1.variable_id
	, dat1.unit_type_id
	, dat1.unit_id
	, dat1.stat_id AS stat1
	, dat2.stat_id AS stat2
	, CONVERT(DECIMAL(10, 4),
		CASE 
			WHEN dat1.[weight] * ABS(dat1.[value] - dat2.[value]) / ABS(IIF(group_total = 0, 1, group_total)) > @MAXSCORE
				THEN @MAXSCORE -- Score cutoff value: Applied to prevent disproportionately large and non-informative scores that may occur when the score's denominator approaches zero; If the denominator is 0, then use 1
			ELSE dat1.[weight] * ABS(dat1.[value] - dat2.[value]) / ABS(IIF(group_total = 0, 1, group_total))
		END) AS score
	, is_excluded
	, legal_name
	, NACE
	, dat1.[value] AS waarde1
	, dat2.[value] AS waarde2
	, dat1.[status] AS status1
	, dat2.[status] AS status2
	, dat1.[weight] AS gewicht1
	, dat2.[weight] AS gewicht2
	, GETDATE()
FROM #data_tot dat1
JOIN #data_tot dat2 ON (  -- This join ensures that only overlapping combinations of statistics are included
		dat1.unit_type_id = dat2.unit_type_id
		AND dat1.unit_id = dat2.unit_id
		AND dat1.variable_id = dat2.variable_id
		AND dat1.period_id = dat2.period_id
		)
JOIN #population pop ON (
		dat1.unit_type_id = pop.unit_type_id
		AND dat1.unit_id = pop.unit_id
		AND dat1.period_id = pop.period_id
		)
JOIN #stat_unit_type sut1 ON (sut1.stat_id = dat1.stat_id)  -- The unit_type associated with stat1, regardless of whether the units were aggregated from subsidiaries to the parent company level (and were thus stored using the parent_type in #data_tot)
JOIN #stat_unit_type sut2 ON (sut2.stat_id = dat2.stat_id)  -- Same for stat2
JOIN #group_totals gt ON (  -- For score calculation, always use the denominator total corresponding to the unit type of stat1
		gt.unit_type_id = sut1.unit_type_id
		AND gt.variable_id = dat1.variable_id
		AND gt.group_type_id = pop.group_type_id
		AND gt.group_id = pop.group_id
		AND dat1.period_id = gt.period_id
		) 
JOIN #source_denominator sd ON (  -- Addition to the previous join: use the denominator total of the stat from the #source_denominator table, and use the denominator total of stat1 if stat in #source_denominator is empty
		dat1.variable_id = sd.variable_id
		AND gt.stat_id = ISNULL(sd.statistic_id, dat1.stat_id)
		)
LEFT JOIN #parent_subsidiary_types pctA ON (  -- Do NOT combine two subsidiary units on the level of the parent company with each other! See also the WHERE-clause.
		sut1.unit_type_id = pctA.subsidiary_type_id
		AND sut2.unit_type_id = pctA.subsidiary_type_id
		AND dat1.unit_type_id = pctA.parent_type_id
		)
LEFT JOIN #parent_subsidiary_types pctB ON ( -- If stat1 is a subsidiary and stat2 is a parent company, exclude the pair if the parent does not match the subsidiary! See also the WHERE-clause.
		sut1.unit_type_id = pctB.subsidiary_type_id
		AND sut2.unit_type_id = pctB.parent_type_id
		AND dat1.ParentIsSubsidiary = 0
		)
WHERE dat1.stat_id <> dat2.stat_id       -- Combinations of the same two stats are not needed and are excluded here
	AND pctA.subsidiary_type_id IS NULL  -- See comments on the join with pctA
	AND pctB.subsidiary_type_id IS NULL  -- See comments on the join with pctB

-- subsidiary data used to drill down from Layer 3 data at the parent company level to the underlying subsidiaries
DELETE FROM [layer3_subsidiary_data]  -- First, empty subsidiary_data for layer 3 down-drilling
INSERT INTO [layer3_subsidiary_data] ([period_id], [parent_type_id], [parent_id], [variable_id], [unit_type_id], [unit_id], [stat_id], [legal_name], [NACE], [value], [status], [timestamp])
SELECT DISTINCT sd.period_id -- DISTINCT is used because units appear multiple times in the population table, once per group_type
	, parent_type_id
	, parent_id
	, sd.variable_id
	, sd.unit_type_id
	, sd.unit_id
	, sd.stat_id
	, pop.legal_name
	, pop.NACE
	, [value]
	, [status]
	, GETDATE() AS [timestamp]
FROM #subsidiaries_data sd
JOIN #population pop ON (  -- population table is needed for amongst other things the legal names of the subsidiaries
		sd.period_id = pop.period_id
		AND sd.unit_type_id = pop.unit_type_id
		AND sd.unit_id = pop.unit_id
		)
JOIN [layer3_data] l3 ON (  -- A join with Layer 3 is used to restrict the dataset to only the data necessary for drilling down. Data needs to be written only for cases where sd.stat is stat2 at Layer 3, since the 1:n restriction between parant company and subsidiaries ensures that all relevant data is already included there.
		sd.period_id = l3.period_id
		AND sd.parent_type_id = l3.unit_type_id
		AND sd.parent_id = l3.unit_id
		AND sd.variable_id = l3.variable_id
		AND sd.stat_id = l3.stat2_id
		)

/*** Create table containing data for LAYER 2 on the dashboard ***/
/*
  - Layer 2 displays aggregated Layer 3 data at the level of group_type_id, group_id, and variable_id, for all relevant combinations of statistics.
  
  - It includes:
    • The total number of units for stat1.
    • The number of overlapping units with stat2.
    • The sum and maximum of the scores for the underlying Layer 3 units.
    • For overlapping units: the weighted sums of values for stat1 and stat2, using the weights from stat1 (since we are assessing the influence of errors in stat1).
    • The denominator total used in the score calculation, based on the unit type of stat1.
*/
DELETE FROM [layer2_data];  -- First, empty layer2_data
INSERT INTO [layer2_data] ([period_id], [group_type_id], [group_id], [variable_id], [stat1_id], [stat2_id], [count], [overlap], [sum_score], [max_score], [value_stat1_overlap_weight1], [value_stat2_overlap_weight1], [value], [timestamp])
SELECT l3.period_id
	, l3.group_type_id
	, l3.group_id
	, l3.variable_id
	, stat1_id
	, stat2_id
	, gt_stat1.group_count
	, COUNT(*)
	, CONVERT(DECIMAL(10, 3),
		SUM(CASE 
				WHEN is_excluded = 0  -- Use only units that are not excluded, as indicated by a flag in the population table — for example, units handled by the Large Case Unit (LCU) rather than by analysts using the top-down dashboard.
					THEN score
				ELSE 0
			END))
	, CONVERT(DECIMAL(10, 3),
		MAX(CASE
				WHEN is_excluded = 0  -- Same as above
					THEN score
				ELSE 0
			END))
	, CONVERT(DECIMAL(10, 0), SUM(weight1 * value1)) -- weighted sum of stat1 values in overlap is calculated from data of Layer 3
	, CONVERT(DECIMAL(10, 0), SUM(weight1 * value2)) -- weighted sum of stat2 values in overlap is calculated from data of Layer 3
	, CONVERT(DECIMAL(10, 0), gt_denominator.group_total)
	, getdate()
FROM [layer3_data] AS l3
JOIN #stat_unit_type sut ON (sut.stat_id = l3.stat1_id)           -- Needed for indication of which unit_type is used for the denominator of the scores. This denominator is shown as the total value.
JOIN #source_denominator sd ON (sd.variable_id = l3.variable_id)  -- Needed for indication of which stat is used for the denominator of the scores. This denominator is shown as the total value.
JOIN #group_totals gt_denominator ON (                   -- Table containing all group total values, here used for the denominator total
		gt_denominator.group_type_id = l3.group_type_id
		AND gt_denominator.group_id = l3.group_id
		AND gt_denominator.unit_type_id = sut.unit_type_id
		AND gt_denominator.variable_id = sd.variable_id
		AND gt_denominator.stat_id = ISNULL(sd.statistic_id, l3.stat1_id)
		AND l3.period_id = gt_denominator.period_id
		) 
JOIN #group_totals gt_stat1 ON (  -- Similar, but here for the total number of units for stat1
		gt_stat1.group_type_id = l3.group_type_id
		AND gt_stat1.group_id = l3.group_id
		AND gt_stat1.unit_type_id = sut.unit_type_id
		AND gt_stat1.variable_id = sd.variable_id
		AND gt_stat1.stat_id = l3.stat1_id
		AND gt_stat1.period_id = l3.period_id
		) 
GROUP BY l3.group_type_id
	, l3.group_id
	, l3.variable_id
	, stat1_id
	, stat2_id
	, gt_denominator.group_total
	, gt_stat1.group_count
	, l3.period_id

/*** Create table containing data for LAYER 1 on the dashboard ***/

-- Per variable and unit_id, the maximum score is calculated for each combination of group_type and group_id.
-- Then the sum of these values is calculated as the sumscore and the maximum is calculated as the maxscore.
-- The result is placed in a base table, which in the view [layer1] is pivoted from long to wide format, for display on the dashboard.
DELETE FROM [layer1_data];  -- First, empty layer1_data
INSERT INTO [layer1_data] ([period_id], [group_type_id], [group_id], [variable_id], [value], [timestamp])
SELECT a.period_id
	, group_type_id
	, group_id
	, variable_id
	, CONVERT(DECIMAL(10, 3), MAX(maxscore))
	, GETDATE()
FROM (
	SELECT period_id
		, group_type_id
		, group_id
		, variable_id
		, unit_id
		, MAX(score) AS maxscore
	FROM [layer3_data]
	WHERE is_excluded = 0  -- As in Layer 2, use only units that are not excluded, as indicated by a flag in the population table
	GROUP BY group_type_id
		, group_id
		, variable_id
		, unit_id
		, period_id
	) a
GROUP BY group_type_id
	, group_id
	, variable_id
	, a.period_id

/*** Create table containing data for LAYER 4 on the dashboard ***/

-- Data of all stats is retrieved from the #data_tot table for a specific unit and then in the view [layer4] pivoted to wide format
DELETE FROM [layer4_data];  -- First, empty layer4_data
INSERT INTO [layer4_data] 
SELECT period_id
	, unit_type_id
	, unit_id
	, variable_id
	, stat_id
	, CONVERT(INT, [value]) as [value]
	, GETDATE() AS [timestamp]
FROM #data_tot

/********** END: DATA PROCESSING - CALCULATING ALL DATA TO BE DISPLAYED ON DASHBOARD **********/
