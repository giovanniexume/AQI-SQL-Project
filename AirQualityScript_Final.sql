
--CBSA Air Quality Exploration. Skills used: Joins, Aggregate Functions, Creating Views--


--Good Days, Moderate Days, and Unhealthy for Sensitive Group Days vs Days with AQI--
--Shows percentage of Good Days and Unhealthy for Sensitive Group Days per Year for my CBSA--


SELECT CBSA, Year, Good_Days, (Good_Days/Days_with_AQI)*100 as PercentageGoodDays, Moderate_Days, (Moderate_Days/Days_with_AQI)*100 AS PercentageModerateDays, Unhealthy_Sensitive_Groups_Days, (Unhealthy_Sensitive_Groups_Days/Days_with_AQI)*100 as PercentageSensitiveDays
FROM annual_aqi_by_cbsa AS aabc
WHERE CBSA = 'New York-Newark-Jersey City, NY-NJ-PA'


--PM2.5, Ozone and NO2 make up the majority of Main Pollutants for 2019 in my CBSA, so lets break results down by those three pollutants--

--Ozone Main Pollutant Days for 2019--

SELECT Days_Ozone, CBSA
FROM annual_aqi_by_cbsa
WHERE Year = 2019 

--NO2 Main Pollutant Days for 2019--

SELECT Days_NO2, CBSA 
FROM annual_aqi_by_cbsa
WHERE Year = 2019

--PM2.5 Main Pollutant Days for 2019--

SELECT Days_PM25, CBSA
FROM annual_aqi_by_cbsa
WHERE Year = 2019;


--Creating a View for Main Pollutant Percentages for Ozone, NO2 and PM2.5--

CREATE VIEW MainPollutantPercentanges AS
SELECT CBSA, YEAR, (Days_Ozone/Days_with_AQI)*100 AS PercentageOzoneDays, (Days_NO2/Days_with_AQI)*100 AS PercentageNO2Days, (Days_PM25/Days_with_AQI)*100 AS PercentagePM25Days
FROM annual_aqi_by_cbsa
WHERE Year = 2019 

SELECT *
FROM MainPollutantPercentanges


--Essex County NO2 Concentration compared to AQI Value for 2019, at Newark Firehouse--
--Newark Firehouse is closest Site within CBSA for my town.--

SELECT apc.Date, cc.Date, apc.Main_Pollutant, apc.NO2 AS NO2AQI, apc.Overall_AQI_Value, cc.Daily_Max_1hour_NO2_Concentration, apc.AQI_Category, apc.Site_Name 
FROM aqidaily2019_p_csv AS apc
LEFT JOIN CBSANO2concentrations AS cc ON apc.DATE = cc.DATE AND apc.Site_Name = cc.Site_Name
WHERE apc.Main_Pollutant = 'NO2' AND cc.Site_Name = 'Newark Firehouse'


--Essex County PM2.5 Concentration compared to AQI Value for 2019--

SELECT apc.Date, cp.Date, apc.Main_Pollutant, apc.PM25 AS 'PM25_AQI', apc.Overall_AQI_Value, cp.Daily_Mean_PM25_Concentration, apc.AQI_Category, apc.Site_Name, cp.Site_Name 
FROM aqidaily2019_p_csv AS apc
LEFT JOIN CBSAPM2 AS cp ON apc.DATE = cp.DATE AND apc.Site_Name = cp.Site_Name AND apc.OVerall_AQI_Value = cp.DAILY_AQI_VALUE
WHERE apc.Main_Pollutant = 'PM2.5' AND cp.Site_Name = 'Newark Firehouse'

--Ozone Concentration compared to AQI Value for 2019--
--There are no days for Newark Firehouse where Ozone was documented as main pollutant. This query only shows overall CBSA results--

SELECT apc.Date, apc.Main_Pollutant, apc.Ozone AS OzoneAQI, apc.Overall_AQI_Value, c.Daily_Max_8hour_Ozone_Concentration, apc.AQI_Category, apc.Site_Name
FROM aqidaily2019_p_csv AS apc
LEFT JOIN CBSAdailyozoneconcentrations_new_csv AS c ON apc.DATE = c.DATE AND apc.Site_Name = c.Site_Name
WHERE apc.Main_Pollutant = 'Ozone'

--Creating AQI category columns in aqidaily2019--

ALTER TABLE aqidaily2019_p_csv 
ADD AQI_Category varchar(75)

UPDATE aqidaily2019_p_csv 
SET AQI_Category = CASE WHEN Overall_AQI_Value <= 50 THEN 'Good' 
	WHEN Overall_AQI_Value BETWEEN 51 AND 100 THEN 'Moderate'
	WHEN Overall_AQI_Value BETWEEN 101 AND 150 THEN 'Unhealthy for Sensitive Groups'
	WHEN Overall_AQI_Value BETWEEN 151 AND 200 THEN 'Unhealthy'
	WHEN Overall_AQI_Value BETWEEN 201 AND 300 THEN 'Very Unhealthy'
	ELSE 'Hazardous'
	END