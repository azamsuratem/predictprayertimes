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

CREATE TABLE dim.time_prayer_names
(
	time_prayer_id INT NOT NULL PRIMARY KEY,
	time_prayer NVARCHAR(10) NOT NULL
);

CREATE TABLE dim.time_stamp
(
	time_id INT NOT NULL PRIMARY KEY,
	time_date DATE NOT NULL
);

CREATE TABLE dim.e_solat_jakim
(
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.islamic_finder
(
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE dim.muslim_pro
(
	time_date DATE NOT NULL,
	time_fajr TIME(0) NOT NULL,
	time_zuhr TIME(0) NOT NULL,
	time_asr TIME(0) NOT NULL,
	time_maghrib TIME(0) NOT NULL,
	time_isha TIME(0) NOT NULL
);

CREATE TABLE fact.diff_fajr
(
	time_id INT NOT NULL PRIMARY KEY,
	e_solat_jakim TIME(0) NOT NULL,
	islamic_finder TIME(0) NOT NULL,
	muslim_pro TIME(0) NOT NULL
);

CREATE TABLE fact.diff_zuhr
(
	time_id INT NOT NULL PRIMARY KEY,
	e_solat_jakim TIME(0) NOT NULL,
	islamic_finder TIME(0) NOT NULL,
	muslim_pro TIME(0) NOT NULL
);

CREATE TABLE fact.diff_asr
(
	time_id INT NOT NULL PRIMARY KEY,
	e_solat_jakim TIME(0) NOT NULL,
	islamic_finder TIME(0) NOT NULL,
	muslim_pro TIME(0) NOT NULL
);

CREATE TABLE fact.diff_maghrib
(
	time_id INT NOT NULL PRIMARY KEY,
	e_solat_jakim TIME(0) NOT NULL,
	islamic_finder TIME(0) NOT NULL,
	muslim_pro TIME(0) NOT NULL
);

CREATE TABLE fact.diff_isha
(
	time_id INT NOT NULL PRIMARY KEY,
	e_solat_jakim TIME(0) NOT NULL,
	islamic_finder TIME(0) NOT NULL,
	muslim_pro TIME(0) NOT NULL
);