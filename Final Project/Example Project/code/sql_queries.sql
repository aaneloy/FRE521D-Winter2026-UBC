-- FRE 521D Final Project - SQL Queries
-- Team AgroAnalytics
-- February 2024

-- These queries were used to extract data from our A1 and A2 databases
-- We exported results to CSV for analysis in Python

-- ========================================
-- QUERY 1: Crop production data with cleaning
-- ========================================

SELECT 
    c.country_name,
    c.iso3_code,
    cp.year,
    cp.crop,
    cp.production_tonnes,
    cp.area_harvested_ha,
    cp.yield_kg_ha,
    cp.fertilizer_kg_ha
FROM crop_production cp
INNER JOIN countries c ON cp.country_id = c.country_id
WHERE cp.yield_kg_ha > 0  -- remove zeros/negatives
    AND cp.year >= 1990
    AND cp.crop IN ('Wheat', 'Maize', 'Rice', 'Soybeans', 'Barley', 'Sorghum')
ORDER BY c.country_name, cp.year, cp.crop;

-- Exported to: crop_production_cleaned.csv


-- ========================================
-- QUERY 2: Weather data from A2
-- ========================================

SELECT 
    c.iso3_code,
    w.year,
    AVG(w.temperature_c) as avg_temperature_c,
    SUM(w.precipitation_mm) as precipitation_mm,
    STDDEV(w.temperature_c) as temp_variability
FROM weather_data w
INNER JOIN countries c ON w.country_id = c.country_id
GROUP BY c.iso3_code, w.year
ORDER BY c.iso3_code, w.year;

-- Exported to: weather_data_cleaned.csv


-- ========================================
-- QUERY 3: Country metadata
-- ========================================

SELECT 
    country_id,
    country_name,
    iso3_code,
    income_group,
    region,
    latitude,
    longitude
FROM countries
ORDER BY country_name;

-- Exported to: countries.csv


-- ========================================
-- QUERY 4: Quick summary check
-- ========================================

-- Verify we have data for all major regions
SELECT 
    c.region,
    COUNT(DISTINCT c.country_id) as n_countries,
    COUNT(*) as n_obs,
    AVG(cp.yield_kg_ha) as avg_yield
FROM crop_production cp
INNER JOIN countries c ON cp.country_id = c.country_id
WHERE cp.year >= 2000
GROUP BY c.region
ORDER BY avg_yield DESC;


-- ========================================
-- QUERY 5: Data quality check
-- ========================================

-- Check for missing values
SELECT 
    'yield_kg_ha' as column_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN yield_kg_ha IS NULL THEN 1 ELSE 0 END) as null_count,
    ROUND(SUM(CASE WHEN yield_kg_ha IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_pct
FROM crop_production

UNION ALL

SELECT 
    'fertilizer_kg_ha',
    COUNT(*),
    SUM(CASE WHEN fertilizer_kg_ha IS NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN fertilizer_kg_ha IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM crop_production;


-- ========================================
-- QUERY 6: Year coverage by country
-- ========================================

SELECT 
    c.country_name,
    MIN(cp.year) as first_year,
    MAX(cp.year) as last_year,
    COUNT(DISTINCT cp.year) as n_years
FROM crop_production cp
INNER JOIN countries c ON cp.country_id = c.country_id
GROUP BY c.country_id, c.country_name
HAVING COUNT(DISTINCT cp.year) >= 20  -- at least 20 years of data
ORDER BY n_years DESC;
