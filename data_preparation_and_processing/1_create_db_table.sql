/* BEGIN DELETE VIEWS */

DROP VIEW IF EXISTS [layer1];
DROP VIEW IF EXISTS [layer2];
DROP VIEW IF EXISTS [layer3];
DROP VIEW IF EXISTS [layer3_subsidiary];
DROP VIEW IF EXISTS [layer4];

/* END DELETE VIEWS */


/* BEGIN DELETE EXISTING TABLES WHEN BOOLEAN IS SET */

DECLARE @RECREATE_INPUT_TABLES AS BIT = 1  -- 1 = TRUE, 0 = FALSE
DECLARE @RECREATE_HELPER_TABLES AS BIT = 1 
DECLARE @RECREATE_LAYER_TABLES AS BIT = 1

IF @RECREATE_LAYER_TABLES = 1
BEGIN
	DROP TABLE IF EXISTS [layer1_data];
	DROP TABLE IF EXISTS [layer2_data];
	DROP TABLE IF EXISTS [layer3_data];
	DROP TABLE IF EXISTS [layer3_subsidiary_data];
	DROP TABLE IF EXISTS [layer4_data];
END

IF @RECREATE_INPUT_TABLES = 1
BEGIN
	DROP TABLE IF EXISTS [data_input];
	DROP TABLE IF EXISTS [parent_subsidiary];
	DROP TABLE IF EXISTS [population];
	DROP TABLE IF EXISTS [population_details];
END

IF @RECREATE_HELPER_TABLES = 1
BEGIN
	DROP TABLE IF EXISTS [group_type];
	DROP TABLE IF EXISTS [statistic];
	DROP TABLE IF EXISTS [unit_type];
	DROP TABLE IF EXISTS [variable];
	DROP TABLE IF EXISTS [period];
END

/* END DELETE EXISTING TABLES WHEN BOOLEAN IS SET (DEFAULT = FALSE!) */



/* BEGIN CREATE INPUT TABLES */



/* BEGIN CREATE HELPER TABLES */

IF @RECREATE_HELPER_TABLES = 1
BEGIN
	-- Period table

	CREATE TABLE [period] (
		[id] int IDENTITY(1,1) PRIMARY KEY,
		[value] NVARCHAR(128),
		[description] NVARCHAR(128)
	)

	-- Variable table

	CREATE TABLE [variable] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[value] NVARCHAR(256),
		[description] NVARCHAR(128)
	)

	-- unit_type table

	CREATE TABLE [unit_type] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[value] NVARCHAR(128),
		[description] NVARCHAR(128)
	)

	-- statistic table

	CREATE TABLE [statistic] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[value] NVARCHAR(128),
		[description] NVARCHAR(128)
	)

	-- group_type table

	CREATE TABLE [group_type] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[value] NVARCHAR(128),
		[description] NVARCHAR(128)
	)
END

/* END CREATE HELPER TABLES */

IF @RECREATE_INPUT_TABLES = 1
BEGIN

	-- population_details table

	CREATE TABLE [population_details] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[unit_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[unit_id] NVARCHAR(128),
		[legal_name] NVARCHAR(128),
		[NACE] NVARCHAR(128),
		[is_excluded] BIT
	)

	-- population table

	CREATE TABLE [population] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[unit_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[unit_id] NVARCHAR(128), 
		[group_type_id] INT FOREIGN KEY REFERENCES [group_type](id),
		[group_id] NVARCHAR(128)
	)

	-- parent_subsidiary table

	CREATE TABLE [parent_subsidiary] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[parent_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[parent_id] NVARCHAR(128), 
		[subsidiary_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[subsidiary_id] NVARCHAR(128) 
	)

	-- data_input table

	CREATE TABLE [data_input] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[unit_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[unit_id] NVARCHAR(128), 
		[stat_id] INT FOREIGN KEY REFERENCES [statistic](id),
		[variable_id] INT FOREIGN KEY REFERENCES [variable](id),
		[value] FLOAT,
		[weight] FLOAT,
		[status] NVARCHAR(128),
	)
END

/* END CREATE INPUT TABLES */



/* BEGIN CREATE LAYER_DATA TABLES */

IF @RECREATE_LAYER_TABLES = 1
BEGIN
	-- create layer1_data table

	CREATE TABLE [layer1_data] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[group_type_id] INT FOREIGN KEY REFERENCES [group_type](id),
		[group_id] NVARCHAR(128), 
		[variable_id] INT FOREIGN KEY REFERENCES [variable](id),
		[value] FLOAT,
		[timestamp] DATETIME
	)

	-- create layer2_data table

	CREATE TABLE [layer2_data] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[group_type_id] INT FOREIGN KEY REFERENCES [group_type](id),
		[group_id] NVARCHAR(128), 
		[variable_id] INT FOREIGN KEY REFERENCES [variable](id),
		[stat1_id] INT FOREIGN KEY REFERENCES [statistic](id),
		[stat2_id] INT FOREIGN KEY REFERENCES [statistic](id),
		[count] INT,
		[overlap] INT,
		[sum_score] FLOAT,
		[max_score] FLOAT,
		[value_stat1_overlap_weight1] DECIMAL(10,0),
		[value_stat2_overlap_weight1] DECIMAL(10,0),
		[value] FLOAT,
		[timestamp] DATETIME
	)

	-- create layer3_data table

	CREATE TABLE [layer3_data] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[group_type_id] INT FOREIGN KEY REFERENCES [group_type](id),
		[group_id] NVARCHAR(128), 
		[variable_id] INT FOREIGN KEY REFERENCES [variable](id),
		[unit_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[unit_id] NVARCHAR(128), 
		[stat1_id] INT FOREIGN KEY REFERENCES [statistic](id),
		[stat2_id] INT FOREIGN KEY REFERENCES [statistic](id),
		[score] FLOAT,
		[is_excluded] BIT,
		[legal_name] NVARCHAR(128),
		[NACE] NVARCHAR(128),
		[value1] FLOAT,
		[value2] FLOAT,
		[status1] NVARCHAR(128),
		[status2] NVARCHAR(128),
		[weight1] FLOAT,
		[weight2] FLOAT,
		[timestamp] DATETIME
	)

	-- create subsidiary_data table

	CREATE TABLE [layer3_subsidiary_data] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[parent_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[parent_id] NVARCHAR(128), 
		[variable_id] INT FOREIGN KEY REFERENCES [variable](id),
		[unit_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[unit_id] NVARCHAR(128), 
		[stat_id] INT FOREIGN KEY REFERENCES [statistic](id),
		[legal_name] NVARCHAR(128),
		[NACE] NVARCHAR(128),
		[value] FLOAT,
		[status] NVARCHAR(128),
		[timestamp] DATETIME
	)

	-- create layer4_data table

	CREATE TABLE [layer4_data] (
		[id] INT IDENTITY(1,1) PRIMARY KEY,
		[period_id] INT FOREIGN KEY REFERENCES [period](id),
		[unit_type_id] INT FOREIGN KEY REFERENCES [unit_type](id),
		[unit_id] NVARCHAR(128), 
		[variable_id] INT FOREIGN KEY REFERENCES [variable](id),
		[stat_id] INT FOREIGN KEY REFERENCES [statistic](id),
		[value] INT,
		[timestamp] DATETIME
	)

END

/* END CREATE LAYER_DATA TABLES */