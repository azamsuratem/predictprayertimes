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

-- prayer names
CREATE TABLE [dbo].[t_time_prayer_names]
(
	[time_prayer_id] TINYINT NOT NULL PRIMARY KEY,
	[time_prayer_name] NVARCHAR(10) NOT NULL
);
INSERT INTO [dbo].[t_time_prayer_names]
VALUES (1,'Fajr'),(2,'Zuhr'),(3,'Asr'),(4,'Maghrib'),(5,'Isha');

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
	[time_date] DATE NOT NULL,
	[time_prayer_id] TINYINT NOT NULL
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

IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [name] = 'p_time_prayer_names_get')
	EXEC ('CREATE PROCEDURE [dbo].[p_time_prayer_names_get] AS SET NOCOUNT ON;')
GO

ALTER PROCEDURE [dbo].[p_time_prayer_names_get]
AS
BEGIN
	SELECT time_prayer_id, time_prayer_name
	FROM t_time_prayer_names
	ORDER BY time_prayer_id ASC
END
GO


IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [name] = 'p_time_prayer_sources_get')
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


IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [name] = 'p_time_stamp_get')
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


IF NOT EXISTS (SELECT 1 FROM [sys].[procedures] WHERE [name] = 'p_time_prayer_source_x_get')
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
	IF (@source_id = 1)
	BEGIN
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
	ELSE
	BEGIN
		DECLARE @err VARCHAR(1024) = 'No such table exists for t_time_prayer_source_' + CAST(@source_id AS VARCHAR(2));
		THROW 23100, @err, 1; 
	END
END
GO

