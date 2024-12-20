/* 1. Create DB & Schema */

USE [master]
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'PrayerTimesDW')
BEGIN
	DECLARE @killConn VARCHAR(2048) = '';
	SELECT @killConn = @killConn + 'KILL ' + CONVERT(VARCHAR(5), session_id)
	FROM sys.dm_exec_sessions WHERE database_id = DB_ID('PrayerTimesDW')
	EXEC (@killConn);

	DROP DATABASE PrayerTimesDW
END

CREATE DATABASE PrayerTimesDW
GO

USE [PrayerTimesDW]
GO

/* 2. Create Tables */

-- data source & its URL
CREATE TABLE [dbo].[t_time_prayer_sources]
(
	[source_id] INT IDENTITY(1,1) PRIMARY KEY,
	[source_name] NVARCHAR(50) NOT NULL,
	[source_url] VARCHAR(1024)
);
INSERT INTO [dbo].[t_time_prayer_sources]
	([source_name],[source_url])
VALUES
	('e-Solat JAKIM', 'https://www.e-solat.gov.my/index.php'),
	('Islamic Finder', 'https://www.islamicfinder.org/prayer-times/'),
	('Muslim Pro', 'https://www.muslimpro.com/en/find')
;

-- time stamp based on date & time prayer name
CREATE TABLE [dbo].[t_time_stamp]
(
	[time_id] INT IDENTITY(1,1) PRIMARY KEY,
	[time_date] DATE NOT NULL
);

-- e-Solat JAKIM, from 2018-01-01 to 2024-12-31
CREATE TABLE [dbo].[t_time_prayer_source_1]
(
	[time_date] DATE NOT NULL,
	[time_fajr] TIME(0) NOT NULL,
	[time_zuhr] TIME(0) NOT NULL,
	[time_asr] TIME(0) NOT NULL,
	[time_maghrib] TIME(0) NOT NULL,
	[time_isha] TIME(0) NOT NULL
);

-- IslamicFinder.org, on 2024-01-XX only
CREATE TABLE [dbo].[t_time_prayer_source_2]
(
	[time_date] DATE NOT NULL,
	[time_fajr] TIME(0) NOT NULL,
	[time_zuhr] TIME(0) NOT NULL,
	[time_asr] TIME(0) NOT NULL,
	[time_maghrib] TIME(0) NOT NULL,
	[time_isha] TIME(0) NOT NULL
);

-- Muslim Pro apps, 2024-01-XX only
CREATE TABLE [dbo].[t_time_prayer_source_3]
(
	[time_date] DATE NOT NULL,
	[time_fajr] TIME(0) NOT NULL,
	[time_zuhr] TIME(0) NOT NULL,
	[time_asr] TIME(0) NOT NULL,
	[time_maghrib] TIME(0) NOT NULL,
	[time_isha] TIME(0) NOT NULL
);

/* 3. Create Stored Procedures */

IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [object_id] = OBJECT_ID('p_time_prayer_sources_get'))
	EXEC ('CREATE PROCEDURE [dbo].[p_time_prayer_sources_get] AS SET NOCOUNT ON;')
GO

ALTER PROCEDURE [dbo].[p_time_prayer_sources_get]
AS
BEGIN
	SELECT source_id, source_name
	FROM t_time_prayer_sources
	ORDER BY source_id ASC
END
GO


IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [object_id] = OBJECT_ID('p_time_stamp_get'))
	EXEC ('CREATE PROCEDURE [dbo].[p_time_stamp_get] AS SET NOCOUNT ON;')
GO

ALTER PROCEDURE [dbo].[p_time_stamp_get]
(
	@time_start DATETIME = NULL,
	@time_end DATETIME = NULL
)
AS
BEGIN
	SELECT time_id, time_date
	FROM t_time_stamp
	WHERE @time_start IS NULL OR CONVERT(DATE, @time_start) >= time_date
	AND @time_end IS NULL OR CONVERT(DATE, @time_end) <= time_date 
END
GO


IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [object_id] = OBJECT_ID('p_time_prayer_source_x_get'))
	EXEC ('CREATE PROCEDURE [dbo].[p_time_prayer_source_x_get] AS SET NOCOUNT ON;')
GO

ALTER PROCEDURE [dbo].[p_time_prayer_source_x_get]
(
	@source_id INT = 1,
	@time_start DATETIME = NULL,
	@time_end DATETIME = NULL
)
AS
BEGIN
	IF (@source_id IS NULL OR @source_id = 1)
	BEGIN
		DECLARE @errNull VARCHAR(1024) = 'NULL @source_id is parsed, fall back to use default source_id = 1';
		IF (@source_id IS NULL) RAISERROR(@errNull, 11, 1);

		SELECT time_date, time_fajr, time_zuhr, time_asr, time_maghrib, time_isha
		FROM t_time_prayer_source_1
		WHERE @time_start IS NULL OR CONVERT(DATE, @time_start) >= time_date
		AND @time_end IS NULL OR CONVERT(DATE, @time_end) <= time_date
	END
	ELSE IF (@source_id = 2)
	BEGIN
		SELECT time_date, time_fajr, time_zuhr, time_asr, time_maghrib, time_isha
		FROM t_time_prayer_source_2
		WHERE @time_start IS NULL OR CONVERT(DATE, @time_start) >= time_date
		AND @time_end IS NULL OR CONVERT(DATE, @time_end) <= time_date 
	END
	ELSE IF (@source_id = 3)
	BEGIN
		SELECT time_date, time_fajr, time_zuhr, time_asr, time_maghrib, time_isha
		FROM t_time_prayer_source_3
		WHERE @time_start IS NULL OR CONVERT(DATE, @time_start) >= time_date
		AND @time_end IS NULL OR CONVERT(DATE, @time_end) <= time_date 
	END
	ELSE IF (@source_id <= 0)
	BEGIN
		DECLARE @errInput VARCHAR(1024) = 'Wrong integer parsed for @source_id!';
		THROW 55000, @errInput, 1;
	END
	ELSE
	BEGIN
		DECLARE @errNotFound VARCHAR(1024) = 'No such table exists for t_time_prayer_source_' + CAST(@source_id AS VARCHAR(2)) + '!';
		THROW 51000, @errNotFound, 1; 
	END
END
GO


IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [object_id] = OBJECT_ID('p_time_stamp_update'))
	EXEC ('CREATE PROCEDURE [dbo].[p_time_stamp_update] AS SET NOCOUNT ON;')
GO

ALTER PROCEDURE [dbo].[p_time_stamp_get]
AS
BEGIN
	IF NOT EXISTS (
		SELECT 1 FROM [dbo].[t_time_prayer_source_1]
		UNION ALL
		SELECT 1 FROM [dbo].[t_time_prayer_source_2]
		UNION ALL
		SELECT 1 FROM [dbo].[t_time_prayer_source_3]
	)
		RETURN
	
	CREATE TABLE #all_dates (time_date DATETIME);

	WITH cte_dates AS (
		SELECT DISTINCT time_date FROM t_time_prayer_source_1
		UNION ALL
		SELECT DISTINCT time_date FROM t_time_prayer_source_2
		UNION ALL
		SELECT DISTINCT time_date FROM t_time_prayer_source_3
	)
	INSERT INTO #all_dates (time_date)
	SELECT time_date FROM cte_dates GROUP BY time_date;

	DECLARE 
		@row_count_raw BIGINT, @first_date_raw DATETIME, @last_date_raw DATETIME
		,@row_count_saved BIGINT, @first_date_saved DATETIME, @last_date_saved DATETIME
	;

	SELECT
		@row_count_raw = COUNT(time_date)
		,@first_date_raw = MIN(time_date)
		,@last_date_raw = MAX(time_date)
		FROM #all_dates;

	SELECT
		@row_count_saved = COUNT(time_date)
		,@first_date_saved = MIN(time_date)
		,@last_date_saved = MAX(time_date)
		FROM t_time_stamp;

	IF (
		@row_count_raw = @row_count_saved
		AND @first_date_raw = @first_date_saved
		AND @last_date_raw = @last_date_saved
	)
	BEGIN
		DROP TABLE #all_dates;
		RETURN
	END

	SET IDENTITY_INSERT t_time_stamp ON
	
	DELETE FROM t_time_stamp;
	
	INSERT INTO t_time_stamp (time_id, time_date)
	SELECT ROW_NUMBER() OVER (ORDER BY time_date ASC), time_date
	FROM #all_dates ORDER BY time_date ASC;

	SET IDENTITY_INSERT t_time_stamp OFF

	DROP TABLE #all_dates;
END