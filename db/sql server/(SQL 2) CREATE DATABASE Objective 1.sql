USE [master]
GO

CREATE DATABASE PrayerTimesDM1
GO

USE [PrayerTimesDM1]
GO

CREATE SCHEMA fact
GO

CREATE SCHEMA dim
GO

CREATE TABLE dim.sources
(
	source_id INT NOT NULL PRIMARY KEY,
	source_name NVARCHAR(50) NOT NULL
);

CREATE TABLE dim.time_stamp
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL
);

CREATE TABLE dim.e_solat_jakim
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL,
	source_id INT NOT NULL
);

CREATE TABLE dim.islamic_finder
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL,
	source_id INT NOT NULL
);

CREATE TABLE dim.muslim_pro
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL,
	source_id INT NOT NULL
);

CREATE TABLE fact.diff_prayer_times
(
	time_id INT NOT NULL PRIMARY KEY,
	source_refer INT,
	diff_fajr_source_1_source_2 INT NOT NULL,
	diff_zuhr_source_1_source_2 INT NOT NULL,
	diff_asr_source_1_source_2 INT NOT NULL,
	diff_maghrib_source_1_source_2 INT NOT NULL,
	diff_isha_source_1_source_2 INT NOT NULL,
	source_compare_2 INT,
	diff_fajr_source_1_source_3 INT NOT NULL,
	diff_zuhr_source_1_source_3 INT NOT NULL,
	diff_asr_source_1_source_3 INT NOT NULL,
	diff_maghrib_source_1_source_3 INT NOT NULL,
	diff_isha_source_1_source_3 INT NOT NULL,
	source_compare_3 INT,
	FOREIGN KEY (time_id) REFERENCES dim.time_stamp (time_id) ON DELETE CASCADE ON UPDATE CASCADE
);