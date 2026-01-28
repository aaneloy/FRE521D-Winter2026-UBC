
================================================================================
DATA CONTRACT: climate_agriculture_analysis
================================================================================

Description: Integrated climate and agricultural production data by country and year

Generated: 2026-01-26 13:25:37

--------------------------------------------------------------------------------
SCHEMA
--------------------------------------------------------------------------------

country_code:
  Type: object
  Non-null: 40/40 (100.0%)
  Unique values: 10
  Sample values: ['ARG', 'AUS', 'BRA', 'CAN', 'CHN']

country_name:
  Type: object
  Non-null: 40/40 (100.0%)
  Unique values: 10
  Sample values: ['Argentina', 'Australia', 'Brazil', 'Canada', 'China']

year:
  Type: int64
  Non-null: 40/40 (100.0%)
  Unique values: 4
  Range: [2020.00, 2023.00]

region:
  Type: object
  Non-null: 40/40 (100.0%)
  Unique values: 5
  Sample values: ['South America', 'Oceania', 'North America', 'Asia', 'Europe']

hemisphere:
  Type: object
  Non-null: 40/40 (100.0%)
  Unique values: 2
  Sample values: ['Southern', 'Northern']

arable_land_mha:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 10
  Range: [11.80, 157.70]

wheat_prod_mt:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 38
  Range: [7.80, 135.90]

maize_prod_mt:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 40
  Range: [3.90, 345.40]

total_cereal_prod_mt:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 40
  Range: [17.70, 446.30]

yield_wheat_ton_ha:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 39
  Range: [2.55, 4.36]

yield_maize_ton_ha:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 40
  Range: [3.06, 11.87]

cereal_intensity_mt_per_mha:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 40
  Range: [0.15, 28.37]

annual_temp_anomaly_c:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 34
  Range: [0.52, 1.91]

temp_category:
  Type: category
  Non-null: 40/40 (100.0%)
  Unique values: 3
  Sample values: ['Very Hot', 'Hot', 'Warm']

growing_season_precip_mm:
  Type: float64
  Non-null: 40/40 (100.0%)
  Unique values: 40
  Range: [203.00, 784.00]

precip_category:
  Type: category
  Non-null: 40/40 (100.0%)
  Unique values: 4
  Sample values: ['Moderate', 'Wet', 'Very Wet', 'Dry']

--------------------------------------------------------------------------------
CONSTRAINTS
--------------------------------------------------------------------------------

Primary Key: year
Foreign Keys: Not specified

--------------------------------------------------------------------------------
BUSINESS RULES
--------------------------------------------------------------------------------

- Numeric measures should be non-negative where applicable
- Year should fall within the dataset coverage
- Missing values should be represented as NULL in the database

--------------------------------------------------------------------------------
REFRESH SCHEDULE
--------------------------------------------------------------------------------

- Update frequency: Depends on source
- Data source: Document per dataset / API
- Last updated: Document per refresh run

================================================================================
