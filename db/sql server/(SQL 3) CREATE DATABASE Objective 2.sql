USE [master]
GO

CREATE DATABASE PrayerTimesDM2
GO

USE [PrayerTimesDM2]
GO

CREATE SCHEMA fact
GO

CREATE SCHEMA dim
GO

CREATE TABLE dim.time_stamp
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL
);

-- actual data from e-Solat JAKIM period Jan 2024

CREATE TABLE dim.actual_prayer_fajr
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.actual_prayer_zuhr
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.actual_prayer_asr
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.actual_prayer_maghrib
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.actual_prayer_isha
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

-- predicted data for Jan 2024

CREATE TABLE dim.predict_prayer_fajr
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.predict_prayer_zuhr
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.predict_prayer_asr
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.predict_prayer_maghrib
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.predict_prayer_isha
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

-- fact table on data comparison

CREATE TABLE fact.diff_prayer_times
(
	time_id INT NOT NULL PRIMARY KEY,
	diff_fajr INT NOT NULL,
	diff_zuhr INT NOT NULL,
	diff_asr INT NOT NULL,
	diff_maghrib INT NOT NULL,
	diff_isha INT NOT NULL,
	FOREIGN KEY (time_id) REFERENCES dim.time_stamp (time_id) ON DELETE CASCADE ON UPDATE CASCADE
);